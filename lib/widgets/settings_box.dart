import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/settings/settings_view.dart';
import 'package:dinney_restaurant/services/functions/notification_provider.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sizer/sizer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SettingsBox extends ConsumerWidget {
  late var notViewedNotifications;

  SettingsBox({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var asyncNotifications = ref.watch(notificationListProvider);

    if (asyncNotifications.value == null) {
      notViewedNotifications = [];
    } else {
      notViewedNotifications = asyncNotifications.value!.reversed.where(
        (element) => !element.viewed,
      );
    }

    return Container(
      height: 9.w,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20.sp,
        children: [
          // 🔔 Notification bell
          InkWell(
            onTap: () {
              if (asyncNotifications.hasValue) {
                showModalBottomSheet(
                  constraints: BoxConstraints(
                    minWidth: 100.w
                  ),
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.sp)),
                  ),
                  builder: (context) {
                    return Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        var notifications = ref.watch(notificationListProvider);
                        return Container(
                          width: 100.w,
                          padding: EdgeInsets.only(
                              top: 16.sp, left: 16.sp, right: 16.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24.sp)),
                            color: backgroundColor,
                          ),
                          constraints: BoxConstraints(
                            maxHeight: 50.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Small top handle
                              Center(
                                child: Container(
                                  width: 40.sp,
                                  height: 8.sp,
                                  margin: EdgeInsets.only(bottom: 12.sp),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius:
                                        BorderRadius.circular(20.sp),
                                  ),
                                ),
                              ),
                        
                              // 🔔 Title + "Clear all" button row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.of(context).notifications,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  if (notifications.value!.isNotEmpty)
                                    TextButton(
                                      onPressed: () async {
                                        final box = await ref.read(
                                            notificationBoxProvider.future);
                                        await box.clear();
                                        ref.invalidate(
                                            notificationListProvider);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text("All notifications cleared"),
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        S.of(context).clear_all,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Colors.red,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                        
                              SizedBox(height: 16.sp),
                        
                              // Scrollable notification list
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    spacing: 12.sp,
                                    children: List.generate(
                                        notifications.value!.length,
                                        (index) {
                                      var notification = notifications
                                          .value!.reversed
                                          .toList()[index];
                        
                                      return VisibilityDetector(
                                        key: Key('item-$index'),
                                        onVisibilityChanged:
                                            (VisibilityInfo info) async {
                                          if (info.visibleFraction > 0.5 &&
                                              !notification.viewed) {
                                            final box = await ref.read(
                                                notificationBoxProvider
                                                    .future);
                                            final key = box.keyAt(
                                                notifications
                                                        .value!.length -
                                                    1 -
                                                    index);
                                            final updated = notification
                                                .copyWith(viewed: true);
                                            await box.put(key, updated);
                                            ref.invalidate(
                                                notificationListProvider);
                                          }
                                        },
                                        child: Dismissible(
                                          key: UniqueKey(),
                                          direction:
                                              DismissDirection.startToEnd,
                                          background: Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(
                                                left: 24.sp),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20.sp),
                                            ),
                                            child: Icon(Icons.delete,
                                                color: Colors.red,
                                                size: 20.sp),
                                          ),
                                          onDismissed: (_) async {
                                            final box = await ref.read(
                                                notificationBoxProvider
                                                    .future);
                                            final currentKeys =
                                                box.keys.toList(
                                                    growable: false);
                                            if (currentKeys.isNotEmpty &&
                                                index <
                                                    currentKeys.length) {
                                              final key = currentKeys[
                                                  currentKeys.length -
                                                      1 -
                                                      index];
                                              await box.delete(key);
                                            }
                                            ref.invalidate(
                                                notificationListProvider);
                                          },
                                          child: InkWell(
                                            onTap: () async {
                                              final box = await ref.read(
                                                  notificationBoxProvider
                                                      .future);
                                              final key = box.keyAt(
                                                  notifications
                                                          .value!.length -
                                                      1 -
                                                      index);
                                              final updated = notification
                                                  .copyWith(viewed: true);
                                              await box.put(key, updated);
                                              ref
                                                  .read(selectedIndex.notifier)
                                                  .state = 0;
                                              AppNavigation.navRouter
                                                  .go("/home");
                                            },
                                            borderRadius:
                                                BorderRadius.circular(20.sp),
                                            child: Container(
                                              margin: EdgeInsets.only(bottom: index == notifications.value!.length -1? 16.px : 0),
                                              padding:
                                                  EdgeInsets.all(16.sp),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.sp),
                                                color: Colors.white,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          notification.title,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        SizedBox(
                                                            height: 4.sp),
                                                        Text(
                                                          notification.body,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodySmall,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (!notification.viewed)
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.only(
                                                              left: 8.sp),
                                                      child: CircleAvatar(
                                                        radius: 8.sp,
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
            borderRadius: BorderRadius.circular(8.sp),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Iconsax.notification,
                  color: tertiaryColor,
                  size: 20.sp,
                ),
                Positioned(
                  right: -10.sp,
                  top: -10.sp,
                  child: Container(
                    padding: EdgeInsets.all(2.sp),
                    decoration: BoxDecoration(
                      color: notViewedNotifications.isEmpty
                          ? Colors.transparent
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.sp,
                      minHeight: 16.sp,
                    ),
                    child: Center(
                      child: Text(
                        notViewedNotifications.isEmpty
                            ? ""
                            : "${notViewedNotifications.length}",
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ⚙️ Settings icon
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsView()));
            },
            borderRadius: BorderRadius.circular(8.sp),
            child: Icon(
              Iconsax.setting,
              color: tertiaryColor,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
