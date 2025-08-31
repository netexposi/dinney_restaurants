import 'dart:io';
import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/authentication/menu_creation_view.dart';
import 'package:dinney_restaurant/services/functions/storage_functions.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/widgets/circles_indicator.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final imagesProvider = StateProvider<List<File?>>((ref) => [null, null, null, null]);
final removeButtonProvider = StateProvider<List<bool>>((ref) => [false, false, false, false]);

class GallerySettingView extends ConsumerWidget {
  final int restaurantId;
  const GallerySettingView(this.restaurantId, {super.key});

  Future<void> _pickImage({
    required WidgetRef ref,
    required int index,
  }) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final currentImages = ref.read(imagesProvider);
      final updatedImages = List<File?>.from(currentImages);
      updatedImages[index] = File(picked.path);
      ref.read(imagesProvider.notifier).state = updatedImages;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imagesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            spacing: 16.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: ThreeDotsIndicator()
              ),
              Text(S.of(context).select_primary_image, style: Theme.of(context).textTheme.titleMedium,),
              InkWell(
                onTap: () => _pickImage(ref: ref, index: 0),
                borderRadius: BorderRadius.circular(24.sp),
                child: Container(
                  width: 100.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.sp),
                    color: Colors.grey[300],
                    image: images[0] != null
                        ? DecorationImage(
                            image: FileImage(images[0]!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: images[0] == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.add_circle, size: 24.sp, color: tertiaryColor,),
                            Text(S.of(context).add_image)
                          ],
                        )
                      : null,
                ),
              ),
              Text(S.of(context).select_album_image, style: Theme.of(context).textTheme.titleMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (i) {
                  final index = i + 1; // 1, 2, 3
                  return InkWell(
                    onTap: () => _pickImage(ref: ref, index: index),
                    onLongPress: (){
                      ref.read(removeButtonProvider.notifier).state[index] = true;
                    },
                    borderRadius: BorderRadius.circular(24.sp),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.sp),
                            color: Colors.grey[300],
                            image: images[index] != null
                                ? DecorationImage(
                                    image: FileImage(images[index]!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: images[index] == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Iconsax.add_circle, size: 24.sp, color: tertiaryColor,),
                                  ],
                                )
                              : null,
                        ),
                        if(ref.watch(removeButtonProvider)[index]) AnimatedContainer(
                          width: 8.w,
                          height: 8.w,
                          duration: Duration(milliseconds: 200),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              onPressed: (){
                                final currentImages = ref.read(imagesProvider);
                                final updatedImages = List<File?>.from(currentImages);
                                updatedImages[index] = null;
                                ref.read(imagesProvider.notifier).state = updatedImages;
                                ref.read(removeButtonProvider.notifier).state[index] = false;
                              },
                              // onPressed: (){
                              //   if(removeButtonProvider[index - 1]){
                              //     setState((){
                              //       removeButtonProvider[index - 1] = false;
                              //       indexes.removeWhere((ind) => ind == index);
                              //       urls[index] = null;
                              //     });
                              //   }
                              // }, 
                              icon: Icon(Iconsax.gallery_remove, color: Colors.red, size: 16.sp,)
                            ),
                          ),
                        )
                      ]
                    ),
                  );
                }),
              ),
              if(ref.watch(imagesProvider).any((image) => image != null)) Align(
                alignment: Alignment.center,
                child: !ref.watch(savingLoadingButton)? ElevatedButton(
                  onPressed: () async{
                    ref.watch(savingLoadingButton.notifier).state = true;
                    List<String> urls = [];
                    for (var imageFile in ref.watch(imagesProvider)) {
                      if(imageFile != null){
                        var url = await uploadImageToSupabase(imageFile);
                        urls.add(url!);
                      }
                    }
                    try{
                      await Supabase.instance.client.from('restaurants').update({'urls': urls}).eq('id', restaurantId)
                      .whenComplete((){
                        ref.watch(savingLoadingButton.notifier).state = false;
                        ref.read(signUpProvider.notifier).state = 2; // update the sign up state to 3
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> MenuCreationView(restaurantId)));
                      });
                    } catch (e){
                      ScaffoldMessenger.of(context).showSnackBar(ErrorMessage(S.of(context).internal_error));
                    }

                  }, 
                  child: Text(S.of(context).next)
                ) : LoadingSpinner(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
