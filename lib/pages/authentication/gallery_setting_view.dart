import 'dart:io';
import 'package:dinney_restaurant/pages/authentication/menu_creation_view.dart';
import 'package:dinney_restaurant/services/functions/storage_functions.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final imagesProvider = StateProvider<List<File?>>((ref) => [null, null, null, null]);

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
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.sp),
          width: 25.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(24.sp)
          ),
          child: Row(
            spacing: 8.sp,
            children: [
              CircleAvatar(
                radius: 16.sp,
                backgroundColor: backgroundColor,
                child: Center(
                  child: Text("${ref.watch(signUpProvider)}", style: Theme.of(context).textTheme.bodyLarge,),
                ),
              ),
              Text("Menu", style: Theme.of(context).textTheme.headlineMedium,)
            ],
          ),
        ),
      ),
      body: SizedBox(
        height: 100.h,
        width: 100.w,
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            spacing: 16.sp,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Primary Image"),
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
                            Icon(CupertinoIcons.add_circled, size: 24.sp),
                            Text("Add Image")
                          ],
                        )
                      : null,
                ),
              ),
              Text("Select Album Images"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (i) {
                  final index = i + 1; // 1, 2, 3
                  return InkWell(
                    onTap: () => _pickImage(ref: ref, index: index),
                    borderRadius: BorderRadius.circular(24.sp),
                    child: Container(
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
                                Icon(CupertinoIcons.add_circled, size: 18.sp),
                                Text("Add", style: TextStyle(fontSize: 9.sp)),
                              ],
                            )
                          : null,
                    ),
                  );
                }),
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async{
                    List<String> urls = [];
                    for (var imageFile in ref.watch(imagesProvider)) {
                      
                      var url = await uploadImageToSupabase(imageFile!);
                      urls.add(url!);
                    }
                    try{
                      final response = await Supabase.instance.client.from('restaurants').update({'urls': urls}).eq('id', restaurantId);
                      ref.read(signUpProvider.notifier).state = 2; // update the sign up state to 3
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> MenuCreationView(restaurantId)));
                    } catch (e){
                      ScaffoldMessenger.of(context).showSnackBar(ErrorMessage("Internarl error, try again!"));
                    }

                  }, 
                  child: Text("Next")
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
