import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({
    required this.navigationShell,
    super.key,
  });
  final StatefulNavigationShell navigationShell;

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int selectedIndex = 0; // Added missing selectedIndex variable

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            _goBranch(selectedIndex);
          });
        },
        currentIndex: selectedIndex,
        selectedItemColor: secondaryColor,
        unselectedItemColor: secondaryColor.withOpacity(0.5), // Lighter color for unselected items
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedHome01,
              color: selectedIndex == 0 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedServingFood,
              color: selectedIndex == 1 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: "Menu",
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAppleStocks,
              color: selectedIndex == 2 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: "Statistics",
          ),
        ],
      ),
    );
  }
}