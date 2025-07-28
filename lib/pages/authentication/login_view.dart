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
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16.sp),
        child: SizedBox(
          height: 30.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InputField(controller: emailController, hintText: "Email"),
              InputField(controller: passwordController, hintText: "Password"),
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
                        .eq("email", emailController.text.trim());
                      if(response.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("You are not registered as a restaurant!"));
                        return;
                      }else {
                        // fetch data 
                        ref.read(userDocumentsProvider.notifier).state = response[0];
                        AppNavigation.navRouter.go("/home");
                        ScaffoldMessenger.of(context).showSnackBar(SuccessMessage("You have signed in successfully!"));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Sign-in failed. Please check your credentials."));
                    }
                  } on AuthException catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Authentication error: ${error.message}"));
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("An unexpected error occurred: $error"));
                  }
                },
                style: blackButton, 
                child: Text("Sign In",),
              ),
              TextButton(
                onPressed: (){}, 
                child: Text("Forgot Password")
              )
            ],
          ),
        ),
      ),
    );
  }
}