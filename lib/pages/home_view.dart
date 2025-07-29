import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomeView extends ConsumerWidget{
  final tags = StateProvider<List<String>>((ref) => []);
  HomeView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var id = supabase.auth.currentUser?.id;
    print(id);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/images/logo.png", width: 20.w,),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 8.sp),
                    width: 25.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.sp),
                      color: Colors.white,
                      boxShadow: [
                        dropShadow
                      ]
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: (){}, 
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedNotification02, color: tertiaryColor.withOpacity(0.5)),
                          ),
                        IconButton(
                          onPressed: (){},
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings05, color: tertiaryColor.withOpacity(0.5)),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Awaiting Orders"),
                  TextButton(
                    onPressed: (){}, 
                    child: Text("See more")
                    )
                ],
              ),
              Text(ref.watch(userDocumentsProvider)["urls"][0])
            ],
          ),
        ),
      ),
    );
  }
}