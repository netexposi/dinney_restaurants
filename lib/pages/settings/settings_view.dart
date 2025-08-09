import 'package:dinney_restaurant/pages/settings/profile_view.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/settings_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sizer/sizer.dart';

class SettingsView extends ConsumerWidget{
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<MaterialColor> colors = [Colors.blue, Colors.deepPurple, Colors.deepOrange, Colors.amber, Colors.teal, Colors.lightGreen, Colors.blueGrey, Colors.grey];
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.sp,
              children: [
                //SECTION Profile and edit profile
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileView()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${ref.watch(userDocumentsProvider)["name"]}", style: Theme.of(context).textTheme.headlineMedium,),
                              Text("ID: ${ref.watch(userDocumentsProvider)["id"]}", style: Theme.of(context).textTheme.bodySmall,),
                            ],
                          ),
                          HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: tertiaryColor)
                        ],
                      ),
                    ),
                    Divider(color: Colors.white,),
                  ],
                ),
                //SECTION Account
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.sp,
                  children: [
                    Text("Record", style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                    SizedBox(height: 16.sp,),
                    //SettingsElement(settingColor: colors[0], onClicked: () {  }, icon: HugeIcons.strokeRoundedAccountSetting01, title: 'Account Information',),
                    SettingsElement(settingColor: colors[1], onClicked: () {  }, icon: HugeIcons.strokeRoundedHourglass, title: 'Orders History',),
                  ],
                ),
                //SECTION App
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.sp,
                  children: [
                    Text("App", style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                    SizedBox(height: 16.sp,),
                    SettingsElement(settingColor: colors[2], onClicked: () {  }, icon: HugeIcons.strokeRoundedLanguageCircle, title: 'Language', subtitle: "English",),
                  ],
                ),
                //SECTION Support
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.sp,
                  children: [
                    Text("Support", style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                    SizedBox(height: 16.sp,),
                    SettingsElement(settingColor: colors[3], onClicked: () {  }, icon: HugeIcons.strokeRoundedHelpCircle, title: 'Help Center',),
                    SettingsElement(settingColor: colors[4], onClicked: () {  }, icon: HugeIcons.strokeRoundedMail01, title: 'Contact Us',),
                    SettingsElement(settingColor: colors[5], onClicked: () {  }, icon: HugeIcons.strokeRoundedAsteroid02, title: 'Rate Our App',),
                  ],
                ),
                //SECTION Legal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.sp,
                  children: [
                    Text("Legal", style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: tertiaryColor)),
                    SizedBox(height: 16.sp,),
                    SettingsElement(settingColor: colors[6], onClicked: () {  }, icon: HugeIcons.strokeRoundedShield01, title: 'Privacy Policy',),
                    SettingsElement(settingColor: colors[7], onClicked: () {  }, icon: HugeIcons.strokeRoundedLegalDocument01, title: 'Terms of Service',),
                  ],
                ),
                SettingsElement(settingColor: Colors.red, onClicked: () {  }, icon: HugeIcons.strokeRoundedLogout03, title: 'Sign Out',),
              ],
            ),
          ),
          )
        ),
    );
  }

}