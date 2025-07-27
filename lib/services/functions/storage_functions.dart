import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

Future<String?> uploadImageToSupabase(File imageFile) async {
  final supabase = Supabase.instance.client;
  final bucketName = 'restaurants'; // change if you use a different bucket
  final fileExtension = imageFile.path.split('.').last;
  final fileName = '${const Uuid().v4()}.$fileExtension';

  try {
    // Upload the file
    final response = await supabase.storage
        .from(bucketName)
        .upload(fileName, imageFile);

    // Get the public URL
    final publicUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
    return publicUrl;
  } catch (e) {
    print('Upload failed: $e');
    return null;
  }
}
