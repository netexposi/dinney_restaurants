import 'dart:async';

import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/authentication/gallery_setting_view.dart';
import 'package:dinney_restaurant/services/models/restaurant_model.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/circles_indicator.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/privacy_policy_content.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpView extends ConsumerWidget{
   SignUpView({super.key});
    final emailConfirmationProvider = StateProvider<bool>((ref)=> false);
    final emailConfirmed = StateProvider<bool>((ref)=> false);
    bool agreeToTerms = false;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      
      appBar: AppBar(
        title: Text(S.of(context).sing_up)
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16.sp),
          child: SizedBox(
            height: 100.h,
            width: 100.w,
            child: !ref.watch(emailConfirmationProvider)? Column(
              spacing: 16.sp,
              children: [
                ThreeDotsIndicator(),
                Text(S.of(context).create_restaurant_account),
                InputField(controller: nameController, hintText: S.of(context).restaurant_name),
                InputField(controller: emailController, hintText: S.of(context).email),
                InputField(controller: passwordController, hintText: S.of(context).password, obscureText: true,),
                InputField(controller: confirmPasswordController, hintText: S.of(context).confirm_password, obscureText: true,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16.sp,
                  children: [
                    StatefulBuilder(builder: (context, setState){
                      return Checkbox.adaptive(
                        activeColor: secondaryColor,
                        value: agreeToTerms, 
                        onChanged: (value){
                          if(value == null || value == true){
                            FocusScope.of(context).unfocus();
                            showAdaptiveDialog(context: context, builder: (context){
                              return Dialog(
                                backgroundColor: Colors.white,
                                insetPadding: EdgeInsets.all(16.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.sp),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 70.h,
                                      child: PrivacyPolicyContent(languageIndex: ref.watch(languageStateProvider),)
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(16.sp),
                                      child: ElevatedButton(
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                          setState((){
                                            agreeToTerms = true;
                                          });
                                        }, 
                                        child: Text(S.of(context).accept)
                                      ),
                                    )
                                  ],
                                ),
                              );
                            });
                          }else {
                            setState((){
                              agreeToTerms = false;
                            });
            
                          }
                        //ref.read(agreeToTermsProvider.notifier).state = value ?? false;
                      });
                    }),
                    Expanded(child: Text(S.of(context).agree_to_terms))
                  ],
                ),
                ref.watch(savingLoadingButton)? LoadingSpinner() : ElevatedButton(
                  onPressed: () async{
                    ref.read(savingLoadingButton.notifier).state = true;
                    // in case fields are empty
                    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).fields_empty));
                    } else if(!agreeToTerms){
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(ErrorMessage(S.of(context).you_must_agree_to_terms));
                    }
                    // in case passwords don't match
                    else if(passwordController.text != confirmPasswordController.text){
                      ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).passwords_dont_match));
                    }
                    // try logging in
                    else{
                      final supabase = Supabase.instance.client;
                      try {
                        var res = await supabase.from("restaurants").select("email").eq("email", emailController.text.trim());
                        var client = await supabase.from("clients").select("email").eq("email", emailController.text.trim());
                        if(res.isEmpty && client.isEmpty){
                          final response = await supabase.auth.signUp(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                          final user = response.user;
                          if (user != null) {
                            final supabase = Supabase.instance.client;
                            var restaurant= Restaurant(
                              uid: user.id,
                              name: nameController.text.trim(), 
                              email: emailController.text.trim(),
                              urls: []             
                            );
                            try {
                              await supabase
                                .from('restaurants')
                                .insert(restaurant.toJson())
                                .whenComplete(() async{
                                  ref.read(emailConfirmationProvider.notifier).state = true;
                                  await supabase.auth.signInWithPassword(
                                    email: emailController.text.trim(), 
                                    password: passwordController.text.trim()).whenComplete(() async{
                                      await supabase.from("restaurants").update({
                                        "fcm_token" : token != null ? [token] : []
                                        }).eq("email", emailController.text.trim())
                                        .whenComplete(() async{
                                          ref.read(signUpProvider.notifier).state = 1;
                                          res = await supabase.from("restaurants").select().eq("email", emailController.text.trim());
                                          int id = res[0]['id'];
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> GallerySettingView(id)));
                                      });
                                  });
                                  // Timer.periodic(const Duration(seconds: 5), (timer) async {
                                  //   final response = await supabase.rpc('is_email_confirmed', params: {'email': emailController.text.trim()});
                                  //   final confirmed = response;
                                  //   if (confirmed) {
                                  //     timer.cancel();
                                  //     ref.read(emailConfirmed.notifier).state = true;
                                  //     Future.delayed(Duration(seconds: 2), () async{
                                        
                                  //     });
                                  //   } else {
                                  //     ref.read(emailConfirmationProvider.notifier).state = true;
                                  //   }
                                  // });
                                });
                              // You can return or use the insertedClient if needed
                            } on PostgrestException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).failed_to_add_restaurant));
                              ref.read(savingLoadingButton.notifier).state = false;
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).unexpected_error));
                              ref.read(savingLoadingButton.notifier).state = false;
                            }
                            
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).sign_failed));
                            ref.read(savingLoadingButton.notifier).state = false;
                          }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            ErrorMessage(S.of(context).account_already_exists)
                          );
                          ref.read(savingLoadingButton.notifier).state = false;
                          return;
                        }
                      } on AuthException catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).invalid_credentials));
                        ref.read(savingLoadingButton.notifier).state = false;
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).unexpected_error));
                        ref.read(savingLoadingButton.notifier).state = false;
                      }
                    }
                    ref.read(savingLoadingButton.notifier).state = false;
                  }, 
                  child: Text(S.of(context).next)
                )
        
              ],
            ) : ref.watch(emailConfirmed)? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16.sp,
                children: [
                  Lottie.asset('assets/animations/checkmark.json', width: 50.w),
                  Text(S.of(context).email_confirmed, style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.green),)
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
                  Text(S.of(context).please_wait)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}