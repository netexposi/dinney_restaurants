import 'dart:async';
import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/authentication/gallery_setting_view.dart';
import 'package:dinney_restaurant/pages/authentication/location_selection.dart';
import 'package:dinney_restaurant/pages/authentication/menu_creation_view.dart';
import 'package:dinney_restaurant/pages/authentication/schedule_view.dart';
import 'package:dinney_restaurant/pages/authentication/sign_up_view.dart';
import 'package:dinney_restaurant/services/functions/sound_player.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/animated_snack_content.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends ConsumerWidget {
  LoginView({super.key});
  final emailConfirmationProvider = StateProvider<bool>((ref) => false);
  final emailConfirmed = StateProvider<bool>((ref) => false);

  @override
  Widget build(context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).sign_in),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: !ref.watch(emailConfirmationProvider)
            ? Column(
                spacing: 16.sp,
                children: [
                  InputField(
                      controller: emailController,
                      hintText: S.of(context).email),
                  InputField(
                    controller: passwordController,
                    hintText: S.of(context).password,
                    obscureText: true,
                  ),
                  ref.watch(savingLoadingButton)
                      ? LoadingSpinner()
                      : ElevatedButton(
                          onPressed: () async {
                            ref.read(savingLoadingButton.notifier).state = true;
                            final supabase = Supabase.instance.client;

                            try {
                              // ✅ Check if account exists
                              var result = await supabase
                                  .from("restaurants")
                                  .select()
                                  .eq("email", emailController.text.trim());

                              if (result.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  ErrorMessage(S.of(context).no_account_found),
                                );
                                throw AuthException("No Account Found!");
                              }

                              // ✅ Check email confirmation
                              final response = await supabase.rpc(
                                'is_email_confirmed',
                                params: {
                                  'email': emailController.text.trim(),
                                },
                              );

                              if (!response) {
                                ref
                                    .read(emailConfirmationProvider.notifier)
                                    .state = true;

                                // Poll until email confirmed
                                Timer.periodic(const Duration(seconds: 5),
                                    (timer) async {
                                  final confirmed = await supabase.rpc(
                                    'is_email_confirmed',
                                    params: {
                                      'email': emailController.text.trim(),
                                    },
                                  );

                                  if (confirmed == true) {
                                    timer.cancel();
                                    ref
                                        .read(emailConfirmed.notifier)
                                        .state = true;

                                    Future.delayed(
                                        const Duration(seconds: 2), () async {
                                      await _handleSignInAndNavigation(
                                          context, ref, supabase,
                                          emailController.text.trim(),
                                          passwordController.text.trim());
                                    });
                                  } else {
                                    print('⏳ Still not confirmed...');
                                  }
                                });
                              } else {
                                // ✅ Already confirmed, try sign-in directly
                                await _handleSignInAndNavigation(
                                    context,
                                    ref,
                                    supabase,
                                    emailController.text.trim(),
                                    passwordController.text.trim());
                              }
                            } on AuthException catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                ErrorMessage(
                                    S.of(context).error),
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                ErrorMessage(
                                    S.of(context).unexpected_error),
                              );
                            }

                            ref.read(savingLoadingButton.notifier).state = false;
                          },
                          style: blackButton,
                          child: Text(S.of(context).sign_in),
                        ),
                  TextButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController resetEmailController =
                              TextEditingController();
                          return Dialog(
                            insetPadding: EdgeInsets.all(16.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.sp),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.sp),
                              child: Column(
                                spacing: 16.sp,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InputField(
                                    controller: resetEmailController,
                                    hintText: S.of(context).email,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (resetEmailController.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          ErrorMessage(S
                                              .of(context)
                                              .items_must_be_filled),
                                        );
                                        return;
                                      }

                                      try {
                                        await Supabase.instance.client.auth
                                            .resetPasswordForEmail(
                                          resetEmailController.text.trim(),
                                          redirectTo:
                                              'com.dinney.restaurant://reset-password',
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SuccessMessage(S
                                              .of(context)
                                              .reset_link_sent),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          ErrorMessage(
                                              "${S.of(context).error}: $e"),
                                        );
                                      }
                                    },
                                    child: Text(S.of(context).send),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(S.of(context).forgot_password),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpView()),
                      );
                    },
                    child: Text(S.of(context).create_account),
                  ),
                ],
              )
            : ref.watch(emailConfirmed)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.sp,
                      children: [
                        Lottie.asset('assets/animations/checkmark.json',
                            width: 50.w),
                        Text(
                          S.of(context).email_confirmed,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(color: Colors.green),
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.sp,
                      children: [
                        LoadingSpinner(),
                        Text(S.of(context).email_sent, textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
      ),
    );
  }

  /// 🧭 Handles actual sign-in and navigation after verification
  Future<void> _handleSignInAndNavigation(
    BuildContext context,
    WidgetRef ref,
    SupabaseClient supabase,
    String email,
    String password,
  ) async {
    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // ❌ If login fails, authResponse.user will be null
      if (authResponse.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          ErrorMessage(S.of(context).auth_error),
        );
        return;
      }

      // ✅ Update FCM token
      //await supabase..from("restaurants").select("fcm_token")
      // await supabase
      //     .from("restaurants")
      //     .update({"fcm_token": token ?? ""})
      //     .eq("email", email);

      final response = await supabase.from("restaurants").select().eq("email", email).single();
      var tokens = response['fcm_token']?? [];
        print("my tokens are $tokens");
        tokens.add(token);
        await supabase
          .from("restaurants")
          .update({"fcm_token": tokens ?? []})
          .eq("email", email);

      if (response['urls'] == null || response['urls'].isEmpty) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GallerySettingView(response['id'])));
            Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.zero,
            content: TweenAnimationBuilder<double>(
              tween: Tween(begin: 100, end: 0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: AnimatedSnackContent(),
                );
              },
            ),
          ),
        );
        SoundEffectPlayer.play();
      });
      } else if (response['menu_id'] == null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MenuCreationView(response['id'])));
            Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.zero,
            content: TweenAnimationBuilder<double>(
              tween: Tween(begin: 100, end: 0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: AnimatedSnackContent(),
                );
              },
            ),
          ),
        );
        SoundEffectPlayer.play();
      });
      } else if (response['schedule'] == null || response['schedule'].isEmpty) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ScheduleView(id: response['id'])));
            Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.zero,
            content: TweenAnimationBuilder<double>(
              tween: Tween(begin: 100, end: 0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: AnimatedSnackContent(),
                );
              },
            ),
          ),
        );
        SoundEffectPlayer.play();
      });
      } else if (response['lat'] == null ||
          response['lng'] == null ||
          response['wilaya'] == null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => LocationSelection(id: response['id'])));
            Future.delayed(const Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.zero,
            content: TweenAnimationBuilder<double>(
              tween: Tween(begin: 100, end: 0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: AnimatedSnackContent(),
                );
              },
            ),
          ),
        );
        SoundEffectPlayer.play();
      });
      } else {
        AppNavigation.navRouter.go("/home");
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorMessage(S.of(context).auth_error),
      );
    } catch (error) {
      print('❌ Unexpected sign-in error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorMessage(S.of(context).unexpected_error),
      );
    }
  }
}
