import UIKit
import Flutter
import GoogleMaps // ✅ Import Google Maps
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Provide Google Maps API key
        GMSServices.provideAPIKey("AIzaSyCg4pGJ8ZCd8CaMNovlyOp5DOlCu8QFNOw") // ✅ Add your API key here
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set delegate for messaging
        Messaging.messaging().delegate = self
        
        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)
        
        // Note: Do not call application.registerForRemoteNotifications() here unconditionally.
        // Instead, handle permission requests in your Flutter code using firebase_messaging's requestPermission(),
        // which will trigger the iOS authorization prompt and register if granted.
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Handle APNs token registration and forward to Firebase
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    // Optional: Handle failure to register for remote notifications
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    // Handle FCM token refresh or initial receipt (with optional token for deletion cases)
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            print("Firebase registration token: \(fcmToken)")
            // You can send this token to your server if needed
        } else {
            print("Firebase registration token deleted")
            // Handle token revocation if relevant for your app
        }
    }
    
    // Present notifications when the app is in the foreground
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    // Handle user tapping on a notification (when app is in background or terminated)
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completionHandler: @escaping () -> Void) {
        // Optionally handle the notification data here (e.g., via Flutter method channel)
        completionHandler()
    }
}
