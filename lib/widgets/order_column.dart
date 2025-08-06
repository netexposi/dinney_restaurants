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
                  child: OrderContainer(order: order)
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
                  Text(DateFormat.Hm().format(timestamp), style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: tertiaryColor)),
                  Text('${order['client_name']}', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),),
                  Text(order["at_table"]? "At Table" : "To Pick Up", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tertiaryColor),),
                  
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 30.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(24.sp),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("$numOrders orders", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white, size: 16.sp)
                      ],
                    )
                  ),
                ],
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