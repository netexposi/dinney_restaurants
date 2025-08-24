import 'package:dinney_restaurant/firebase_options.dart';
import 'package:dinney_restaurant/pages/authentication/login_view.dart';
import 'package:dinney_restaurant/pages/authentication/sign_up_view.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async{
  //WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://sxflfgrlveqeerzwlhhv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4ZmxmZ3JsdmVxZWVyendsaGh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0Njg0MjAsImV4cCI6MjA2OTA0NDQyMH0.ZPZypzCiVynG_BGbXvggr2XVl-KOqKpl_hJZ1pQeht8',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? token = await messaging.getAPNSToken();
  print("FCM Token: $token");
  final supabase = Supabase.instance.client.auth.currentUser?.id;
  if(supabase != null){
    AppNavigation.navRouter.go("/home");
  }
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (BuildContext , Orientation , ScreenType ) {
      return MaterialApp.router(
      routerConfig: AppNavigation.navRouter,
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: secondaryColor,
          onSecondary: Colors.black,
          tertiary: tertiaryColor,
          onTertiary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
        ),
        dialogBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
          headlineMedium: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
          headlineSmall: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
           bodyLarge: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
          bodyMedium: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
          bodySmall: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: tertiaryColor
          ),
          labelSmall: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: blackButton,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: outlinedBeige,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(secondaryColor),
            textStyle: WidgetStateProperty.all<TextStyle>(
              Theme.of(context).textTheme.bodySmall!
          )
        )
      ),
      )
    );
    },);
  }
}

class MyHomePage extends ConsumerWidget {
  MyHomePage({super.key});
  
  final toLogIn = StateProvider<bool>((ref) => false);
  

  
    @override
    Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: (){
              ref.read(toLogIn.notifier).state = false;
            },
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/index.png"),
                  fit: BoxFit.cover
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: AnimatedOpacity(
              opacity: ref.watch(toLogIn)? 0 : 1,
              duration: Duration(milliseconds: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16.sp,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                    children: [
                      TextSpan(text: "Manage Your Orders", style: Theme.of(context).textTheme.headlineLarge),
                      TextSpan(text: "\nEasily", style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: secondaryColor))
                    ]
                  ),),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(toLogIn.notifier).state = true;
                    }, 
                    child: Text("Get Started"),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: ref.watch(toLogIn)? 0 : -27.h, 
            duration: Duration(milliseconds: 300),
            child: Container(
              padding: EdgeInsets.all(16.sp),
              margin: EdgeInsets.only(bottom: 4.h),
              width: 80.w, 
              height: 23.h, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.sp)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Sign in with dinney account", style: Theme.of(context).textTheme.headlineSmall,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginView()));
                    }, 
                    child: Text("Sign In")
                  ),
                  OutlinedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpView()));
                    }, 
                    child: Text("Create an account")
                  )
                ],
              ),
            )
          )
        ],
      )
    );
  }
}
