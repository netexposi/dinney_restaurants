import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Extension to normalize DateTime to start of day
extension DateTimeExtension on DateTime {
  DateTime startOfDay() {
    return DateTime(year, month, day);
  }
}

class StatsView extends ConsumerWidget {
  const StatsView({super.key}); // Add key for proper widget construction

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: StreamBuilder(
            stream: supabase
                .from("orders")
                .stream(primaryKey: ['id'])
                .eq('restaurant_id', ref.watch(userDocumentsProvider)['id'])
                .order("delivery_at", ascending: true)
                .asBroadcastStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Error");
              } else if (snapshot.data != null && snapshot.data!.isEmpty) {
                return const Text("Empty");
              } else if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                final completedOrders = snapshot.data!
                    .where((item) =>
                        item['validated'] == true &&
                        DateTime.parse(item['delivery_at'])
                            .isBefore(DateTime.now()))
                    .toList();

                //SECTION Counting total income and served items
                int servedItems = 0;
                int totalIncome = 0;
                for (var order in completedOrders) {
                  for (var item in order['items']) {
                    totalIncome += (item['price per one'] * item['quantity']) as int;
                    servedItems += item['quantity'] as int;
                  }
                }

                //SECTION Counting weekly orders
                final now = DateTime.now();
                final startOfWeek = now.subtract(const Duration(days: 6)).startOfDay();
                final ordersPerDay = List<int>.filled(7, 0); // Initialize counts
                for (var order in completedOrders) {
                  final orderDate = DateTime.parse(order['delivery_at']);
                  if (orderDate.isAfter(
                          startOfWeek.subtract(const Duration(seconds: 1))) &&
                      orderDate.isBefore(now.add(const Duration(seconds: 1)))) {
                    final dayIndex =
                        orderDate.startOfDay().difference(startOfWeek).inDays;
                    if (dayIndex >= 0 && dayIndex < 7) {
                      ordersPerDay[dayIndex]++;
                    }
                  }
                }

                // Debug print to verify counts
                // ignore: avoid_print
                print('Orders per day: $ordersPerDay');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Statistics",
                        style: Theme.of(context).textTheme.headlineLarge),
                    SizedBox(height: 16.sp),
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
                                        child: Text("Total orders",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ),
                                    ),
                                    SizedBox(
                                      height: (100.w - 16.sp * 3) / 6,
                                      child: Center(
                                        child: Text("${completedOrders.length}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge),
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
                                        child: Text("Served items",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ),
                                    ),
                                    SizedBox(
                                      height: (100.w - 16.sp * 3) / 6,
                                      child: Center(
                                        child: Text("$servedItems",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge),
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
                                    child: Text("Total income",
                                        style:
                                            Theme.of(context).textTheme.bodySmall),
                                  ),
                                ),
                                SizedBox(
                                  height: (100.w - 16.sp * 3) / 6,
                                  child: Center(
                                    child: Text("$totalIncome DA",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge!
                                            .copyWith(color: Colors.green)),
                                  ),
                                ),
                                SizedBox(height: (100.w - 16.sp * 3) / 6),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.sp),
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
                                    child: Text("Weekly orders",
                                        style:
                                            Theme.of(context).textTheme.bodySmall),
                                  ),
                                  SizedBox(height: 16.sp),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16.sp),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(7, (index) {
                                          return ordersPerDay[index] >= 2
                                              ? Container(
                                                  alignment: Alignment.center,
                                                  width: (100.w - 16.sp * 6) / 7,
                                                  height: ordersPerDay[index] > 20
                                                      ? 48.sp
                                                      : 16.sp * ordersPerDay[index],
                                                  decoration: BoxDecoration(
                                                    color: index !=
                                                            ordersPerDay.length - 1
                                                        ? secondaryColor
                                                            .withOpacity(0.8)
                                                        : secondaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(8.sp),
                                                  ),
                                                  child: Text(
                                                    "${ordersPerDay[index]}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                  ),
                                                )
                                              : Text(
                                                  "${ordersPerDay[index]}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                          color: secondaryColor),
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
              } else {
                return LoadingSpinner();
              }
            },
          ),
        ),
      ),
    );
  }
}