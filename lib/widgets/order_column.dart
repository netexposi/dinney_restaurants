import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:dinney_restaurant/widgets/order_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class OrderColumn extends ConsumerWidget{
  final Map<String, dynamic> order;
  final bool last;

  OrderColumn({super.key, required this.order, required this.last, });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int numOrders = 0;
    double totalPrice = 0.0;
    final DateTime timestamp = DateTime.parse(order['delivery_at']);
    for (var item in order['items']) {
      numOrders += item['quantity'] as int;
    }
    return InkWell(
      onTap: (){
        showDialog(
          context: context, 
          builder: (context){
            return Dialog(
              backgroundColor: Colors.transparent,
              child: IntrinsicWidth(
                stepWidth: 100.w,
                child: IntrinsicHeight(
                  child: BlurryContainer(
                  child: Padding(
                    
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                            spacing: 8.sp,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order['client_name'].toString().length > 15 
                            ? order['client_name'].toString().substring(0, 15) + '...'
                            : order['client_name']}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(order['at_table']? "At Table" : "To Pick Up", 
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                      ],
                    ),
                    Text(DateFormat.Hm().format(DateTime.parse(order['delivery_at'])), 
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                ],
                              ),
                              //Text("Items:", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ...List.generate(order['items'].length, (itemIndex){
                                return Column(
                    children: [
                      Text("${order['items'][itemIndex]['category']} ${order['items'][itemIndex]['name']} ${order['items'][itemIndex]['size'] ?? ""} x ${order['items'][itemIndex]['quantity']}", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),),
                      Text("${order['items'][itemIndex]['note']?? ""}", style: Theme.of(context).textTheme.bodySmall,)
                    ],
                                );
                              }),
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
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                            radius: 16.sp,
                            backgroundColor: Colors.green,
                            child: HugeIcon(icon: HugeIcons.strokeRoundedTick01, color: Colors.white, size: 16.sp),
                          ),
                        ),
                        // reject
                        InkWell(
                          onTap: () async{
                            await supabase.from('orders')
                            .delete()
                            .eq('id', order['id']);
                            Navigator.of(context).pop();
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
                  ),
                              ),
                ),
              ),
            );
          }
        );
      },
      borderRadius: BorderRadius.circular(24.sp),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${order['client_name']}', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),),
                  Row(
                    children: [
                      Text(DateFormat.Hm().format(timestamp), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                      Text(" • ${order["at_table"]? "At Table" : "To Pick Up"}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tertiaryColor.withOpacity(0.5)),)
                    ],
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                width: 30.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: tertiaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24.sp),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$numOrders orders", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white, size: 16.sp)
                  ],
                )
              )
            ],
          ),
          if(!last) Divider(
            color: tertiaryColor,
            thickness: 1.sp,
          ),
        ],
      ),
    );
  }
}