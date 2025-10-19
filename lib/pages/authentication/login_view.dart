import 'dart:async';
import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/authentication/gallery_setting_view.dart';
import 'package:dinney_restaurant/pages/authentication/location_selection.dart';
import 'package:dinney_restaurant/pages/authentication/menu_creation_view.dart';
import 'package:dinney_restaurant/pages/authentication/schedule_view.dart';
import 'package:dinney_restaurant/pages/authentication/sign_up_view.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends ConsumerWidget {
  LoginView({super.key});
  final emailConfirmationProvider = StateProvider<bool>((ref)=> false);
  final emailConfirmed = StateProvider<bool>((ref)=> false);

  @override
  Widget build(context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).sign_in,
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16.sp),
        child: !ref.watch(emailConfirmationProvider)?  Column(
          spacing: 16.sp,
          children: [
            InputField(controller: emailController, hintText: S.of(context).email),
            InputField(
              controller: passwordController,
              hintText: S.of(context).password,
              obscureText: true,
            ),
            ref.watch(savingLoadingButton)? LoadingSpinner() : ElevatedButton(
              onPressed: () async {
                ref.read(savingLoadingButton.notifier).state = true;
                final supabase = Supabase.instance.client;
                try {
                  var result = await supabase.from("restaurants").select().eq("email", emailController.text.trim());
                  if(result.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      ErrorMessage(S.of(context).auth_error),
                    );
                    throw AuthException("No Account Found!");
                  }
                  final response = await supabase.rpc('is_email_confirmed', params: {'email': emailController.text.trim()});
                  if(!response){
                    ref.read(emailConfirmationProvider.notifier).state = true;
                    Timer.periodic(const Duration(seconds: 5), (timer) async {
                      final response = await supabase.rpc('is_email_confirmed', params: {'email': emailController.text.trim()});
                      final confirmed = response;
                      if (confirmed) {
                        timer.cancel();
                        ref.read(emailConfirmed.notifier).state = true;
                        Future.delayed(Duration(seconds: 2), () async{
                          await supabase.auth.signInWithPassword(
                            email: emailController.text.trim(), 
                            password: passwordController.text.trim()).whenComplete(() async{
                              await supabase.from("restaurants").update({
                                "fcm_token" : token ?? ""
                                }).eq("email", emailController.text.trim())
                                .whenComplete(() async{
                                  //function test if all restaurant setup is done
                                  await supabase.from("restaurants").select().eq("email", emailController.text.trim()).single().then((response){
                                    print("The response is : $response");
                                    //function test if images are available;
                                    if(response['urls'] == null || response['urls'].length == 0){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => GallerySettingView(response['id'],)));
                                    }
                                    //function test if menu is added
                                    else if(response['menu_id'] == null){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuCreationView(response['id'],)));
                                    }
                                    //function test if schedule is setup
                                    else if(response['schedule'] == null || response['schedule'].length == 0){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleView(id: response['id'])));
                                    } //function test if location is set
                                    else if(response['lat'] == null || response['lng'] == null || response['wilaya'] == null){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LocationSelection(id: response['id'])));
                                    }
                                    //function else go to home
                                    else{
                                      AppNavigation.navRouter.go("/home");
                                        ScaffoldMessenger.of(context).showSnackBar(
                                        SuccessMessage(S.of(context).sign_successfully),
                                      );
                                    }
                                  });
                              });
                            });
                        });
                      } else {
                        ref.read(emailConfirmationProvider.notifier).state = true;
                        print('⏳ Still not confirmed...');
                      }
                    });
                  }else{
                  //LOGIC update the fcm_token
                  await supabase.auth.signInWithPassword(
                    email: emailController.text.trim(), 
                    password: passwordController.text.trim()).whenComplete(() async{
                  await supabase.from("restaurants").update({
                    "fcm_token" : token ?? ""
                    }).eq("email", emailController.text.trim())
                    .whenComplete(() async{
                          //function test if all restaurant setup is done
                          await supabase.from("restaurants").select().eq("email", emailController.text.trim()).single().then((response){
                            print("The response is : $response");
                            //function test if images are available;
                            if(response['urls'] == null || response['urls'].length == 0){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GallerySettingView(response['id'],)));
                            }
                            //function test if menu is added
                            else if(response['menu_id'] == null){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MenuCreationView(response['id'],)));
                            }
                            //function test if schedule is setup
                            else if(response['schedule'] == null || response['schedule'].length == 0){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleView(id: response['id'])));
                            } //function test if location is set
                            else if(response['lat'] == null || response['lng'] == null || response['wilaya'] == null){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LocationSelection(id: response['id'])));
                            }
                            //function else go to home
                            else{
                              AppNavigation.navRouter.go("/home");
                                ScaffoldMessenger.of(context).showSnackBar(
                                SuccessMessage(S.of(context).sign_successfully),
                              );
                            }
                          });
                      });
                    });
                }
                } on AuthException catch (error) {
                  print(' Unexpected error: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    ErrorMessage("${S.of(context).error} $error"),
                  );
                } catch (error) {
                  print(' Unexpected error: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    ErrorMessage("${S.of(context).unexpected_error} $error"),
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
        ) : ref.watch(emailConfirmed)? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16.sp,
            children: [
              Lottie.asset('assets/animations/checkmark.json', width: 50.w),
              Text("Email Confimed", style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.green),)
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
              Text("We have sent you a confirmation email\nPlease check your inbox!")
            ],
           ),
         ),
      ),
    );
  }
}
