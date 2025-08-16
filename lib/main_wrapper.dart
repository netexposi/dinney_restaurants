import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';


class MainWrapper extends ConsumerWidget {
  MainWrapper({
    required this.navigationShell,
    super.key,
  });
  final StatefulNavigationShell navigationShell;
  
  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: navigationShell,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if(ref.watch(userDocumentsProvider).isNotEmpty){
            ref.read(selectedIndex.notifier).state = index;
            _goBranch(index);
          }
        },
        currentIndex: ref.watch(selectedIndex),
        selectedItemColor: secondaryColor,
        unselectedItemColor: secondaryColor.withOpacity(0.5), // Lighter color for unselected items
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedHome01,
              color: ref.watch(selectedIndex) == 0 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedServingFood,
              color: ref.watch(selectedIndex) == 1 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: "Menu",
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAppleStocks,
              color: ref.watch(selectedIndex) == 2 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: "Statistics",
          ),
        ],
      ),
    );
  }
}
