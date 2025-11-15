import 'package:dinney_restaurant/firebase_options.dart';
import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/pages/authentication/login_view.dart';
import 'package:dinney_restaurant/pages/authentication/sign_up_view.dart';
import 'package:dinney_restaurant/services/functions/firebase_api_provider.dart';
import 'package:dinney_restaurant/services/functions/sound_player.dart';
import 'package:dinney_restaurant/services/functions/system_functions.dart';
import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/widgets/blurry_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: 'secondary',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await Supabase.initialize(
    url: 'https://sxflfgrlveqeerzwlhhv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4ZmxmZ3JsdmVxZWVyendsaGh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0Njg0MjAsImV4cCI6MjA2OTA0NDQyMH0.ZPZypzCiVynG_BGbXvggr2XVl-KOqKpl_hJZ1pQeht8',
  );
  SoundEffectPlayer.preload();
  final supabase = Supabase.instance.client;
  supabase.auth.onAuthStateChange.listen((data) {
    final event = data.event;

    if (event == AuthChangeEvent.passwordRecovery) {
      AppNavigation.navRouter.go('/reset-password');
    }
  });
  final session = supabase.auth.currentSession;
  if (session != null && session.isExpired == false) {
    await supabase.from("restaurants").select().eq("email", session.user.email!).single().then((response){
      print("The response is : $response");
      final id = response['id'];
      //function test if images are available;
      if(response['urls'] == null || response['urls'].length == 0){
        AppNavigation.navRouter.go("/gallery/$id");
      }
      //function test if menu is added
      else if(response['menu_id'] == null){
        AppNavigation.navRouter.go("/menu_creation/$id");
      }
      //function test if schedule is setup
      else if(response['schedule'] == null || response['schedule'].length == 0){
        AppNavigation.navRouter.go("/menu_creation/$id");
      } //function test if location is set
      else if(response['lat'] == null || response['lng'] == null || response['wilaya'] == null){
        AppNavigation.navRouter.go("/location/$id");
      }
      //function else go to home
      else{
        AppNavigation.navRouter.go("/home");
      }
    });
  }

  runApp(ProviderScope(child: const MyApp()));
}
void getLanguage(WidgetRef ref) async{
  final language = await Hive.openBox('Language');
  
  if(language.isNotEmpty){
    ref.read(languageStateProvider.notifier).state = language.values.last;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(firebaseInitProvider, (prev, next) {
      next.whenOrNull(
        data: (_) => print("✅ Firebase initialized successfully"),
        error: (err, _) => print("❌ Firebase init error: $err"),
      );
    });
    getLanguage(ref);
    return Sizer(builder: (BuildContext , Orientation , ScreenType ) {
      return MaterialApp.router(
      routerConfig: AppNavigation.navRouter,
      locale: S.delegate.supportedLocales[ref.watch(languageStateProvider)],
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
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
      final LanguageList = [
        S.of(context).english, 
        S.of(context).arabic,
        S.of(context).french
        ];
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
                      TextSpan(text: S.of(context).manage_your_orders, style: Theme.of(context).textTheme.headlineLarge),
                      TextSpan(text: S.of(context).easily, style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: secondaryColor))
                    ]
                  ),),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(toLogIn.notifier).state = true;
                    }, 
                    child: Text(S.of(context).get_started),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            bottom: ref.watch(toLogIn)? 0 : -50.h, 
            duration: Duration(milliseconds: 300),
            child: Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: BlurryContainer(
                padding: 16.sp,
                borderRadius: BorderRadius.circular(24.sp),
                child: Column(
                spacing: 16.sp,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(S.of(context).authentication_slogan, style: Theme.of(context).textTheme.headlineSmall,),
                    ElevatedButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginView()));
                      }, 
                      child: Text(S.of(context).sign_in)
                    ),
                    OutlinedButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpView()));
                      }, 
                      child: Text(S.of(context).create_account)
                    ),
                    Divider(indent: 24.sp, endIndent: 24.sp ,height: 2, color: tertiaryColor.withOpacity(0.5),),
                    OutlinedButton(
                      style: outlinedBeige.copyWith(
                        side: WidgetStateProperty.all<BorderSide>(BorderSide(color: tertiaryColor.withOpacity(0.5)))
                      ),
                      onPressed: (){
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: Text(S.of(context).select_your_language, style: Theme.of(context).textTheme.headlineSmall,),
                            content: SizedBox(
                              width: 80.w,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: LanguageList.length,
                                itemBuilder: (context, index){
                                  return ListTile(
                                    onTap: (){
                                      setLanguage(index);
                                      ref.read(languageStateProvider.notifier).state = index;
                                      Navigator.pop(context);
                                    },
                                    leading: Text(flagsList[index], style: TextStyle(fontSize: 24.sp),),
                                    title: Text(LanguageList[index], style: Theme.of(context).textTheme.bodyLarge,),
                                    trailing: ref.watch(languageStateProvider) == index ? Icon(Icons.check, color: secondaryColor,) : null,
                                  );
                                }),
                            ),
                          );
                        });
                      }, 
                      child: Text("${flagsList[ref.watch(languageStateProvider)]}  ${LanguageList[ref.watch(languageStateProvider)]}")
                    ),
                  ],
                ),
              ),
            )
          )
        ],
      )
    );
  }
}

