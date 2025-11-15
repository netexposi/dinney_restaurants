import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/services/functions/sound_player.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AnimatedSnackContent extends StatefulWidget {
  const AnimatedSnackContent({super.key});

  @override
  State<AnimatedSnackContent> createState() => _AnimatedSnackContentState();
}

class _AnimatedSnackContentState extends State<AnimatedSnackContent>
    with TickerProviderStateMixin {
  late final AnimationController _avatarController;
  late final AnimationController _textController;

  @override
  void initState() {
    super.initState();
    

    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Fade in text after avatar appears
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(8.sp),
      child: BlurryContainer(
        borderRadius: BorderRadius.circular(36.sp),
        padding: 12.sp,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 16.sp,
          //mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _avatarController,
                curve: Curves.easeOutBack,
              ),
              child: CircleAvatar(
                radius: 24.sp,
                backgroundImage:
                    const AssetImage("assets/images/minature_logo.png"),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: _textController,
                child: SizedBox(
                  child: Text(
                    S.of(context).welcome_back_message,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}