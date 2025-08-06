import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatsView extends ConsumerWidget {
  @override
  final ordersProvider = StateProvider<List<int>>((ref) => [0, 0, 0, 0, 0, 0, 0]);
  var startingDayOfWeek = DateTime.now().subtract(Duration(days: 6));
  Widget build(BuildContext context, WidgetRef ref) {
    
    int totalIncome = 0;
    

    
    final supabase = Supabase.instance.client;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: StreamBuilder(
            stream: supabase.from("orders")
            .stream(primaryKey: ['id'])
            .eq('restaurant_id', ref.watch(userDocumentsProvider)['id'])
            .order("delivery_at", ascending: true)
            .asBroadcastStream(), 
            builder: (context, snapshot){
              if(snapshot.hasError){
                //TODO add error message
                return Text("Error");
              }else if(snapshot.data != null && snapshot.data!.isEmpty){
                //TODO add emptyness text here
                return Text("Empty");
              }else if(snapshot.data != null && snapshot.data!.isNotEmpty){
                
                
                final completedOrders = snapshot.data!.where((item) => item['validated'] == true && DateTime.parse(item['delivery_at']).isBefore(DateTime.now()));
                //SECTION Counting total income
                for (var order in completedOrders) {
                  for (var item in order['items']) {
                    totalIncome += item['price per one']* item['quantity'] as int;
                  }
                  //SECTION Counting weekly orders
                  if(DateTime.parse(order['delivery_at']).isAtSameMomentAs(startingDayOfWeek) || DateTime.parse(order['delivery_at']).isAfter(startingDayOfWeek)){
                    //print(DateTime.parse(order['delivery_at']).day);
                    for (var i = 0; i < 7; i++){
                      if(DateTime.parse(order['delivery_at']).day == startingDayOfWeek.day){
                        ref.read(ordersProvider.notifier).state[i] = ref.watch(ordersProvider)[i] + 1;
                      }else{
                        startingDayOfWeek = startingDayOfWeek.add(Duration(days: 1));
                        print(startingDayOfWeek);
                      }
                    }
                  }
                  
                }
                 
                print(ref.watch(ordersProvider));
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Statistics", style: Theme.of(context).textTheme.headlineLarge),
                    SizedBox(height: 16.sp),
                    // Wrap the rest in Expanded to take remaining height
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: (100.w - 16.sp * 3) / 2,
                                height: (100.w - 16.sp * 3) / 2,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.sp),
                                  boxShadow: [dropShadow],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: (100.w - 16.sp * 3) / 6,
                                      child: Padding(
                                        padding: EdgeInsets.all(16.sp),
                                        child: Text("Total orders", style: Theme.of(context).textTheme.bodySmall),
                                      ),
                                    ),
                                    SizedBox(
                                      height: (100.w - 16.sp * 3) / 6,
                                      child: Center(
                                        child: Text("${completedOrders.length}", style: Theme.of(context).textTheme.headlineLarge),
                                      ),
                                    ),
                                    SizedBox(height: (100.w - 16.sp * 3) / 6),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.sp),
                              Container(
                                width: (100.w - 16.sp * 3) / 2,
                                height: (100.w - 16.sp * 3) / 2,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.sp),
                                  boxShadow: [dropShadow],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: (100.w - 16.sp * 3) / 6,
                                      child: Padding(
                                        padding: EdgeInsets.all(16.sp),
                                        child: Text("Refused orders", style: Theme.of(context).textTheme.bodySmall),
                                      ),
                                    ),
                                    SizedBox(
                                      height: (100.w - 16.sp * 3) / 6,
                                      child: Center(
                                        child: Text("192", style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.red)),
                                      ),
                                    ),
                                    SizedBox(height: (100.w - 16.sp * 3) / 6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.sp),
                          Container(
                            width: 100.w,
                            height: (100.w - 16.sp * 3) / 2,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.sp),
                              boxShadow: [dropShadow],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: (100.w - 16.sp * 3) / 6,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.sp),
                                    child: Text("Total income", style: Theme.of(context).textTheme.bodySmall),
                                  ),
                                ),
                                SizedBox(
                                  height: (100.w - 16.sp * 3) / 6,
                                  child: Center(
                                    child: Text("$totalIncome DA", style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.green)),
                                  ),
                                ),
                                SizedBox(height: (100.w - 16.sp * 3) / 6),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.sp),
                          // This container should take all remaining space
                          Expanded(
                            child: Container(
                              width: 100.w,
                              padding: EdgeInsets.symmetric(vertical: 16.sp),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.sp),
                                boxShadow: [dropShadow],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.sp),
                                    child: Text("Weekly orders", style: Theme.of(context).textTheme.bodySmall),
                                  ),
                                  SizedBox(height: 16.sp),
                                  // This part expands to fill remaining height
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: List.generate(7, (index) {
                                          return Container(
                                            alignment: Alignment.center,
                                            width: (100.w - 16.sp * 6) / 7,
                                            height: ref.watch(ordersProvider)[index] > 6 ? 48.sp : 12.sp * ref.watch(ordersProvider)[index],
                                            decoration: BoxDecoration(
                                              color: index != ref.watch(ordersProvider).length - 1
                                                  ? secondaryColor.withOpacity(0.8)
                                                  : secondaryColor,
                                              borderRadius: BorderRadius.circular(8.sp),
                                            ),
                                            child: ref.watch(ordersProvider)[index] >= 4? Text("${ref.watch(ordersProvider)[index]}", 
                                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),) 
                                            : SizedBox.shrink(),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }else {
                return LoadingSpinner();
              }
            }
          )
        ),
      ),
    );
  }
}
