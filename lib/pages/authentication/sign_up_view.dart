import 'package:dinney_restaurant/pages/authentication/gallery_setting_view.dart';
import 'package:dinney_restaurant/services/models/restaurant_model.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpView extends ConsumerWidget{
  const SignUpView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16.sp),
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: Column(
            spacing: 16.sp,
            children: [
              Text("Create a restaurant account"),
              InputField(controller: nameController, hintText: "Restaurant Name"),
              InputField(controller: emailController, hintText: "Email"),
              InputField(controller: passwordController, hintText: "Password"),
              InputField(controller: confirmPasswordController, hintText: "Confirm Password"),
              ElevatedButton(
                onPressed: () async{
                  // in case fields are empty
                  if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Fields are empty"));
                  }
                  // in case passwords don't match
                  else if(passwordController.text != confirmPasswordController.text){
                    ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Passwords don't match"));
                  }
                  // try logging in
                  else{
                    final supabase = Supabase.instance.client;
                    try {
                      final response = await supabase.auth.signUp(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      final user = response.user;
                      if (user != null) {
                        var restaurant= Restaurant(
                          name: nameController.text.trim(), 
                          email: emailController.text.trim(),
                          urls: []             
                        );
                        final supabase = Supabase.instance.client;
                        late var query;
                        try {
                          query =  await supabase
                            .from('restaurants')
                            .insert(restaurant.toJson())
                            .select()
                            .single();
                          print(query['id']);
                          // You can return or use the insertedClient if needed
                        } on PostgrestException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Failed to add restaurant: ${e.message}"));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("An unexpected error occurred: $e"));
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> GallerySettingView(query['id'])));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Sign-in failed. Please check your credentials."));
                      }
                    } on AuthException catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Authentication error: ${error.message}"));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("An unexpected error occurred: $error"));
                    }
                  }
                }, 
                child: Text("Next")
              )

            ],
          ),
        ),
      ),
    );
  }
}