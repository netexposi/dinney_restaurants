import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomeView extends ConsumerWidget{
  final seeMoreOrders = StateProvider<bool>((ref) => false);
  final manyOrders = StateProvider<bool>((ref) => false);
  
  HomeView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var id = supabase.auth.currentUser?.id;
    print(id);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                            onPressed: (){},
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
                        if(snapshot.data!.length >=4){
                          ref.read(manyOrders.notifier).state = true;
                        }
                        // filtering to get unresponded orders first
                        final unrespondedOrders = snapshot.data!.where(
                          (item) => item['awaiting'] == true && item['validated'] == false && item['suggested'] == false && DateTime.parse(item['delivery_at']).isAfter(DateTime.now())).toList();

                        // filtering to get confirmed orders
                        final confirmedOrders = snapshot.data!.where(
                          (item) => item['validated'] == true && DateTime.parse(item['delivery_at']).isAfter(DateTime.now())).toList();
                        
                        final numAtTable = confirmedOrders.where((item) => item['at_table'] == true).length;
                        final numToPickUp = confirmedOrders.where((item) => item['at_table'] == false).length;
                        print("Number of orders at table: $numAtTable and to pick up: $numToPickUp");
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16.sp,
                          children: [
                            //Responding to orders
                            Text("Arriving Orders", style: Theme.of(context).textTheme.headlineLarge,),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16.sp,
                                children: List.generate(unrespondedOrders.length, (index){
                                  return Container(
                                    padding: EdgeInsets.all(16.sp),
                                    width: 70.w,
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${unrespondedOrders[index]['client_name'].toString().length > 15 
                                                    ? unrespondedOrders[index]['client_name'].toString().substring(0, 15) + '...'
                                                    : unrespondedOrders[index]['client_name']}',
                                                  style: Theme.of(context).textTheme.headlineMedium,
                                                ),
                                                Text(unrespondedOrders[index]['at_table']? "At Table" : "To Pick Up", 
                                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                              ],
                                            ),
                                            Text(DateFormat.Hm().format(DateTime.parse(unrespondedOrders[index]['delivery_at'])), 
                                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                                          ],
                                        ),
                                        //Text("Items:", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        ...List.generate(unrespondedOrders[index]['items'].length, (itemIndex){
                                          return Text("${unrespondedOrders[index]['items'][itemIndex]['category']} ${unrespondedOrders[index]['items'][itemIndex]['name']} ${unrespondedOrders[index]['items'][itemIndex]['size'] ?? ""} x ${unrespondedOrders[index]['items'][itemIndex]['quantity']}");
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
                                                    }).eq('id', unrespondedOrders[index]['id']);
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
                                                    .eq('id', unrespondedOrders[index]['id']);
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
                                                    return suggestionDialog();
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
                                }),
                              ),
                            ),
                            //awaiting orders
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("Awaiting Orders", style: Theme.of(context).textTheme.headlineLarge,),
                            //     if(ref.watch(manyOrders)) TextButton(
                            //       onPressed: (){
                            //         ref.read(seeMoreOrders.notifier).state = !ref.read(seeMoreOrders);
                            //       }, 
                            //       child: Text(ref.watch(seeMoreOrders)? "See less" : "See more")
                            //       )
                            //   ],
                            // ),
                            // AnimatedContainer(
                            //   width: 100.w,
                            //   padding: EdgeInsets.all(16.sp),
                            //   //height: ref.watch(seeMoreOrders)? 80.h : 40.h,
                            //   duration: Duration(milliseconds: 300),
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(24.sp),
                            //     boxShadow: [dropShadow],),
                            //   child: Column(
                            //     children: List.generate(
                            //       // ref.watch(manyOrders) && ref.watch(seeMoreOrders)? snapshot.data!.length : 
                            //       // ref.watch(manyOrders) && !ref.watch(seeMoreOrders)? 4 : snapshot.data!.length, 
                            //       1,
                            //       (index){
                            //       int numOrders = 0;
                            //       late double totalPrice;
                            //       final DateTime timestamp = DateTime.parse(snapshot.data![index]['delivery_at']);
                            //       for (var item in snapshot.data![index]['items']) {
                            //         numOrders += int.parse(item['quantity']);
                            //       }
                            //       print(numOrders);
                            //       return Column(
                            //         children: [
                            //           Row(
                            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //             children: [
                            //               Column(
                            //                 crossAxisAlignment: CrossAxisAlignment.start,
                            //                 children: [
                            //                   Text('${snapshot.data![index]['client_name']}', style: Theme.of(context).textTheme.headlineMedium,),
                            //                   Text(DateFormat.Hm().format(timestamp), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tertiaryColor.withOpacity(0.5))),
                            //                 ],
                            //               ),
                            //               Container(
                            //                 alignment: Alignment.center,
                            //                 width: 30.w,
                            //                 height: 8.w,
                            //                 decoration: BoxDecoration(
                            //                   color: tertiaryColor.withOpacity(0.5),
                            //                   borderRadius: BorderRadius.circular(24.sp),
                            //                 ),
                            //                 child: Row(
                            //                   mainAxisAlignment: MainAxisAlignment.center,
                            //                   children: [
                            //                     Text("$numOrders orders", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                            //                     HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white, size: 16.sp)
                            //                   ],
                            //                 )
                            //               )
                            //             ],
                            //           ),
                            //           if(index != snapshot.data!.length - 1) Divider(
                            //             color: tertiaryColor,
                            //             thickness: 1.sp,
                            //           ),
                            //         ],
                            //       );
                            //     })
                            //   ),
                            // ),
                            Text("Confirmed Orders", style: Theme.of(context).textTheme.headlineLarge,),
                            // Completed Orders
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 16.sp,
                              children: [
                                Container(
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
                                        width: 35.w,
                                        height: 13.w,
                                        child: Text("$numAtTable order" + (numAtTable != 1? "s" : ""), 
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
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
                                        width: 35.w,
                                        height: 13.w,
                                        child: Text("$numToPickUp order" + (numToPickUp != 1? "s" : ""), 
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
                                        ),
                                    ],
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
      ),
    );
  }
}

class suggestionDialog extends ConsumerWidget{
  List<String> suggestions = ["At Table", "To Pick Up"];
  final suggestionProvider = StateProvider<List<bool>>((ref) => [true, false]);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.sp),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          spacing: 16.sp,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Suggest a change", style: Theme.of(context).textTheme.headlineMedium,),
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
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour picker
                  SizedBox(
                    width: 60,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      onSelectedItemChanged: (index) => print('Hour: ${9 + index}'),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Center(
                          child: Text(
                            (9 + index).toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        childCount: 9, // 9:00 to 17:00
                      ),
                    ),
                  ),
                  const Text(':', style: TextStyle(fontSize: 18)),
                  // Minute picker
                  SizedBox(
                    width: 60,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      onSelectedItemChanged: (index) => print('Minute: $index'),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        childCount: 60, // 00 to 59
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async{
                // // Suggest the change
                // await supabase.from('orders').update({
                //   'suggested': true,
                //   'awaiting': false,
                // }).eq('id', unrespondedOrders[index]['id']);
                // Navigator.pop(context);
              },
              child: Text("Suggest")
            )
          ],
        ),
      ),
    );
  }

}
