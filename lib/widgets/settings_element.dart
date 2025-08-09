import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sizer/sizer.dart';

class SettingsElement extends StatelessWidget {
  final IconData icon;
  final String title;
  final MaterialColor settingColor;
  final Function() onClicked;
  String? subtitle;
  SettingsElement({super.key, required this.settingColor, required this.onClicked, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Column(
        spacing: 8.sp,
        children: [
          InkWell(
            onTap: onClicked,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
              children: [
                Row(
                  spacing: 16.sp,
                  children: [
                    Container(
                      width: 24.sp,
                      height: 24.sp,
                      decoration: BoxDecoration(
                        color: settingColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.sp)
                      ),
                      child: HugeIcon(icon: icon, color: settingColor),
                    ),
                    subtitle == null? Text(title, style: Theme.of(context).textTheme.titleMedium,) : 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium,),
                        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: tertiaryColor),),
                      ],
                      ),
                  ],
                ),
                HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: tertiaryColor)
              ],
            ),
          ),
          Divider(color: Colors.white,)
        ],
      ),
    );
  }
}