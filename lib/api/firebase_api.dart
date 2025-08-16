// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   try {
//     await Hive.initFlutter();
//     Hive.registerAdapter(NotificationAdapter());
//     final box = await Hive.openBox<Notifications>('notifications');
    
//     final notification = Notifications(
//       id: message.messageId!,
//       title: message.notification?.title ?? 'No Title',
//       body: message.notification?.body ?? 'No Body',
//       viewed: false,
//       media: message.notification?.android?.imageUrl ?? '',
//     );
//     await box.add(notification);
//     AppNavigation.navRouter.push('/push_notification', extra: notification);
//   } catch (e) {
//     print('Error handling background message: $e');
//   }
// }

// class FirebaseApi {
//   final _firebaseMessaging = FirebaseMessaging.instance;
//   final _androidChannel = const AndroidNotificationChannel(
//     'push_channel', 
//     'Updates Notifications',
//     description: 'This channel is used for pushed notifications',
//     importance: Importance.defaultImportance,
//   );
//   final _localNotifications = FlutterLocalNotificationsPlugin();

//   Future<void> handleMessage(RemoteMessage? message) async {
//     if (message == null) return;
//     await Hive.initFlutter();
//     Hive.registerAdapter(NotificationAdapter());
//     final box = await Hive.openBox<Notifications>('notifications');

//     final notification = Notifications(
//       id: message.messageId!,
//       title: message.notification?.title ?? 'No Title',
//       body: message.notification?.body ?? 'No Body',
//       viewed: false,
//       media: message.notification?.android?.imageUrl ?? '',
//     );
//     await box.add(notification);
//     AppNavigation.navRouter.push('/push_notification', extra: notification);
//   }

//   Future<void> initLocalNotification() async {
//     try {
//       const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//       // const iOS = IOSInitializationSettings(); // Uncomment if iOS support is needed
//       const settings = InitializationSettings(android: android);
//       await _localNotifications.initialize(settings);
//     } catch (e) {
//       print('Error initializing local notifications: $e');
//     }
//   }

//   Future<void> initPushNotification() async {
//     try {
//       await _firebaseMessaging.setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );

//       FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//       FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

//       FirebaseMessaging.onMessage.listen((event) async {
//         final notification = event.notification;
//         if (notification == null) return;

//         try {
//           final Uint8List imageBytes = await networkImageToUint8List(notification.android!.imageUrl!);
//           String title = notification.title!;
//           String body = notification.body!;
//           if(notification.title!.contains("follower")){
//             title = title.replaceAll('follower', S.current.new_follower);
//           }
//           if(notification.body!.contains("Meeting")){
//             body = body.replaceAll('Meeting', S.current.meeting);
//             body = body.replaceAll('At', S.current.at);
//             body = body.replaceAll('In', S.current.in_word);
//           }
//           await _localNotifications.show(
//             notification.hashCode,
//             title,
//             body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(
//                 _androidChannel.id,
//                 _androidChannel.name,
//                 channelDescription: _androidChannel.description,
//                 importance: Importance.high,
//                 visibility: NotificationVisibility.public,
//                 priority: Priority.high,
//                 icon: '@mipmap/ic_launcher',
//                 largeIcon: ByteArrayAndroidBitmap(imageBytes)
//               ),
//             ),
//             payload: jsonEncode(event.toMap()),
//           );
//         } catch (e) {
//           print('Error showing local notification: $e');
//         }
//       });
//     } catch (e) {
//       print('Error initializing push notifications: $e');
//     }
//   }

//   Future<void> initNotification() async {
//     try {
//       await _firebaseMessaging.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );
//       token = await _firebaseMessaging.getToken();
//       await initLocalNotification();
//       await initPushNotification();
//     } catch (e) {
//       print('Error initializing notifications: $e');
//     }
//   }
// }