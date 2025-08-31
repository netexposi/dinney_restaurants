
import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
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
      width: 100.w,
      //height: 20.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.sp),
        boxShadow: [dropShadow],
      ),
      child: Column(
        spacing: 8.sp,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order['client_name'].toString().length > 15 
                      ? order['client_name'].toString().substring(0, 15) + '...'
                      : order['client_name']}',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 20.sp),
                  ),
                  HugeIcon(icon: HugeIcons.strokeRoundedCalendar01, color: tertiaryColor)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${S.of(context).order}:", style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: tertiaryColor),),
                      Column(
                        children: List.generate(order['items'].length, (itemIndex){
                          return Column(
                            children: [
                              Text("${order['items'][itemIndex]['quantity']} x ${order['items'][itemIndex]['category']} ${order['items'][itemIndex]['name']} ${order['items'][itemIndex]['size'] ?? ""}", style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),),
                              Text(" ${order['items'][itemIndex]['note']?? ""}", style: Theme.of(context).textTheme.bodySmall,)
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(order['at_table']? S.of(context).reservation_at_table : S.of(context).reservation_to_go, 
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: secondaryColor, fontWeight: FontWeight.bold)),
                        Text(DateFormat.MMMEd().format(DateTime.parse(order['delivery_at'])), 
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tertiaryColor, fontWeight: FontWeight.bold)),
                      Text(DateFormat.Hm().format(DateTime.parse(order['delivery_at'])), 
                        style: Theme.of(context).textTheme.headlineLarge),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          // action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // accept and reject buttons
              Row(
                spacing: 16.sp,
                children: [
                  // accept
                  InkWell(
                    onTap: () async{
                      // Accept the order
                      
                      await supabase.from('orders').update({
                        'validated': true,
                        'awaiting': false,
                      }).eq('id', order['id']);
                      if(Navigator.canPop(context)){
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16.sp)
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
                      await supabase.from('orders')
                      .delete()
                      .eq('id', order['id']);
                      await supabase.from("restaurants")
                      .update({"refused_orders" : 
                        ref.watch(userDocumentsProvider)["refused_orders"] == null ? 1 : ref.watch(userDocumentsProvider)["refused_orders"] + 1
                      })
                      .eq("id", ref.watch(userDocumentsProvider)['id']);
                      if(Navigator.canPop(context)){
                        Navigator.of(context).pop();
                      }

                    },
                    child: CircleAvatar(
                      radius: 16.sp,
                      backgroundColor: Colors.red,
                      child: HugeIcon(icon: HugeIcons.strokeRoundedRemoveCircle, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ],
              ),
              // suggesting button
              OutlinedButton(
                style: outlinedBeige.copyWith(fixedSize: WidgetStateProperty.all<Size>(Size(27.w, 4.h))),
                onPressed: (){
                  showDialog(
                    context: context, 
                    builder: (context){
                      return suggestionDialog(id: order['id'], ref.watch(userDocumentsProvider)['opening'], ref.watch(userDocumentsProvider)['closing']);
                    }
                    );
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