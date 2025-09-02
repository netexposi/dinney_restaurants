import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sizer/sizer.dart';


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
      body: ref.watch(errorProvider)['status']? SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: navigationShell,
      ) : Center(
        child: Column(
          spacing: 16.sp,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/error.png", width: 25.w,),
            Text(S.of(context).error)
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if(ref.watch(userDocumentsProvider).isNotEmpty && ref.watch(errorProvider)['status']){
            ref.read(selectedIndex.notifier).state = index;
            _goBranch(index);
          }
        },
        currentIndex: ref.watch(selectedIndex),
        selectedItemColor: secondaryColor,
        unselectedItemColor: secondaryColor.withOpacity(0.5), // Lighter color for unselected items
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              ref.watch(selectedIndex) == 0? Iconsax.home_21 : Iconsax.home_24,
              color: ref.watch(selectedIndex) == 0 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: S.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              ref.watch(selectedIndex) == 1? Iconsax.document_15 : Iconsax.document_1,
              color: ref.watch(selectedIndex) == 1 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: S.of(context).menu,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              ref.watch(selectedIndex) == 2? Iconsax.graph5 : Iconsax.graph,
              color: ref.watch(selectedIndex) == 2 ? secondaryColor : secondaryColor.withOpacity(0.5),
            ),
            label: S.of(context).statistics,
          ),
        ],
      ),
    );
  }
}
