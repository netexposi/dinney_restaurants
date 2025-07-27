import 'package:dinney_restaurant/main.dart';
import 'package:dinney_restaurant/main_wrapper.dart';
import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  AppNavigation._();
  static final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorCommunity = GlobalKey<NavigatorState>(debugLabel: 'shellCommunity');
  static final _shellNavigatorBoard = GlobalKey<NavigatorState>(debugLabel: 'shellBoard');
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter navRouter = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      navigatorKey: _rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {return MyHomePage();}
        ),
        // Main Wrapper
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MainWrapper(navigationShell: navigationShell);
            },
            branches: <StatefulShellBranch>[
              //Branch Home
              StatefulShellBranch(
                  navigatorKey: _shellNavigatorHome,
                  routes: <RouteBase>[
                    GoRoute(
                        path: '/home',
                        name: 'home',
                        pageBuilder: (context, state) => CustomTransitionPage(
                          child: HomeView(), 
                          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                              FadeTransition(opacity: animation, child: child),
                    ),),
                    // GoRoute(
                    //   path: '/push_notification',
                    //   builder: (context, state) {
                    //   final message = state.extra;
                    //   return PushNotificationView(extra: message);
                    //   }
                    // ),
                  ]),
              // Branch Community
              // StatefulShellBranch(
              //   navigatorKey: _shellNavigatorCommunity, 
              // routes: <RouteBase>[
              //   GoRoute(
              //     path: '/community',
              //     name: 'community',
              //     pageBuilder: (context, state) =>CustomTransitionPage(
              //             child: const CommunitySearchView(), 
              //             transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              //                 FadeTransition(opacity: animation, child: child),
              //       ))
              // ]),
              // // Branch Board
              // StatefulShellBranch(
              //     navigatorKey: _shellNavigatorBoard,
              //     routes: <RouteBase>[
              //       GoRoute(
              //           path: '/board',
              //           name: 'board',
              //           pageBuilder: (context, state) {
              //             return CustomTransitionPage(
              //               child: ActivityBoard(preDefinedActivity: state.extra,), 
              //               transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              //                   FadeTransition(opacity: animation, child: child),
              //             );
              //             }
              //           ),
              //     ]),
            ])
      ],
    );
}
