import 'package:dinney_restaurant/main.dart';
import 'package:dinney_restaurant/main_wrapper.dart';
import 'package:dinney_restaurant/pages/authentication/gallery_setting_view.dart';
import 'package:dinney_restaurant/pages/authentication/location_selection.dart';
import 'package:dinney_restaurant/pages/authentication/menu_creation_view.dart';
import 'package:dinney_restaurant/pages/authentication/reset_password_view.dart';
import 'package:dinney_restaurant/pages/authentication/schedule_view.dart';
import 'package:dinney_restaurant/pages/home_view.dart';
import 'package:dinney_restaurant/pages/menu_view.dart';
import 'package:dinney_restaurant/pages/stats_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigation {
  AppNavigation._();
  static final _shellNavigatorHome = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorMenu = GlobalKey<NavigatorState>(debugLabel: 'shellMenu');
  static final _shellNavigatorStats = GlobalKey<NavigatorState>(debugLabel: 'shellStats');
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
        GoRoute(
          path: '/reset-password',
          builder: (context, state) =>  ResetPasswordView(),
        ),
        GoRoute(
          path: '/gallery/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return GallerySettingView(id);
          },
        ),
        GoRoute(
          path: '/menu_creation/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return MenuCreationView(id);
          },
        ),
        GoRoute(
          path: '/schedule/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ScheduleView(id: id,);
          },
        ),
        GoRoute(
          path: '/location/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return LocationSelection(id: id,);
          },
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
              //Branch Menu
              StatefulShellBranch(
                navigatorKey: _shellNavigatorMenu, 
              routes: <RouteBase>[
                GoRoute(
                  path: '/menu',
                  name: 'menu',
                  pageBuilder: (context, state) =>CustomTransitionPage(
                          child: MenuView(), 
                          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                              FadeTransition(opacity: animation, child: child),
                    ))
              ]),
              // // Branch Board
              StatefulShellBranch(
                  navigatorKey: _shellNavigatorStats,
                  routes: <RouteBase>[
                    GoRoute(
                        path: '/board',
                        name: 'board',
                        pageBuilder: (context, state) {
                          return CustomTransitionPage(
                            child: StatsView(), 
                            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                FadeTransition(opacity: animation, child: child),
                          );
                          }
                        ),
                  ]),
            ])
      ],
    );
}
