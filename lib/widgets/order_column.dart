import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/utils/styles.dart';
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
              insetPadding: EdgeInsets.all(12.sp),
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
                  Text('${order['client_name']}', style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 20.sp)!),
                  Text(order["at_table"]? S.of(context).reservation_at_table : S.of(context).reservation_to_go, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tertiaryColor),),
                  
                ],
              ),
              HugeIcon(icon: HugeIcons.strokeRoundedNotification01, color: secondaryColor)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8.sp,
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
                        Text("$numOrders ${S.of(context).orders}", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white, size: 16.sp)
                      ],
                    )
                  ),
                  OutlinedButton(
                    style: outlinedBeige.copyWith(fixedSize: WidgetStateProperty.all<Size>(Size(20.w, 4.h))),
                    onPressed: (){
                      showDialog(
                        context: context, 
                        builder: (context){
                          return Dialog(
                            insetPadding: EdgeInsets.all(8.sp),
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
                    child: Text(S.of(context).view)
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat.MMMEd().format(timestamp)),
                  Text(DateFormat.Hm().format(timestamp), style: Theme.of(context).textTheme.headlineLarge),
                ],
              ),
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