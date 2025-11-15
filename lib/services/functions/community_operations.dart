import 'package:cloud_functions/cloud_functions.dart';

Future<void> sendNotification(String title, String body, List<dynamic> tokens, {String? image}) async {
  print("DEBUG -> sending notification:");
  print("title: $title");
  print("body: $body");
  print("token: $tokens");
  print("image: $image");

  for (var token in tokens) {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('sendNotification');

      final result = await callable.call(<String, dynamic>{
        'token': token.toString(),
        'title': title,
        'body': body,
        if (image != null) 'image': image,
      });

      print('Function result: ${result.data}');
    } catch (error) {
      print('🔥 Error sending notification: $error');
    }
  }
}

