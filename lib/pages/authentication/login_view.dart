import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends ConsumerWidget{
  const LoginView({super.key});
  @override
  Widget build(context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).sign_in),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16.sp),
        child: SizedBox(
          height: 30.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InputField(controller: emailController, hintText: S.of(context).email),
              InputField(controller: passwordController, hintText: S.of(context).password, obscureText: true,),
              ElevatedButton(
                onPressed: () async{
                  final supabase = Supabase.instance.client;
                  try {
                    final response = await supabase.auth.signInWithPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
                    final user = response.user;
                    if (user != null) {
                      // checking if the user is actually a restaurant and not a client
                      final response = await supabase
                        .from("restaurants")
                        .select()
                        .eq("email", emailController.text.trim())
                        .single();
                      if(response.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).youre_not_registered_as_restaurant));
                        return;
                      }else {
                        // fetch data 
                        ref.read(userDocumentsProvider.notifier).state = response;
                        AppNavigation.navRouter.go("/home");
                        ScaffoldMessenger.of(context).showSnackBar(SuccessMessage(S.of(context).sign_successfully));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).sign_failed));
                    }
                  } on AuthException catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("${S.of(context).auth_error} ${error.message}"));
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("${S.of(context).unexpected_error} $error"));
                  }
                },
                style: blackButton, 
                child: Text(S.of(context).sign_in,),
              ),
              TextButton(
                onPressed: (){}, 
                child: Text(S.of(context).forgot_password)
              )
            ],
          ),
        ),
      ),
    );
  }
}