
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
      width: 80.w,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order['client_name'].toString().length > 15 
                  ? order['client_name'].toString().substring(0, 15) + '...'
                  : order['client_name']}',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),
              ),
              Column(
                children: [
                  Text(DateFormat.Hm().format(DateTime.parse(order['delivery_at'])), 
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: tertiaryColor)),
                  Text(order['at_table']? "At Table" : "To Pick Up", 
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor)),
                ],
              ),
            ],
          ),
          //Text("Items:", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          Container(
            width: 100.w,
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.sp)
            ),
            child: Column(
              children: List.generate(order['items'].length, (itemIndex){
            return Row(
              children: [
                Text("${order['items'][itemIndex]['category']} ${order['items'][itemIndex]['name']} ${order['items'][itemIndex]['size'] ?? ""} x ${order['items'][itemIndex]['quantity']}", style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),),
                Text(" ${order['items'][itemIndex]['note']?? ""}", style: Theme.of(context).textTheme.bodySmall,)
              ],
            );
          }),
            ),
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
                          Text("Accept", style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
                child: Text("Suggest")
                )
            ],
          )
        ],
      ),
    );
  }
}