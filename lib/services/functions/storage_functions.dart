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

Future<bool?> removeImageFromSupabase(String url) async{
  final parts = url.split("/storage/v1/object/public/")[1].split("/");
  final bucket = parts.first; // "restaurants"
  final path = parts.sublist(1).join("/");
  final response = await Supabase.instance.client.storage
      .from(bucket)
      .remove([path]);
  if (response.isEmpty) {
    print("✅ File deleted successfully");
    return true;
  } else {
    print("⚠️ Error deleting file: $response");
    return false;
  }
}