import 'package:dinney_restaurant/pages/authentication/login_view.dart';
import 'package:dinney_restaurant/pages/authentication/sign_up_view.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://sxflfgrlveqeerzwlhhv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4ZmxmZ3JsdmVxZWVyendsaGh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0Njg0MjAsImV4cCI6MjA2OTA0NDQyMH0.ZPZypzCiVynG_BGbXvggr2XVl-KOqKpl_hJZ1pQeht8',
  );
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
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
          headlineMedium: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool toLogIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: (){
              setState(() {
                toLogIn = false;
              });
            },
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/test.jpeg"),
                  fit: BoxFit.cover
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: ElevatedButton(
              onPressed: () async{
                setState(() {
                  toLogIn = true;
                  //Navigator.push(context, MaterialPageRoute(builder: (context)=> MenuCreationView(7)));
                });
              }, 
              child: Text("Proceed"),
            ),
          ),
          AnimatedPositioned(
            bottom: toLogIn? 0 : -27.h, 
            duration: Duration(milliseconds: 300),
            child: Container(
              padding: EdgeInsets.all(16.sp),
              margin: EdgeInsets.only(bottom: 4.h),
              width: 80.w, 
              height: 23.h, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.sp)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Log in with your account", style: Theme.of(context).textTheme.headlineMedium,),
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
