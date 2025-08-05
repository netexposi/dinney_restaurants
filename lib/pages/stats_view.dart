import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class StatsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<int> orders = [3, 6, 5, 3, 8, 5, 8];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
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
                                  child: Text("192", style: Theme.of(context).textTheme.headlineLarge),
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
                              child: Text("192", style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.green)),
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
                                      height: orders[index] > 6 ? 48.sp : 12.sp * orders[index],
                                      decoration: BoxDecoration(
                                        color: index != orders.length - 1
                                            ? secondaryColor.withOpacity(0.8)
                                            : secondaryColor,
                                        borderRadius: BorderRadius.circular(8.sp),
                                      ),
                                      child: orders[index] >= 4? Text("${orders[index]}", 
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
          ),
        ),
      ),
    );
  }
}
