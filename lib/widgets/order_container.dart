
import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/services/functions/community_operations.dart';
import 'package:dinney_restaurant/services/functions/string_handlings.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderContainer extends ConsumerWidget{
  final Map<String, dynamic> order;

  OrderContainer({super.key, required this.order});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    return Container(
      padding: EdgeInsets.all(16.sp),
      width: 85.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.sp),
        boxShadow: [dropShadow],
      ),
      child: Column(
        spacing: 16.sp,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium,
                  children: [
                    TextSpan(
                      text: order['client_name'].toString().length > 15
                          ? order['client_name'].toString().substring(0, 15) + '...'
                          : order['client_name'].toString(),
                    ),
                    TextSpan(text: "  "), // spacing
                    TextSpan(
                      text: "#${order['id']}",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: tertiaryColor, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Iconsax.calendar, color: tertiaryColor.withOpacity(0.5),),
                  Text(DateFormat.Hm().format(DateTime.parse(order['delivery_at'])), 
                    style: Theme.of(context).textTheme.headlineLarge),
                    Text(
                    DateFormat.MMMEd().format(DateTime.parse(order['delivery_at'])),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: tertiaryColor),
                  ),
                  Text(order['at_table']? S.of(context).reservation_at_table : S.of(context).reservation_to_go, 
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: secondaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Container(
            width: 100.w,
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20.sp)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16.sp,
              children: [
                Text(S.of(context).order, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: tertiaryColor)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16.sp,
                  children: List.generate(order['items'].length, (itemIndex){
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${order['items'][itemIndex]['quantity']} x ",
                                style: Theme.of(context).textTheme.bodyLarge
                              ),
                              TextSpan(
                                text: "${order['items'][itemIndex]['category']} ${order['items'][itemIndex]['name']} ${order['items'][itemIndex]['size'] ?? ""}",
                                style: Theme.of(context).textTheme.headlineSmall
                              ),
                            ],
                          ),
                        ),
                        if(order['items'][itemIndex]['note'] != null) Text(" • ${order['items'][itemIndex]['note']}", style: Theme.of(context).textTheme.titleSmall!.copyWith(color: tertiaryColor, fontWeight: FontWeight.normal),)
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          
          // action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // accept and reject buttons
              ref.watch(savingLoadingButton) ? LoadingSpinner() : Row(
                spacing: 16.sp,
                children: [
                  // accept
                  InkWell(
                    onTap: () async{
                      // Accept the order
                      ref.read(savingLoadingButton.notifier).state = true;
                      await supabase.from('orders').update({
                        'validated': true,
                        'awaiting': false,
                      }).eq('id', order['id']);
                      await sendNotification(
                        "${ref.watch(userDocumentsProvider)['name']}", 
                        "Restaurant has accepted your order", 
                        order['client_fcm'], 
                        image: ref.watch(userDocumentsProvider)['urls'][0]
                      );
                      //ref.read(savingLoadingButton.notifier).state = false;
                      if(context.mounted){
                        if(Navigator.canPop(context)){
                        Navigator.of(context).pop();
                      }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20.sp)
                      ),
                      child: Row(
                        spacing: 8.sp,
                        children: [
                          Text(S.of(context).accept, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          HugeIcon(icon: HugeIcons.strokeRoundedTick01, color: Colors.white, size: 16.sp),
                        ],
                      ),
                    ),

                  ),
                  // reject
                  InkWell(
                    onTap: () async{
                      ref.read(savingLoadingButton.notifier).state = true;
                      await supabase.from('orders')
                      .delete()
                      .eq('id', order['id']);
                      await supabase.from("restaurants")
                      .update({"refused_orders" : 
                        ref.watch(userDocumentsProvider)["refused_orders"] == null ? 1 : ref.watch(userDocumentsProvider)["refused_orders"] + 1
                      })
                      .eq("id", ref.watch(userDocumentsProvider)['id']);
                      await sendNotification(
                        "${ref.watch(userDocumentsProvider)['name']}", 
                        "Restaurant has refused your order", 
                        order['client_fcm'], 
                        image: ref.watch(userDocumentsProvider)['urls'][0]
                      );
                      ref.read(savingLoadingButton.notifier).state = false;
                      if(Navigator.canPop(context)){
                        Navigator.of(context).pop();
                      }

                    },
                    child: CircleAvatar(
                      radius: 20.sp,
                      backgroundColor: Colors.red,
                      child: HugeIcon(icon: HugeIcons.strokeRoundedRemoveCircle, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ],
              ),
              // suggesting button
              if(!ref.watch(savingLoadingButton)) OutlinedButton(
                style: outlinedBeige.copyWith(fixedSize: WidgetStateProperty.all<Size>(Size(35.w, 3.h))),
                onPressed: (){
                  showDialog(
                    context: context, 
                    builder: (context){
                      int dayIndex = getDayName(ref.watch(languageStateProvider));

                      print("The opening is at: ${ref.watch(userDocumentsProvider)['schedule'][dayIndex]['opening']}");
                      print("the closing is at: ${ref.watch(userDocumentsProvider)['schedule'][dayIndex]['closing']}");

                      return suggestionDialog(
                        id: order['id'], 
                        ref.watch(userDocumentsProvider)['schedule'][dayIndex]['opening'], 
                        ref.watch(userDocumentsProvider)['schedule'][dayIndex]['closing'],
                        order['client_fcm']
                      );
                    }
                  );
                  ref.read(savingLoadingButton.notifier).state = false;
                }, 
                child: Text(S.of(context).suggest)
              )
            ],
          )
        ],
      ),
    );
  }
}