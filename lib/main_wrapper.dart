import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        unselectedItemColor: secondaryColor.withOpacity(0.5),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.home),label: "Home"),
          BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.archivebox), label: "Menu"),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.list_bullet), label: "JCP"),
        ],
      ),
    );
  }
}
