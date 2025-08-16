import 'package:dinney_restaurant/pages/settings/settings_view.dart';
import 'package:dinney_restaurant/services/functions/background_service.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:dinney_restaurant/widgets/order_column.dart';
import 'package:dinney_restaurant/widgets/order_container.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomeView extends ConsumerWidget{
  final horizontalOrder = StateProvider<bool>((ref)=> false);
  final backgroundServiceProvider = Provider<MyBackgroundService>((ref) {
    return MyBackgroundService(ref);
  });
  HomeView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var id = supabase.auth.currentUser!.id;
    ref.read(backgroundServiceProvider).startService(tableName: 'restaurants', id: id);
    final List<GlobalKey<BlurryContainerState>> blurryKeys = [
        GlobalKey<BlurryContainerState>(),
        GlobalKey<BlurryContainerState>()];
    print(id);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: ref.watch(userDocumentsProvider).isNotEmpty? SingleChildScrollView(
        child:  SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              //TODO make a beautiful emptiness message
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.sp,
              children: [
                // Header
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
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsView()));
                            },
                            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings05, color: tertiaryColor.withOpacity(0.5)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                // Awaiting Orders
                  StreamBuilder(
                    stream: supabase
                    .from('orders')
                    .stream(primaryKey: ['id'])
                    .eq('restaurant_id', ref.watch(userDocumentsProvider)['id'])
                    .asBroadcastStream(),
                    builder: (context, snapshot){
                      if(snapshot.hasError){
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }else if(snapshot.data == null || snapshot.data!.isEmpty){
                        return Center(child: Text("No orders found"));
                      }else{
                        if(snapshot.data!.length >4){
                          ref.read(horizontalOrder.notifier).state = true;
                        }
                        // filtering to get unresponded orders first
                        final unrespondedOrders = snapshot.data!.where(
                          (item) => item['awaiting'] == true && item['validated'] == false && item['suggested'] == false && DateTime.parse(item['delivery_at']).isAfter(DateTime.now())).toList();

                        // filtering to get confirmed orders
                        final confirmedOrders = snapshot.data!.where(
                          (item) => item['validated'] == true && DateTime.parse(item['delivery_at']).isAfter(DateTime.now())).toList();
                        // this two lists are used to count the number of CONFIRMED orders at table and to pick up
                        final atTableOrders = confirmedOrders.where((item) => item['at_table'] == true).toList();
                        final toPickUpOrders = confirmedOrders.where((item) => item['at_table'] == false).toList();
                        
                        final numAtTable = atTableOrders.length;
                        final numToPickUp = toPickUpOrders.length;
                        print("Number of orders at table: $numAtTable and to pick up: $numToPickUp");
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16.sp,
                          children: [
                            //Responding to orders
                            //TODO make a beautiful emptiness message
                            if(unrespondedOrders.isNotEmpty) Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Arriving Orders", style: Theme.of(context).textTheme.headlineLarge,),
                                AnimatedRotation(
                                  duration: Duration(milliseconds: 300),
                                  turns: ref.watch(horizontalOrder)? 0.0 : 0.5,
                                  child: IconButton(
                                    onPressed: (){
                                      ref.read(horizontalOrder.notifier).state = !ref.watch(horizontalOrder);
                                    }, 
                                    icon: HugeIcon(icon: HugeIcons.strokeRoundedRotateRight02, color: tertiaryColor)
                                  ),
                                )
                              ],
                            ),
                            if(unrespondedOrders.isNotEmpty) ref.watch(horizontalOrder)? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16.sp,
                                children: List.generate(unrespondedOrders.length, (index){
                                  return OrderContainer(order: unrespondedOrders[index]);
                                }),
                              ),
                            ) : Container(
                              width: 100.w,
                              padding: EdgeInsets.all(16.sp),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.sp),
                                boxShadow: [dropShadow]
                              ),
                              child: Column(
                                children: List.generate(unrespondedOrders.length, (index){
                                  return OrderColumn(order: unrespondedOrders[index], last: unrespondedOrders.length == index + 1);
                                }),
                              ),
                            ),
                            Text("Confirmed Orders", style: Theme.of(context).textTheme.headlineLarge,),
                            // Completed Orders
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 16.sp,
                              children: [
                                InkWell(
                                  //SECTION At Table
                                  onTap: (){
                                    if(numAtTable > 0){
                                      showDialog(
                                        context: context, 
                                        builder: (context){
                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: IntrinsicWidth(
                                              stepWidth: 100.w,
                                              child: IntrinsicHeight(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.sp),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      spacing: 16.sp,
                                                      children: List.generate(atTableOrders.length, (index){
                                                        int numOrders = 0;
                                                        int totalPrice = 0;
                                                        final DateTime timestamp = DateTime.parse(atTableOrders[index]['delivery_at']);
                                                        for (var item in atTableOrders[index]['items']) {
                                                          totalPrice += item['price per one']* item['quantity'] as int;
                                                          numOrders += item['quantity'] as int;
                                                        }
                                                        print(numOrders);
                                                        return InkWell(
                                                          onTap: (){
                                                            showDialog(context: context, builder: (context){
                                                              return Dialog(
                                                                backgroundColor: Colors.white,
                                                                child: IntrinsicWidth(
                                                                  stepWidth: 100.w,
                                                                  child: IntrinsicHeight(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.all(16.sp),
                                                                      child: Column(
                                                                        spacing: 16.sp,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              //TODO add a total price text
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text('${atTableOrders[index]['client_name'].toString().length > 15 
                                                                                    ? '${atTableOrders[index]['client_name'].toString().substring(0, 15)}...'
                                                                                    : atTableOrders[index]['client_name']}', 
                                                                                    style: Theme.of(context).textTheme.headlineMedium!),
                                                                                  Text(atTableOrders[index]["at_table"]? "At Table" : "To Pick Up", 
                                                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                                                                ],
                                                                              ),
                                                                              Text(DateFormat.Hm().format(timestamp), 
                                                                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                                                            ],
                                                                          ),
                                                                          Container(
                                                                            width: 100.w,
                                                                            padding: EdgeInsets.all(16.sp),
                                                                            decoration: BoxDecoration(
                                                                              color: backgroundColor,
                                                                              borderRadius: BorderRadius.circular(16.sp)
                                                                            ),
                                                                            child: Column(
                                                                              children: List.generate(atTableOrders[index]['items'].length, (itemIndex){
                                                                            return Row(
                                                                              children: [
                                                                                Text("${atTableOrders[index]['items'][itemIndex]['category']} ${atTableOrders[index]['items'][itemIndex]['name']} ${atTableOrders[index]['items'][itemIndex]['size'] ?? ""} x ${atTableOrders[index]['items'][itemIndex]['quantity']}", style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),),
                                                                                Text(" ${atTableOrders[index]['items'][itemIndex]['note']?? ""}", style: Theme.of(context).textTheme.bodySmall,)
                                                                              ],
                                                                            );
                                                                          }),
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text("Total Price", style: Theme.of(context).textTheme.headlineSmall),
                                                                              Text("$totalPrice DA", style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),),
                                                                            ],
                                                                          ),
                                                                          Center(
                                                                            child: TextButton(
                                                                              style: Theme.of(context).textButtonTheme.style?.copyWith(
                                                                                foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                                                              ),
                                                                              onPressed: (){
                                                                                showDialog(
                                                                                  context: context, 
                                                                                  builder: (context){
                                                                                    return AlertDialog(
                                                                                  title: Text("Cancel Order"),
                                                                                  content: Text("Are you sure you want to cancel this order?"),
                                                                                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  actions: [
                                                                                    TextButton(
                                                                                      style: Theme.of(context).textButtonTheme.style?.copyWith(
                                                                                        foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                                                                      ),
                                                                                      onPressed: () async {
                                                                                        await supabase.from('orders')
                                                                                        .delete()
                                                                                        .eq('id', atTableOrders[index]['id']);
                                                                                        Navigator.of(context).pop();
                                                                                        Navigator.of(context).pop();
                                                                                        Navigator.of(context).pop();
                                                                                      }, 
                                                                                      child: Text("Yes, Cancel Order")
                                                                                    ),
                                                                                    TextButton(
                                                                                      style: Theme.of(context).textButtonTheme.style?.copyWith(
                                                                                        foregroundColor: WidgetStateProperty.all<Color>(tertiaryColor),
                                                                                      ),
                                                                                      onPressed: () => Navigator.of(context).pop(), 
                                                                                      child: Text("No")
                                                                                    ),
                                                                                    
                                                                                  ],
                                                                                );
                                                                                  }
                                                                                );
                                                                                
                                                                                                                      
                                                                              }, 
                                                                              child: Text("Cancel Order")
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          },
                                                          borderRadius: BorderRadius.circular(24.sp),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(8.sp),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          '${atTableOrders[index]['client_name'].toString().length > 15 
                                                                            ? '${atTableOrders[index]['client_name'].toString().substring(0, 15)}...'
                                                                            : atTableOrders[index]['client_name']}',
                                                                          style: Theme.of(context).textTheme.headlineMedium,
                                                                        ),
                                                                        Row(
                                                                          spacing: 8.sp,
                                                                          children: [
                                                                            Text(DateFormat.Hm().format(timestamp), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                                                            Text(atTableOrders[index]["at_table"]? "• At Table" : "• To Pick Up", 
                                                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.end,
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
                                                                if(index != atTableOrders.length - 1) Divider(
                                                                  color: tertiaryColor,
                                                                  thickness: 1.sp,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      );
                                    }else{
                                      blurryKeys[0].currentState?.bounce();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(24.sp),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.all(16.sp),
                                    width: (100.w - 16.sp * 3) / 2,
                                    height: 70.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24.sp),
                                      boxShadow: [dropShadow],
                                      image: DecorationImage(image: AssetImage("assets/images/at_table.png"), fit: BoxFit.cover)
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("At Table", 
                                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                        BlurryContainer(
                                          key: blurryKeys[0],
                                          width: 35.w,
                                          height: 13.w,
                                          child: Text("$numAtTable order" + (numAtTable != 1? "s" : ""), 
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    if(numToPickUp > 0){
                                      showDialog(
                                        context: context, 
                                        builder: (context){
                                          return Dialog(
                                            child: IntrinsicWidth(
                                              stepWidth: 100.w,
                                              child: IntrinsicHeight(
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.sp),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      spacing: 16.sp,
                                                      children: List.generate(toPickUpOrders.length, (index){
                                                        int numOrders = 0;
                                                        int totalPrice = 0;
                                                        final DateTime timestamp = DateTime.parse(toPickUpOrders[index]['delivery_at']);
                                                        for (var item in toPickUpOrders[index]['items']) {
                                                          totalPrice += item['price per one']* item['quantity'] as int;
                                                          numOrders += item['quantity'] as int;
                                                        }
                                                        print(numOrders);
                                                        return InkWell(
                                                          onTap: (){
                                                            showDialog(context: context, builder: (context){
                                                              return Dialog(
                                                                child: IntrinsicWidth(
                                                                  stepWidth: 100.w,
                                                                  child: IntrinsicHeight(
                                                                    child: Padding(
                                                                      padding: EdgeInsets.all(16.sp),
                                                                      child: Column(
                                                                        spacing: 16.sp,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              //TODO add a total price text
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text('${toPickUpOrders[index]['client_name'].toString().length > 15 
                                                                                    ? '${toPickUpOrders[index]['client_name'].toString().substring(0, 15)}...'
                                                                                    : toPickUpOrders[index]['client_name']}', 
                                                                                    style: Theme.of(context).textTheme.headlineMedium),
                                                                                  Text(toPickUpOrders[index]["at_table"]? "At Table" : "To Pick Up", 
                                                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                                                                ],
                                                                              ),
                                                                              Text(DateFormat.Hm().format(timestamp), 
                                                                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                                                            ],
                                                                          ),
                                                                          Container(
                                                                              width: 100.w,
                                                                              padding: EdgeInsets.all(16.sp),
                                                                              decoration: BoxDecoration(
                                                                                color: backgroundColor,
                                                                                borderRadius: BorderRadius.circular(16.sp)
                                                                              ),
                                                                              child: Column(
                                                                                children: List.generate(toPickUpOrders[index]['items'].length, (itemIndex){
                                                                              return Row(
                                                                                children: [
                                                                                  Text("${toPickUpOrders[index]['items'][itemIndex]['category']} ${toPickUpOrders[index]['items'][itemIndex]['name']} ${toPickUpOrders[index]['items'][itemIndex]['size'] ?? ""} x ${toPickUpOrders[index]['items'][itemIndex]['quantity']}", style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),),
                                                                                  Text(" ${toPickUpOrders[index]['items'][itemIndex]['note']?? ""}", style: Theme.of(context).textTheme.bodySmall,)
                                                                                ],
                                                                              );
                                                                            }),
                                                                              ),
                                                                            ),
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text("Total Price", style: Theme.of(context).textTheme.headlineSmall),
                                                                              Text("$totalPrice DA", style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),),
                                                                            ],
                                                                          ),
                                                                          Center(
                                                                            child: TextButton(
                                                                              style: Theme.of(context).textButtonTheme.style?.copyWith(
                                                                                foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                                                              ),
                                                                              onPressed: (){
                                                                                showDialog(
                                                                                  context: context, 
                                                                                  builder: (context){
                                                                                    return AlertDialog(
                                                                                      title: Text("Cancel Order"),
                                                                                      content: Text("Are you sure you want to cancel this order?"),
                                                                                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                                                                                      actions: [
                                                                                        TextButton(
                                                                                          style: Theme.of(context).textButtonTheme.style?.copyWith(
                                                                                            foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                                                                                          ),
                                                                                          onPressed: () async {
                                                                                            await supabase.from('orders')
                                                                                            .delete()
                                                                                            .eq('id', toPickUpOrders[index]['id']);
                                                                                            Navigator.of(context).pop();
                                                                                            Navigator.of(context).pop();
                                                                                            Navigator.of(context).pop();
                                                                                          }, 
                                                                                          child: Text("Yes, Cancel Order")
                                                                                        ),
                                                                                        TextButton(
                                                                                          style: Theme.of(context).textButtonTheme.style?.copyWith(
                                                                                            foregroundColor: WidgetStateProperty.all<Color>(tertiaryColor),
                                                                                          ),
                                                                                          onPressed: () => Navigator.of(context).pop(), 
                                                                                          child: Text("No")
                                                                                        ),
                                                                                        
                                                                                      ],
                                                                                    );
                                                                                  }
                                                                                );
                                                                                //TODO First we inform the client with a push notification
                                                                                //TODO Then we remove the row from the database
                                                
                                                                              }, 
                                                                              child: Text("Cancel Order")
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          },
                                                          borderRadius: BorderRadius.circular(24.sp),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(8.sp),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          '${toPickUpOrders[index]['client_name'].toString().length > 15 
                                                                            ? '${toPickUpOrders[index]['client_name'].toString().substring(0, 15)}...'
                                                                            : toPickUpOrders[index]['client_name']}',
                                                                          style: Theme.of(context).textTheme.headlineMedium,
                                                                        ),
                                                                        Row(
                                                                          spacing: 8.sp,
                                                                          children: [
                                                                            Text(DateFormat.Hm().format(timestamp), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                                                            Text(toPickUpOrders[index]["at_table"]? "• At Table" : "• To Pick Up", 
                                                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.end,
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
                                                                if(index != toPickUpOrders.length - 1) Divider(
                                                                  color: tertiaryColor,
                                                                  thickness: 1.sp,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      );
                                    }else{
                                      blurryKeys[1].currentState?.bounce();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(24.sp),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.all(16.sp),
                                    width: (100.w - 16.sp * 3) / 2,
                                    height: 70.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24.sp),
                                      boxShadow: [dropShadow],
                                      image: DecorationImage(image: AssetImage("assets/images/to_pick_up.png"), fit: BoxFit.cover)
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("To Pick Up", 
                                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                        BlurryContainer(
                                          key: blurryKeys[1],
                                          width: 35.w,
                                          height: 13.w,
                                          child: Text("$numToPickUp order${numToPickUp != 1? "s" : ""}", 
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      }
                    }
                  )
              ],
            ),
          ),
        ),
      ) : Center(child: LoadingSpinner()),
    );
  }
}

class suggestionDialog extends ConsumerWidget{
  final int id;
  final String opening;
  final String closing;
  List<String> suggestions = ["At Table", "To Pick Up"];
  final suggestionProvider = StateProvider<List<bool>>((ref) => [true, false]);
  final suggestionButton = StateProvider<bool>((ref) => false);
  int selectedHour = 0;
  int selectedMinute = 0;
  TimeOfDay? parseTimeString(String timeString) {
    try {
      // Split the time string by ':'
      final components = timeString.split(':');
      if (components.length < 2 || components.length > 3) {
        return null; // Invalid format
      }

      // Parse hour and minute
      final hour = int.tryParse(components[0]);
      final minute = int.tryParse(components[1]);

      // Validate parsed values
      if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null; // Invalid hour or minute
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null; // Return null on any parsing error
    }
  }

  suggestionDialog(this.opening, this.closing, {super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var openingTime = parseTimeString(opening);
    final closingTime = parseTimeString(closing);
    if(openingTime!.isBefore(TimeOfDay.now())){
      openingTime = TimeOfDay.now();
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.sp),
      ),
      child: IntrinsicWidth(
        stepWidth: 100.w,
        child: IntrinsicHeight(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              spacing: 16.sp,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  spacing: 16.sp,
                  children: List.generate(2, (index){
                    return OutlinedButton(
                      onPressed: (){
                        if(index == 0){
                          ref.read(suggestionProvider.notifier).state = [true, false];
                        }else{
                          ref.read(suggestionProvider.notifier).state = [false, true];
                        }
                      },
                      style: outlinedBeige.copyWith(
                        fixedSize: WidgetStateProperty.all<Size>(Size(33.w, 4.h)),
                        backgroundColor: WidgetStateProperty.all<Color>(ref.watch(suggestionProvider)[index]? secondaryColor : Colors.transparent),
                      ), 
                      child: Text(suggestions[index], 
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ref.watch(suggestionProvider)[index]? Colors.white : tertiaryColor,
                          fontWeight: ref.watch(suggestionProvider)[index]? FontWeight.bold : FontWeight.normal
                        ))
                      );
                  }),
                ),
                SizedBox(
                  height: 25.h, // Responsive height using Sizer
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Prevent unnecessary space
                    children: [
                      // Hour picker
                      SizedBox(
                        width: 20.w, // Responsive width
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 5.h, // Responsive item height
                          diameterRatio: 1.5, // Controls the wheel curvature
                          magnification: 1.3, // Magnify selected item
                          useMagnifier: true, // Enable magnification effect
                          onSelectedItemChanged: (index) {
                            selectedHour = openingTime!.hour + index;
                            final selectedTime = parseTimeString("$selectedHour:$selectedMinute");
                            if(selectedTime!.isAfter(openingTime) && selectedTime.isBefore(closingTime)){
                              ref.read(suggestionButton.notifier).state = true;
                            }else {
                              ref.read(suggestionButton.notifier).state = false;
                            }
                            //hour =  + index;
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              var hour = openingTime!.hour + index;
                              return Center(
                                child: Text(
                                  hour.toString().padLeft(2, '0'),
                                  style: Theme.of(context).textTheme.bodyLarge
                                ),
                              );
                            },
                            childCount: (closingTime!.hour - openingTime.hour) + 1, // 9:00 to 17:00
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text(
                          ':',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white)
                        ),
                      ),
                      // Minute picker
                      SizedBox(
                        width: 20.w, // Responsive width
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 5.h, // Responsive item height
                          diameterRatio: 1.5,
                          magnification: 1.3, // Magnify selected item
                          useMagnifier: true,
                          onSelectedItemChanged: (index) { 
                            print('Minute: $index');
                            selectedMinute = index;
                            final selectedTime = parseTimeString("$selectedHour:$selectedMinute:00");
                            if(selectedTime!.isAfter(openingTime!) && selectedTime.isBefore(closingTime!)){
                              ref.read(suggestionButton.notifier).state = true;
                            }else {
                              ref.read(suggestionButton.notifier).state = false;
                            }
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: Theme.of(context).textTheme.bodyLarge!
                                ),
                              );
                            },
                            childCount: 60, // 00 to 59
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if(ref.watch(suggestionButton)) ElevatedButton(
                  onPressed: () async{
                    // TODO send notification to user;
                    await supabase.from('orders').update(({
                      'suggested' : true,
                      'awaiting' : false,
                      'at_table' : ref.watch(suggestionProvider)[0],
                      'delivery_at' : DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        selectedHour,
                        selectedMinute
                      ).toIso8601String()
                    })).eq('id', id);
                    Navigator.pop(context);
                    if(Navigator.canPop(context)){
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Suggest")
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
