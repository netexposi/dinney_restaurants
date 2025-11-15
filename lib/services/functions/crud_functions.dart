import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> updateFCM(String id, String token) async {
  try {
    final response = await Supabase.instance.client
        .from("clients")
        .update({
          "fcm_token": token,
        })
        .eq("uid", id)
        .select(); // Select returns the updated rows

    // response is a List of updated rows
    if (response.isNotEmpty) {
      print("Updated successfully: $response");
      return true;
    } else {
      print("No rows updated for uid: $id");
      return false;
    }
  } catch (e) {
    print("Error updating FCM: $e");
    return false;
  }
}
