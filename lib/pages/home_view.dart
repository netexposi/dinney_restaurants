import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/services/functions/background_service.dart';
import 'package:dinney_restaurant/services/functions/community_operations.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:dinney_restaurant/widgets/order_column.dart';
import 'package:dinney_restaurant/widgets/order_container.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/settings_box.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class HomeView extends ConsumerWidget {
  final horizontalOrder = StateProvider<bool>((ref) => false);
  final expandSuggestedOrders = StateProvider<bool>((ref) => false);
  final backgroundServiceProvider = Provider<MyBackgroundService>((ref) {
    return MyBackgroundService(ref);
  });
  HomeView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var id = supabase.auth.currentUser!.id;
    ref
        .read(backgroundServiceProvider)
        .startService(tableName: 'restaurants', id: id);
    final List<GlobalKey<BlurryContainerState>> blurryKeys = [
      GlobalKey<BlurryContainerState>(),
      GlobalKey<BlurryContainerState>(),
    ];
    return Scaffold(
      backgroundColor: backgroundColor,
      body: ref.watch(userDocumentsProvider).isNotEmpty
          ? SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    //TODO make a beautiful emptiness message
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16.sp,
                    children: [
                      //SECTION Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/images/logo.png", height: 9.w),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 8.sp),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.sp),
                              color: Colors.white,
                              boxShadow: [dropShadow],
                            ),
                            child: SettingsBox(),
                          ),
                        ],
                      ),
                      //SECTION Orders
                      ref.watch(userDocumentsProvider)['subscription_end'] !=
                                  null &&
                              ref.watch(userDocumentsProvider)['active'] ==
                                  true &&
                              (DateTime.parse(
                                ref.watch(
                                  userDocumentsProvider,
                                )['subscription_end'],
                              )).isAfter(DateTime.now())
                          ? StreamBuilder(
                              stream: supabase
                                  .from('orders')
                                  .stream(primaryKey: ['id'])
                                  .eq(
                                    'restaurant_id',
                                    ref.watch(userDocumentsProvider)['id'],
                                  )
                                  .order("id", ascending: false)
                                  .asBroadcastStream(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  //ref.read(errorProvider.notifier).state = {"status" : false, "reason" : "error"};
                                  return Center(
                                    child: Text(
                                      "${S.of(context).error}: ${snapshot.error}",
                                    ),
                                  );
                                } else if (snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Lottie.asset(
                                          "assets/animations/order.json",
                                          width: 50.w,
                                        ),
                                        Text(
                                          S.of(context).no_orders_found,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(color: tertiaryColor),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // if(snapshot.data != null && snapshot.data!.length > 4){
                                  //   ref.read(horizontalOrder.notifier).state = true;
                                  // }
                                  // filtering to get unresponded orders first
                                  final unrespondedOrders = snapshot.data!
                                      .where(
                                        (item) =>
                                            item['awaiting'] == true &&
                                            item['validated'] == false &&
                                            item['suggested'] == false &&
                                            DateTime.parse(
                                              item['delivery_at'],
                                            ).isAfter(DateTime.now()),
                                      )
                                      .toList();
                                  // filtering to get suggested orders
                                  final suggestedOrders = snapshot.data!
                                      .where(
                                        (item) =>
                                            item['suggested'] &&
                                            item['validated'] == false &&
                                            DateTime.parse(
                                              item['delivery_at'],
                                            ).isAfter(DateTime.now()),
                                      )
                                      .toList();
                                  // filtering to get confirmed orders
                                  final confirmedOrders = snapshot.data!
                                      .where(
                                        (item) =>
                                            item['validated'] == true &&
                                            item['completed'] == false &&
                                            DateTime.parse(
                                              item['delivery_at'],
                                            ).isAfter(
                                              DateTime.now().subtract(
                                                Duration(hours: 2),
                                              ),
                                            ),
                                      )
                                      .toList();

                                  //idea this two lists are used to count the number of CONFIRMED orders at table and to pick up
                                  final atTableOrders = confirmedOrders
                                      .where((item) => item['at_table'] == true)
                                      .toList();
                                  final toPickUpOrders = confirmedOrders
                                      .where(
                                        (item) => item['at_table'] == false,
                                      )
                                      .toList();

                                  final numAtTable = atTableOrders.length;
                                  final numToPickUp = toPickUpOrders.length;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 16.sp,
                                    children: [
                                      //Responding to orders
                                      //TODO make a beautiful emptiness message
                                      if (unrespondedOrders.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              S.of(context).arriving_orders,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.headlineLarge,
                                            ),
                                            // AnimatedRotation(
                                            //   duration: Duration(milliseconds: 300),
                                            //   turns: ref.watch(horizontalOrder)? 0.0 : 0.5,
                                            //   child: IconButton(
                                            //     onPressed: (){
                                            //       ref.read(horizontalOrder.notifier).state = !ref.watch(horizontalOrder);
                                            //     },
                                            //     icon: HugeIcon(icon: HugeIcons.strokeRoundedRotateRight02, color: tertiaryColor)
                                            //   ),
                                            // )
                                          ],
                                        ),
                                      // ref.watch(horizontalOrder)? SingleChildScrollView(
                                      //   scrollDirection: Axis.horizontal,
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     spacing: 16.sp,
                                      //     children: List.generate(unrespondedOrders.length, (index){
                                      //       return OrderContainer(order: unrespondedOrders[index]);
                                      //     }),
                                      //   ),
                                      // ) :
                                      if (unrespondedOrders.isNotEmpty)
                                        Container(
                                          width: 100.w,
                                          padding: EdgeInsets.all(16.sp),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              24.sp,
                                            ),
                                            boxShadow: [dropShadow],
                                          ),
                                          child: Column(
                                            children: List.generate(
                                              unrespondedOrders.length,
                                              (index) {
                                                return OrderColumn(
                                                  order:
                                                      unrespondedOrders[index],
                                                  last:
                                                      unrespondedOrders
                                                          .length ==
                                                      index + 1,
                                                );
                                              },
                                            ),
                                          ),
                                        ),

                                      //FIXME SECTION Suggested Orders
                                      if (suggestedOrders.isNotEmpty)
                                        Text(
                                          S.of(context).suggested_orders,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineLarge,
                                        ),
                                      if (suggestedOrders.isNotEmpty)
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          width: 100.w,
                                          padding: EdgeInsets.all(16.sp),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              24.sp,
                                            ),
                                            color: Colors.white,
                                            boxShadow: [dropShadow],
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  !ref.watch(
                                                        expandSuggestedOrders,
                                                      )
                                                      ? Text(
                                                          "${suggestedOrders.length} ${suggestedOrders.length == 1 ? S.of(context).order : S.of(context).orders}",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headlineSmall,
                                                        )
                                                      : SizedBox.shrink(),
                                                  InkWell(
                                                    onTap: () {
                                                      bool oldValue = ref.watch(
                                                        expandSuggestedOrders,
                                                      );
                                                      ref
                                                              .read(
                                                                expandSuggestedOrders
                                                                    .notifier,
                                                              )
                                                              .state =
                                                          !oldValue;
                                                      print(
                                                        ref.watch(
                                                          expandSuggestedOrders,
                                                        ),
                                                      );
                                                    },
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: CircleAvatar(
                                                        radius: 16.sp,
                                                        backgroundColor:
                                                            tertiaryColor,
                                                        child: AnimatedRotation(
                                                          turns:
                                                              ref.watch(
                                                                expandSuggestedOrders,
                                                              )
                                                              ? 0.5
                                                              : 0,
                                                          duration: Duration(
                                                            milliseconds: 300,
                                                          ),
                                                          child: Icon(
                                                            Iconsax.arrow_down,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (ref.watch(
                                                expandSuggestedOrders,
                                              ))
                                                Column(
                                                  children: List.generate(suggestedOrders.length, (
                                                    index,
                                                  ) {
                                                    var numOrders = 0;
                                                    var totalPrice = 0;
                                                    for (var item
                                                        in suggestedOrders[index]['items']) {
                                                      totalPrice +=
                                                          item['price per one'] *
                                                                  item['quantity']
                                                              as int;
                                                      numOrders +=
                                                          item['quantity']
                                                              as int;
                                                    }
                                                    return Column(
                                                      children: [
                                                        ListTile(
                                                          title: Text(
                                                            "${suggestedOrders[index]['client_name']}",
                                                            style:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .headlineSmall,
                                                          ),
                                                          subtitle: Text(
                                                            DateFormat.Hm().format(
                                                              DateTime.parse(
                                                                suggestedOrders[index]['suggested_at'],
                                                              ),
                                                            ),
                                                            style:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .bodySmall,
                                                          ),
                                                          trailing: AnimatedOpacity(
                                                            opacity:
                                                                ref.watch(
                                                                  expandSuggestedOrders,
                                                                )
                                                                ? 1.0
                                                                : 0.0,
                                                            duration: Duration(
                                                              milliseconds: 300,
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    vertical:
                                                                        8.sp,
                                                                    horizontal:
                                                                        16.sp,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16.sp,
                                                                    ),
                                                                color:
                                                                    secondaryColor,
                                                              ),
                                                              child: Text(
                                                                "$numOrders ${numOrders == 1 ? S.of(context).order : S.of(context).orders}",
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .labelLarge!
                                                                    .copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        if (index !=
                                                            suggestedOrders
                                                                    .length -
                                                                1)
                                                          Divider(
                                                            height: 0.5.sp,
                                                            color: tertiaryColor
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                            indent: 16.sp,
                                                            endIndent: 16.sp,
                                                          ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                            ],
                                          ),
                                        ),

                                      //SECTION Completed Orders
                                      Text(
                                        S.of(context).confirmed_orders,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineLarge,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        spacing: 16.sp,
                                        children: [
                                          InkWell(
                                            //SECTION At Table
                                            onTap: () {
                                              if (numAtTable > 0) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      insetPadding:
                                                          EdgeInsets.all(8.sp),
                                                      child: IntrinsicWidth(
                                                        stepWidth: 100.w,
                                                        child: IntrinsicHeight(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  16.sp,
                                                                ),
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                spacing: 16.sp,
                                                                children: List.generate(
                                                                  atTableOrders
                                                                      .length,
                                                                  (index) {
                                                                    int
                                                                    numOrders =
                                                                        0;
                                                                    int
                                                                    totalPrice =
                                                                        0;
                                                                    final DateTime
                                                                    timestamp =
                                                                        DateTime.parse(
                                                                          atTableOrders[index]['delivery_at'],
                                                                        );
                                                                    for (var item
                                                                        in atTableOrders[index]['items']) {
                                                                      totalPrice +=
                                                                          item['price per one'] *
                                                                                  item['quantity']
                                                                              as int;
                                                                      numOrders +=
                                                                          item['quantity']
                                                                              as int;
                                                                    }
                                                                    print(
                                                                      numOrders,
                                                                    );
                                                                    return InkWell(
                                                                      onTap: () {
                                                                        TimeOfDay
                                                                        time = TimeOfDay(
                                                                          hour: DateTime.parse(
                                                                            atTableOrders[index]['delivery_at'],
                                                                          ).hour,
                                                                          minute: DateTime.parse(
                                                                            atTableOrders[index]['delivery_at'],
                                                                          ).minute,
                                                                        );

                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) {
                                                                                return Dialog(
                                                                                  backgroundColor: Colors.white,
                                                                                  insetPadding: EdgeInsets.all(
                                                                                    8.sp,
                                                                                  ),
                                                                                  child: IntrinsicWidth(
                                                                                    stepWidth: 100.w,
                                                                                    child: IntrinsicHeight(
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.all(
                                                                                          16.sp,
                                                                                        ),
                                                                                        child: Consumer(
                                                                                          builder:
                                                                                              (
                                                                                                context,
                                                                                                ref,
                                                                                                child,
                                                                                              ) {
                                                                                                return Column(
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
                                                                                                            Text(
                                                                                                              '${atTableOrders[index]['client_name'].toString().length > 15 ? '${atTableOrders[index]['client_name'].toString().substring(0, 15)}...' : atTableOrders[index]['client_name']}',
                                                                                                              style: Theme.of(
                                                                                                                context,
                                                                                                              ).textTheme.headlineMedium!,
                                                                                                            ),
                                                                                                            Text(
                                                                                                              atTableOrders[index]["at_table"]
                                                                                                                  ? "At Table"
                                                                                                                  : "To Pick Up",
                                                                                                              style: Theme.of(
                                                                                                                context,
                                                                                                              ).textTheme.bodyLarge,
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                        Text(
                                                                                                          DateFormat.Hm().format(
                                                                                                            timestamp,
                                                                                                          ),
                                                                                                          style: Theme.of(
                                                                                                            context,
                                                                                                          ).textTheme.headlineLarge,
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    Container(
                                                                                                      width: 100.w,
                                                                                                      padding: EdgeInsets.all(
                                                                                                        16.sp,
                                                                                                      ),
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: backgroundColor,
                                                                                                        borderRadius: BorderRadius.circular(
                                                                                                          16.sp,
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        children: List.generate(
                                                                                                          atTableOrders[index]['items'].length,
                                                                                                          (
                                                                                                            itemIndex,
                                                                                                          ) {
                                                                                                            return Row(
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  "${atTableOrders[index]['items'][itemIndex]['quantity']} - ${atTableOrders[index]['items'][itemIndex]['category']} ${atTableOrders[index]['items'][itemIndex]['name']} ${atTableOrders[index]['items'][itemIndex]['size'] ?? ""}",
                                                                                                                  style:
                                                                                                                      Theme.of(
                                                                                                                        context,
                                                                                                                      ).textTheme.bodySmall!.copyWith(
                                                                                                                        color: Colors.black,
                                                                                                                      ),
                                                                                                                ),
                                                                                                                Text(
                                                                                                                  " ${atTableOrders[index]['items'][itemIndex]['note'] ?? ""}",
                                                                                                                  style: Theme.of(
                                                                                                                    context,
                                                                                                                  ).textTheme.bodySmall,
                                                                                                                ),
                                                                                                              ],
                                                                                                            );
                                                                                                          },
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          S
                                                                                                              .of(
                                                                                                                context,
                                                                                                              )
                                                                                                              .total_price,
                                                                                                          style: Theme.of(
                                                                                                            context,
                                                                                                          ).textTheme.bodyLarge,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          "$totalPrice ${S.of(context).da}",
                                                                                                          style:
                                                                                                              Theme.of(
                                                                                                                context,
                                                                                                              ).textTheme.headlineSmall!.copyWith(
                                                                                                                fontWeight: FontWeight.bold,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    ref.watch(
                                                                                                          savingLoadingButton,
                                                                                                        )
                                                                                                        ? Center(
                                                                                                            child: LoadingSpinner(),
                                                                                                          )
                                                                                                        : Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                            children: [
                                                                                                              ConstrainedBox(
                                                                                                                constraints: BoxConstraints(
                                                                                                                  maxWidth: 40.w,
                                                                                                                ),
                                                                                                                child: TextButton(
                                                                                                                  style:
                                                                                                                      Theme.of(
                                                                                                                        context,
                                                                                                                      ).textButtonTheme.style?.copyWith(
                                                                                                                        foregroundColor:
                                                                                                                            WidgetStateProperty.all<
                                                                                                                              Color
                                                                                                                            >(
                                                                                                                              Colors.red,
                                                                                                                            ),
                                                                                                                      ),
                                                                                                                  onPressed: () {
                                                                                                                    showDialog(
                                                                                                                      context: context,
                                                                                                                      builder:
                                                                                                                          (
                                                                                                                            context,
                                                                                                                          ) {
                                                                                                                            return AlertDialog(
                                                                                                                              title: Text(
                                                                                                                                S
                                                                                                                                    .of(
                                                                                                                                      context,
                                                                                                                                    )
                                                                                                                                    .cancel_order,
                                                                                                                              ),
                                                                                                                              content: Text(
                                                                                                                                S
                                                                                                                                    .of(
                                                                                                                                      context,
                                                                                                                                    )
                                                                                                                                    .cancel_order_warning,
                                                                                                                              ),
                                                                                                                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                              actions: [
                                                                                                                                Consumer(
                                                                                                                                  builder:
                                                                                                                                      (
                                                                                                                                        context,
                                                                                                                                        ref,
                                                                                                                                        child,
                                                                                                                                      ) {
                                                                                                                                        return ref.watch(
                                                                                                                                              savingLoadingButton,
                                                                                                                                            )
                                                                                                                                            ? LoadingSpinner()
                                                                                                                                            : Row(
                                                                                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                                                                children: [
                                                                                                                                                  TextButton(
                                                                                                                                                    style:
                                                                                                                                                        Theme.of(
                                                                                                                                                          context,
                                                                                                                                                        ).textButtonTheme.style?.copyWith(
                                                                                                                                                          foregroundColor:
                                                                                                                                                              WidgetStateProperty.all<
                                                                                                                                                                Color
                                                                                                                                                              >(
                                                                                                                                                                Colors.red,
                                                                                                                                                              ),
                                                                                                                                                        ),
                                                                                                                                                    onPressed: () async {
                                                                                                                                                      ref
                                                                                                                                                              .read(
                                                                                                                                                                savingLoadingButton.notifier,
                                                                                                                                                              )
                                                                                                                                                              .state =
                                                                                                                                                          true;
                                                                                                                                                      await sendNotification(
                                                                                                                                                        ref.watch(
                                                                                                                                                          userDocumentsProvider,
                                                                                                                                                        )['name'],
                                                                                                                                                        "Sorry, restaurant has canceled your order",
                                                                                                                                                        atTableOrders[index]['client_fcm'],
                                                                                                                                                        image: ref.watch(
                                                                                                                                                          userDocumentsProvider,
                                                                                                                                                        )['urls'][0],
                                                                                                                                                      );
                                                                                                                                                      await supabase
                                                                                                                                                          .from(
                                                                                                                                                            'orders',
                                                                                                                                                          )
                                                                                                                                                          .delete()
                                                                                                                                                          .eq(
                                                                                                                                                            'id',
                                                                                                                                                            atTableOrders[index]['id'],
                                                                                                                                                          );
                                                                                                                                                      ref
                                                                                                                                                              .read(
                                                                                                                                                                savingLoadingButton.notifier,
                                                                                                                                                              )
                                                                                                                                                              .state =
                                                                                                                                                          false;
                                                                                                                                                      Navigator.of(
                                                                                                                                                        context,
                                                                                                                                                      ).pop();
                                                                                                                                                      Navigator.of(
                                                                                                                                                        context,
                                                                                                                                                      ).pop();
                                                                                                                                                      Navigator.of(
                                                                                                                                                        context,
                                                                                                                                                      ).pop();
                                                                                                                                                    },
                                                                                                                                                    child: Text(
                                                                                                                                                      S
                                                                                                                                                          .of(
                                                                                                                                                            context,
                                                                                                                                                          )
                                                                                                                                                          .yes_cancel,
                                                                                                                                                    ),
                                                                                                                                                  ),
                                                                                                                                                  TextButton(
                                                                                                                                                    style:
                                                                                                                                                        Theme.of(
                                                                                                                                                          context,
                                                                                                                                                        ).textButtonTheme.style?.copyWith(
                                                                                                                                                          foregroundColor:
                                                                                                                                                              WidgetStateProperty.all<
                                                                                                                                                                Color
                                                                                                                                                              >(
                                                                                                                                                                tertiaryColor,
                                                                                                                                                              ),
                                                                                                                                                        ),
                                                                                                                                                    onPressed: () => Navigator.of(
                                                                                                                                                      context,
                                                                                                                                                    ).pop(),
                                                                                                                                                    child: Text(
                                                                                                                                                      S
                                                                                                                                                          .of(
                                                                                                                                                            context,
                                                                                                                                                          )
                                                                                                                                                          .no,
                                                                                                                                                    ),
                                                                                                                                                  ),
                                                                                                                                                ],
                                                                                                                                              );
                                                                                                                                      },
                                                                                                                                ),
                                                                                                                              ],
                                                                                                                            );
                                                                                                                          },
                                                                                                                    );
                                                                                                                    ref
                                                                                                                            .read(
                                                                                                                              savingLoadingButton.notifier,
                                                                                                                            )
                                                                                                                            .state =
                                                                                                                        false;
                                                                                                                  },
                                                                                                                  child: Text(
                                                                                                                    S
                                                                                                                        .of(
                                                                                                                          context,
                                                                                                                        )
                                                                                                                        .cancel_order,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              if (TimeOfDay.now().isAfter(
                                                                                                                    time,
                                                                                                                  ) ||
                                                                                                                  TimeOfDay.now().isAtSameTimeAs(
                                                                                                                    time,
                                                                                                                  ))
                                                                                                                ConstrainedBox(
                                                                                                                  constraints: BoxConstraints(
                                                                                                                    maxWidth: 40.w,
                                                                                                                  ),
                                                                                                                  child: ElevatedButton(
                                                                                                                    onPressed: () async {
                                                                                                                      try {
                                                                                                                        ref
                                                                                                                                .read(
                                                                                                                                  savingLoadingButton.notifier,
                                                                                                                                )
                                                                                                                                .state =
                                                                                                                            true;
                                                                                                                        await supabase
                                                                                                                            .from(
                                                                                                                              "orders",
                                                                                                                            )
                                                                                                                            .update(
                                                                                                                              {
                                                                                                                                "completed": true,
                                                                                                                              },
                                                                                                                            )
                                                                                                                            .eq(
                                                                                                                              "id",
                                                                                                                              atTableOrders[index]['id'],
                                                                                                                            )
                                                                                                                            .whenComplete(
                                                                                                                              () async {
                                                                                                                                await sendNotification(
                                                                                                                                  ref.watch(
                                                                                                                                    userDocumentsProvider,
                                                                                                                                  )['name'],
                                                                                                                                  "Your command has been completed. Make sure to come again 😊",
                                                                                                                                  atTableOrders[index]['client_fcm'],
                                                                                                                                  image: ref.watch(
                                                                                                                                    userDocumentsProvider,
                                                                                                                                  )['urls'][0],
                                                                                                                                );
                                                                                                                                ref
                                                                                                                                        .read(
                                                                                                                                          savingLoadingButton.notifier,
                                                                                                                                        )
                                                                                                                                        .state =
                                                                                                                                    false;
                                                                                                                                Navigator.of(
                                                                                                                                  context,
                                                                                                                                ).pop();
                                                                                                                                Navigator.of(
                                                                                                                                  context,
                                                                                                                                ).pop();
                                                                                                                                ScaffoldMessenger.of(
                                                                                                                                  context,
                                                                                                                                ).showSnackBar(
                                                                                                                                  SuccessMessage(
                                                                                                                                    S
                                                                                                                                        .of(
                                                                                                                                          context,
                                                                                                                                        )
                                                                                                                                        .order_completed,
                                                                                                                                  ),
                                                                                                                                );
                                                                                                                              },
                                                                                                                            );
                                                                                                                      } catch (
                                                                                                                        e
                                                                                                                      ) {
                                                                                                                        print(
                                                                                                                          e,
                                                                                                                        );
                                                                                                                      }
                                                                                                                    },
                                                                                                                    child: Text(
                                                                                                                      S
                                                                                                                          .of(
                                                                                                                            context,
                                                                                                                          )
                                                                                                                          .complete,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                            ],
                                                                                                          ),
                                                                                                  ],
                                                                                                );
                                                                                              },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                        );
                                                                      },
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            24.sp,
                                                                          ),
                                                                      child: Padding(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                              8.sp,
                                                                            ),
                                                                        child: Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      '${atTableOrders[index]['client_name'].toString().length > 15 ? '${atTableOrders[index]['client_name'].toString().substring(0, 15)}...' : atTableOrders[index]['client_name']}',
                                                                                      style: Theme.of(
                                                                                        context,
                                                                                      ).textTheme.headlineMedium,
                                                                                    ),
                                                                                    Row(
                                                                                      spacing: 8.sp,
                                                                                      children: [
                                                                                        Text(
                                                                                          DateFormat.Hm().format(
                                                                                            timestamp,
                                                                                          ),
                                                                                          style: Theme.of(
                                                                                            context,
                                                                                          ).textTheme.bodyLarge,
                                                                                        ),
                                                                                        Text(
                                                                                          atTableOrders[index]["at_table"]
                                                                                              ? "• ${S.of(context).at_table}"
                                                                                              : "• ${S.of(context).to_go}",
                                                                                          style: Theme.of(
                                                                                            context,
                                                                                          ).textTheme.bodyLarge,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                                  children: [
                                                                                    Text(
                                                                                      "${S.of(context).order} ${atTableOrders[index]["id"]}",
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          "$numOrders ${numOrders > 1 ? S.of(context).items : S.of(context).item}",
                                                                                          style:
                                                                                              Theme.of(
                                                                                                context,
                                                                                              ).textTheme.bodyLarge?.copyWith(
                                                                                                color: secondaryColor,
                                                                                                fontWeight: FontWeight.bold,
                                                                                              ),
                                                                                        ),
                                                                                        HugeIcon(
                                                                                          icon: HugeIcons.strokeRoundedArrowRight01,
                                                                                          color: secondaryColor,
                                                                                          size: 16.sp,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            if (index !=
                                                                                atTableOrders.length -
                                                                                    1)
                                                                              Divider(
                                                                                color: tertiaryColor,
                                                                                thickness: 1.sp,
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                blurryKeys[0].currentState
                                                    ?.bounce();
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(
                                              24.sp,
                                            ),
                                            child: IntrinsicWidth(
                                              child: Container(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                padding: EdgeInsets.all(16.sp),
                                                height: 70.w,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        24.sp,
                                                      ),
                                                  boxShadow: [dropShadow],
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                      "assets/images/at_table.png",
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      S
                                                          .of(context)
                                                          .at_table_container,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineLarge
                                                          ?.copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    BlurryContainer(
                                                      key: blurryKeys[0],
                                                      width: 35.w,
                                                      height: 13.w,
                                                      child: Text(
                                                        "$numAtTable ${numAtTable != 1 ? S.of(context).orders : S.of(context).order}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (numToPickUp > 0) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                      insetPadding:
                                                          EdgeInsets.all(8.sp),
                                                      child: IntrinsicWidth(
                                                        stepWidth: 100.w,
                                                        child: IntrinsicHeight(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                  16.sp,
                                                                ),
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                spacing: 16.sp,
                                                                children: List.generate(
                                                                  toPickUpOrders
                                                                      .length,
                                                                  (index) {
                                                                    int
                                                                    numOrders =
                                                                        0;
                                                                    int
                                                                    totalPrice =
                                                                        0;
                                                                    final DateTime
                                                                    timestamp =
                                                                        DateTime.parse(
                                                                          toPickUpOrders[index]['delivery_at'],
                                                                        );
                                                                    for (var item
                                                                        in toPickUpOrders[index]['items']) {
                                                                      totalPrice +=
                                                                          item['price per one'] *
                                                                                  item['quantity']
                                                                              as int;
                                                                      numOrders +=
                                                                          item['quantity']
                                                                              as int;
                                                                    }
                                                                    print(
                                                                      numOrders,
                                                                    );
                                                                    return InkWell(
                                                                      onTap: () {
                                                                        TimeOfDay
                                                                        time = TimeOfDay(
                                                                          hour: DateTime.parse(
                                                                            toPickUpOrders[index]['delivery_at'],
                                                                          ).hour,
                                                                          minute: DateTime.parse(
                                                                            toPickUpOrders[index]['delivery_at'],
                                                                          ).minute,
                                                                        );
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) {
                                                                                return Dialog(
                                                                                  insetPadding: EdgeInsets.all(
                                                                                    8.sp,
                                                                                  ),
                                                                                  child: IntrinsicWidth(
                                                                                    stepWidth: 100.w,
                                                                                    child: IntrinsicHeight(
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.all(
                                                                                          16.sp,
                                                                                        ),
                                                                                        child: Consumer(
                                                                                          builder:
                                                                                              (
                                                                                                BuildContext context,
                                                                                                WidgetRef ref,
                                                                                                Widget? child,
                                                                                              ) {
                                                                                                return Column(
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
                                                                                                            Text(
                                                                                                              '${toPickUpOrders[index]['client_name'].toString().length > 15 ? '${toPickUpOrders[index]['client_name'].toString().substring(0, 15)}...' : toPickUpOrders[index]['client_name']}',
                                                                                                              style: Theme.of(
                                                                                                                context,
                                                                                                              ).textTheme.headlineMedium,
                                                                                                            ),
                                                                                                            Text(
                                                                                                              toPickUpOrders[index]["at_table"]
                                                                                                                  ? S
                                                                                                                        .of(
                                                                                                                          context,
                                                                                                                        )
                                                                                                                        .at_table
                                                                                                                  : S
                                                                                                                        .of(
                                                                                                                          context,
                                                                                                                        )
                                                                                                                        .to_go,
                                                                                                              style: Theme.of(
                                                                                                                context,
                                                                                                              ).textTheme.bodyLarge,
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                        Text(
                                                                                                          DateFormat.Hm().format(
                                                                                                            timestamp,
                                                                                                          ),
                                                                                                          style: Theme.of(
                                                                                                            context,
                                                                                                          ).textTheme.headlineLarge,
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    Container(
                                                                                                      width: 100.w,
                                                                                                      padding: EdgeInsets.all(
                                                                                                        16.sp,
                                                                                                      ),
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: backgroundColor,
                                                                                                        borderRadius: BorderRadius.circular(
                                                                                                          16.sp,
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: Column(
                                                                                                        children: List.generate(
                                                                                                          toPickUpOrders[index]['items'].length,
                                                                                                          (
                                                                                                            itemIndex,
                                                                                                          ) {
                                                                                                            return Row(
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  "${toPickUpOrders[index]['items'][itemIndex]['category']} ${toPickUpOrders[index]['items'][itemIndex]['name']} ${toPickUpOrders[index]['items'][itemIndex]['size'] ?? ""} x ${toPickUpOrders[index]['items'][itemIndex]['quantity']}",
                                                                                                                  style:
                                                                                                                      Theme.of(
                                                                                                                        context,
                                                                                                                      ).textTheme.bodySmall!.copyWith(
                                                                                                                        color: Colors.black,
                                                                                                                      ),
                                                                                                                ),
                                                                                                                Text(
                                                                                                                  " ${toPickUpOrders[index]['items'][itemIndex]['note'] ?? ""}",
                                                                                                                  style: Theme.of(
                                                                                                                    context,
                                                                                                                  ).textTheme.bodySmall,
                                                                                                                ),
                                                                                                              ],
                                                                                                            );
                                                                                                          },
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                      children: [
                                                                                                        Text(
                                                                                                          S
                                                                                                              .of(
                                                                                                                context,
                                                                                                              )
                                                                                                              .total_price,
                                                                                                          style: Theme.of(
                                                                                                            context,
                                                                                                          ).textTheme.headlineSmall,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          "$totalPrice ${S.of(context).da}",
                                                                                                          style:
                                                                                                              Theme.of(
                                                                                                                context,
                                                                                                              ).textTheme.headlineSmall!.copyWith(
                                                                                                                fontWeight: FontWeight.bold,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    ref.watch(
                                                                                                          savingLoadingButton,
                                                                                                        )
                                                                                                        ? Center(
                                                                                                            child: LoadingSpinner(),
                                                                                                          )
                                                                                                        : Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                            children: [
                                                                                                              ConstrainedBox(
                                                                                                                constraints: BoxConstraints(
                                                                                                                  maxWidth: 40.w,
                                                                                                                ),
                                                                                                                child: TextButton(
                                                                                                                  style:
                                                                                                                      Theme.of(
                                                                                                                        context,
                                                                                                                      ).textButtonTheme.style?.copyWith(
                                                                                                                        foregroundColor:
                                                                                                                            WidgetStateProperty.all<
                                                                                                                              Color
                                                                                                                            >(
                                                                                                                              Colors.red,
                                                                                                                            ),
                                                                                                                      ),
                                                                                                                  onPressed: () {
                                                                                                                    showDialog(
                                                                                                                      context: context,
                                                                                                                      builder:
                                                                                                                          (
                                                                                                                            context,
                                                                                                                          ) {
                                                                                                                            return AlertDialog(
                                                                                                                              title: Text(
                                                                                                                                S
                                                                                                                                    .of(
                                                                                                                                      context,
                                                                                                                                    )
                                                                                                                                    .cancel_order,
                                                                                                                              ),
                                                                                                                              content: Text(
                                                                                                                                S
                                                                                                                                    .of(
                                                                                                                                      context,
                                                                                                                                    )
                                                                                                                                    .cancel_order_warning,
                                                                                                                              ),
                                                                                                                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                              actions: [
                                                                                                                                TextButton(
                                                                                                                                  style:
                                                                                                                                      Theme.of(
                                                                                                                                        context,
                                                                                                                                      ).textButtonTheme.style?.copyWith(
                                                                                                                                        foregroundColor:
                                                                                                                                            WidgetStateProperty.all<
                                                                                                                                              Color
                                                                                                                                            >(
                                                                                                                                              Colors.red,
                                                                                                                                            ),
                                                                                                                                      ),
                                                                                                                                  onPressed: () async {
                                                                                                                                    await sendNotification(
                                                                                                                                      ref.watch(
                                                                                                                                        userDocumentsProvider,
                                                                                                                                      )['name'],
                                                                                                                                      "Sorry, restaurant has canceled your order",
                                                                                                                                      toPickUpOrders[index]['client_fcm'],
                                                                                                                                      image: ref.watch(
                                                                                                                                        userDocumentsProvider,
                                                                                                                                      )['urls'][0],
                                                                                                                                    );
                                                                                                                                    await supabase
                                                                                                                                        .from(
                                                                                                                                          'orders',
                                                                                                                                        )
                                                                                                                                        .delete()
                                                                                                                                        .eq(
                                                                                                                                          'id',
                                                                                                                                          toPickUpOrders[index]['id'],
                                                                                                                                        );
                                                                                                                                    Navigator.of(
                                                                                                                                      context,
                                                                                                                                    ).pop();
                                                                                                                                    Navigator.of(
                                                                                                                                      context,
                                                                                                                                    ).pop();
                                                                                                                                    Navigator.of(
                                                                                                                                      context,
                                                                                                                                    ).pop();
                                                                                                                                  },
                                                                                                                                  child: Text(
                                                                                                                                    S
                                                                                                                                        .of(
                                                                                                                                          context,
                                                                                                                                        )
                                                                                                                                        .yes_cancel,
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                                TextButton(
                                                                                                                                  style:
                                                                                                                                      Theme.of(
                                                                                                                                        context,
                                                                                                                                      ).textButtonTheme.style?.copyWith(
                                                                                                                                        foregroundColor:
                                                                                                                                            WidgetStateProperty.all<
                                                                                                                                              Color
                                                                                                                                            >(
                                                                                                                                              tertiaryColor,
                                                                                                                                            ),
                                                                                                                                      ),
                                                                                                                                  onPressed: () => Navigator.of(
                                                                                                                                    context,
                                                                                                                                  ).pop(),
                                                                                                                                  child: Text(
                                                                                                                                    S
                                                                                                                                        .of(
                                                                                                                                          context,
                                                                                                                                        )
                                                                                                                                        .no,
                                                                                                                                  ),
                                                                                                                                ),
                                                                                                                              ],
                                                                                                                            );
                                                                                                                          },
                                                                                                                    );
                                                                                                                    //TODO First we inform the client with a push notification
                                                                                                                    //TODO Then we remove the row from the database
                                                                                                                  },
                                                                                                                  child: Text(
                                                                                                                    S
                                                                                                                        .of(
                                                                                                                          context,
                                                                                                                        )
                                                                                                                        .cancel_order,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              if (TimeOfDay.now().isAfter(
                                                                                                                    time,
                                                                                                                  ) ||
                                                                                                                  TimeOfDay.now().isAtSameTimeAs(
                                                                                                                    time,
                                                                                                                  ))
                                                                                                                ConstrainedBox(
                                                                                                                  constraints: BoxConstraints(
                                                                                                                    maxWidth: 40.w,
                                                                                                                  ),
                                                                                                                  child: ElevatedButton(
                                                                                                                    onPressed: () async {
                                                                                                                      try {
                                                                                                                        ref
                                                                                                                                .read(
                                                                                                                                  savingLoadingButton.notifier,
                                                                                                                                )
                                                                                                                                .state =
                                                                                                                            true;
                                                                                                                        await supabase
                                                                                                                            .from(
                                                                                                                              "orders",
                                                                                                                            )
                                                                                                                            .update(
                                                                                                                              {
                                                                                                                                "completed": true,
                                                                                                                              },
                                                                                                                            )
                                                                                                                            .eq(
                                                                                                                              "id",
                                                                                                                              toPickUpOrders[index]['id'],
                                                                                                                            )
                                                                                                                            .whenComplete(
                                                                                                                              () async {
                                                                                                                                await sendNotification(
                                                                                                                                  ref.watch(
                                                                                                                                    userDocumentsProvider,
                                                                                                                                  )['name'],
                                                                                                                                  "Your command has been completed. Make sure to come again 😊",
                                                                                                                                  toPickUpOrders[index]['client_fcm'],
                                                                                                                                  image: ref.watch(
                                                                                                                                    userDocumentsProvider,
                                                                                                                                  )['urls'][0],
                                                                                                                                );
                                                                                                                                ref
                                                                                                                                        .read(
                                                                                                                                          savingLoadingButton.notifier,
                                                                                                                                        )
                                                                                                                                        .state =
                                                                                                                                    false;
                                                                                                                                Navigator.of(
                                                                                                                                  context,
                                                                                                                                ).pop();
                                                                                                                                Navigator.of(
                                                                                                                                  context,
                                                                                                                                ).pop();
                                                                                                                                ScaffoldMessenger.of(
                                                                                                                                  context,
                                                                                                                                ).showSnackBar(
                                                                                                                                  SuccessMessage(
                                                                                                                                    S
                                                                                                                                        .of(
                                                                                                                                          context,
                                                                                                                                        )
                                                                                                                                        .order_completed,
                                                                                                                                  ),
                                                                                                                                );
                                                                                                                              },
                                                                                                                            );
                                                                                                                      } catch (
                                                                                                                        e
                                                                                                                      ) {
                                                                                                                        print(
                                                                                                                          e,
                                                                                                                        );
                                                                                                                      }
                                                                                                                    },
                                                                                                                    child: Text(
                                                                                                                      S
                                                                                                                          .of(
                                                                                                                            context,
                                                                                                                          )
                                                                                                                          .complete,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ),
                                                                                                            ],
                                                                                                          ),
                                                                                                  ],
                                                                                                );
                                                                                              },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                        );
                                                                      },
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            24.sp,
                                                                          ),
                                                                      child: Padding(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                              8.sp,
                                                                            ),
                                                                        child: Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      '${toPickUpOrders[index]['client_name'].toString().length > 15 ? '${toPickUpOrders[index]['client_name'].toString().substring(0, 15)}...' : toPickUpOrders[index]['client_name']}',
                                                                                      style: Theme.of(
                                                                                        context,
                                                                                      ).textTheme.headlineMedium,
                                                                                    ),
                                                                                    Row(
                                                                                      spacing: 8.sp,
                                                                                      children: [
                                                                                        Text(
                                                                                          DateFormat.Hm().format(
                                                                                            timestamp,
                                                                                          ),
                                                                                          style: Theme.of(
                                                                                            context,
                                                                                          ).textTheme.bodyLarge,
                                                                                        ),
                                                                                        Text(
                                                                                          toPickUpOrders[index]["at_table"]
                                                                                              ? "• ${S.of(context).at_table}"
                                                                                              : "• ${S.of(context).to_go}",
                                                                                          style: Theme.of(
                                                                                            context,
                                                                                          ).textTheme.bodyLarge,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                                  children: [
                                                                                    Text(
                                                                                      "${S.of(context).order} ${toPickUpOrders[index]['id']}",
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          "$numOrders ${numOrders > 1 ? S.of(context).items : S.of(context).item}",
                                                                                          style:
                                                                                              Theme.of(
                                                                                                context,
                                                                                              ).textTheme.bodyLarge?.copyWith(
                                                                                                color: secondaryColor,
                                                                                                fontWeight: FontWeight.bold,
                                                                                              ),
                                                                                        ),
                                                                                        HugeIcon(
                                                                                          icon: HugeIcons.strokeRoundedArrowRight01,
                                                                                          color: secondaryColor,
                                                                                          size: 16.sp,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            if (index !=
                                                                                toPickUpOrders.length -
                                                                                    1)
                                                                              Divider(
                                                                                color: tertiaryColor,
                                                                                thickness: 1.sp,
                                                                              ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                blurryKeys[1].currentState
                                                    ?.bounce();
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(
                                              24.sp,
                                            ),
                                            child: IntrinsicWidth(
                                              child: Container(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                padding: EdgeInsets.all(16.sp),
                                                height: 70.w,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        24.sp,
                                                      ),
                                                  boxShadow: [dropShadow],
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                      "assets/images/to_pick_up.png",
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      S
                                                          .of(context)
                                                          .to_go_container,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineLarge
                                                          ?.copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                    BlurryContainer(
                                                      key: blurryKeys[1],
                                                      width: 35.w,
                                                      height: 13.w,
                                                      child: Text(
                                                        "$numToPickUp ${numToPickUp != 1 ? S.of(context).orders : S.of(context).order}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall
                                                            ?.copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              },
                            )
                          : ref.watch(userDocumentsProvider)['active'] == false
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16.sp,
                                children: [
                                  Lottie.asset(
                                    "assets/animations/warning_red.json",
                                    width: 40.w,
                                  ),
                                  Text(
                                    S.of(context).status_off,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge,
                                  ),
                                ],
                              ),
                            )
                          : ref.watch(
                                  userDocumentsProvider,
                                )['subscription_end'] ==
                                null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16.sp,
                                children: [
                                  Lottie.asset(
                                    "assets/animations/money.json",
                                    width: 40.w,
                                  ),
                                  Text(
                                    S.of(context).no_subscription,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  Text(S.of(context).contact_dinney),
                                  Text("‪+213 797 08 76 52‬"),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 16.sp,
                                children: [
                                  Lottie.asset(
                                    "assets/animations/pay.json",
                                    width: 40.w,
                                  ),
                                  Text(
                                    S.of(context).ended_subscribtion,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  Text(S.of(context).contact_dinney),
                                  Text("‪+213 797 08 76 52‬"),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            )
          : Center(child: LoadingSpinner()),
    );
  }
}

class suggestionDialog extends ConsumerWidget {
  final int id;
  final String opening;
  final String closing;
  final List<dynamic> client_fcm;

  final suggestionProvider = StateProvider<List<bool>>((ref) => [true, false]);
  final suggestionButton = StateProvider<bool>((ref) => false);
  int selectedHour = DateTime.now().hour;
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
      if (hour == null ||
          minute == null ||
          hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        return null; // Invalid hour or minute
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null; // Return null on any parsing error
    }
  }

  suggestionDialog(
    this.opening,
    this.closing,
    this.client_fcm, {
    super.key,
    required this.id,
  });
  @override
  Widget build(BuildContext context, WidgetRef dref) {
    //FIXME suggestion might not show suggestion because of moved list from above to here
    List<String> suggestions = [S.of(context).at_table, S.of(context).to_go];
    var openingTime = parseTimeString(opening);
    final closingTime = parseTimeString(closing);
    final name = dref.watch(userDocumentsProvider)['name'];
    final image = dref.watch(userDocumentsProvider)['urls'][0];
    if (openingTime!.isBefore(TimeOfDay.now())) {
      openingTime = TimeOfDay.now();
    }
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.sp)),
      insetPadding: EdgeInsets.all(8.sp),
      child: Consumer(
        builder: (context, ref, child) {
          return IntrinsicWidth(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        return Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (index == 0) {
                                ref.read(suggestionProvider.notifier).state = [
                                  true,
                                  false,
                                ];
                              } else {
                                ref.read(suggestionProvider.notifier).state = [
                                  false,
                                  true,
                                ];
                              }
                            },
                            style: outlinedBeige.copyWith(
                              //fixedSize: WidgetStateProperty.all<Size>(Size(33.w, 4.h)),
                              backgroundColor: WidgetStateProperty.all<Color>(
                                ref.watch(suggestionProvider)[index]
                                    ? secondaryColor
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              suggestions[index],
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: ref.watch(suggestionProvider)[index]
                                        ? Colors.white
                                        : tertiaryColor,
                                    fontWeight:
                                        ref.watch(suggestionProvider)[index]
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      height: 25.h, // Responsive height using Sizer
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize:
                            MainAxisSize.min, // Prevent unnecessary space
                        children: [
                          // Hour picker
                          SizedBox(
                            width: 20.w, // Responsive width
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 5.h, // Responsive item height
                              diameterRatio:
                                  1.5, // Controls the wheel curvature
                              physics:
                                  FixedExtentScrollPhysics(), // Snap to each item
                              squeeze: 0.8, // Squeeze items toward the center
                              offAxisFraction:
                                  -0.3, // Adjust for better centering
                              magnification: 1.3, // Magnify selected item
                              useMagnifier: true, // Enable magnification effect
                              onSelectedItemChanged: (index) {
                                selectedHour = openingTime!.hour + index;
                                final selectedTime = parseTimeString(
                                  "$selectedHour:$selectedMinute:00",
                                );
                                print("the selected time is $selectedTime");
                                if (selectedTime!.isAfter(openingTime) &&
                                    selectedTime.isBefore(closingTime)) {
                                  ref.read(suggestionButton.notifier).state =
                                      true;
                                } else {
                                  ref.read(suggestionButton.notifier).state =
                                      false;
                                }
                                //hour =  + index;
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  var hour = openingTime!.hour + index;
                                  return Center(
                                    child: Text(
                                      hour.toString().padLeft(2, '0'),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  );
                                },
                                childCount:
                                    (closingTime!.hour - openingTime!.hour) +
                                    1, // 9:00 to 17:00
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              ':',
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          // Minute picker
                          SizedBox(
                            width: 20.w, // Responsive width
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 5.h, // Responsive item height
                              diameterRatio: 1.5,
                              magnification: 1.3, // Magnify selected item
                              physics:
                                  FixedExtentScrollPhysics(), // Snap to each item
                              squeeze: 0.8, // Squeeze items toward the center
                              offAxisFraction:
                                  -0.3, // Adjust for better centering
                              useMagnifier: true,
                              onSelectedItemChanged: (index) {
                                print('Minute: $index');
                                selectedMinute = index;
                                final selectedTime = parseTimeString(
                                  "$selectedHour:$selectedMinute:00",
                                );
                                if (selectedTime!.isAfter(openingTime!) &&
                                    selectedTime.isBefore(closingTime!)) {
                                  ref.read(suggestionButton.notifier).state =
                                      true;
                                } else {
                                  ref.read(suggestionButton.notifier).state =
                                      false;
                                }
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  //var minute = openingTime!.minute + index;
                                  return Center(
                                    child: Text(
                                      index.toString().padLeft(2, '0'),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!,
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
                    if (ref.watch(suggestionButton))
                      ref.watch(savingLoadingButton)
                          ? LoadingSpinner()
                          : ElevatedButton(
                              onPressed: () async {
                                ref.read(savingLoadingButton.notifier).state =
                                    true;
                                await supabase
                                    .from('orders')
                                    .update(({
                                      'suggested': true,
                                      'awaiting': false,
                                      'at_table': ref.watch(
                                        suggestionProvider,
                                      )[0],
                                      'suggested_at': DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        selectedHour,
                                        selectedMinute,
                                      ).toIso8601String(),
                                    }))
                                    .eq('id', id);
                                await sendNotification(
                                  name,
                                  "Restaurant has made a suggestion",
                                  client_fcm,
                                  image: image,
                                );
                                if (context.mounted) {
                                  ref.read(savingLoadingButton.notifier).state =
                                      false;
                                  Navigator.pop(context);
                                  if (Navigator.canPop(context)) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                              child: Text(S.of(context).suggest),
                            ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
