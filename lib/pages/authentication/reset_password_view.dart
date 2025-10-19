
import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/authentication/gallery_setting_view.dart';
import 'package:dinney_restaurant/pages/authentication/location_selection.dart';
import 'package:dinney_restaurant/pages/authentication/menu_creation_view.dart';
import 'package:dinney_restaurant/pages/authentication/schedule_view.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    final supabase = Supabase.instance.client;
    final newPassword = _passwordController.text;
    final confirm = _confirmController.text;

    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorMessage(S.of(context).password_dont_match));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (mounted) {
        print("the mail is ${supabase.auth.currentUser!.email!}");
        ScaffoldMessenger.of(context).showSnackBar(
          SuccessMessage(S.of(context).password_updated_successfully));
        await supabase.auth.signInWithPassword(
          email: supabase.auth.currentUser!.email, 
          password: newPassword).whenComplete(() async{
            await supabase.from("restaurants").update({
              "fcm_token" : token ?? ""
              }).eq("email", supabase.auth.currentUser!.email!)
              .whenComplete(() async{
                //function test if all restaurant setup is done
                await supabase.from("restaurants").select().eq("email", supabase.auth.currentUser!.email!).single().then((response){
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        ErrorMessage("${S.of(context).error}: $e")
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).reset_password)),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          spacing: 16.sp,
          children: [
            InputField(
              controller: _passwordController,
              hintText: S.of(context).new_password,
              obscureText: true,
            ),
            InputField(
              controller: _confirmController,
              hintText: S.of(context).confirm_password,
              obscureText: true,
            ),
            _isLoading? LoadingSpinner() : ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              child: Text(S.of(context).update_password),
            ),
          ],
        ),
      ),
    );
  }
}
