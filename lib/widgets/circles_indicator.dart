import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';


class ThreeDotsIndicator extends ConsumerWidget {

  ThreeDotsIndicator({
    super.key,
  });
  final activeColor = secondaryColor;
  final inactiveColor = tertiaryColor.withOpacity(0.7);
  final activeSize = 24.sp;
  final inactiveSize = 16.sp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(signUpProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final bool isActive = index == activeIndex;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: index >= ref.watch(signUpProvider)? AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 300),
            width: isActive ? activeSize : inactiveSize,
            height: isActive ? activeSize : inactiveSize,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
            child: index == ref.watch(signUpProvider)?
            Text("${ref.watch(signUpProvider)+1}", style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),)
            : SizedBox.shrink(),
          ) : AnimatedContainer(
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 300),
              width: inactiveSize,
              height: inactiveSize,
              decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
          ),
        );
      }),
    );
  }
}
