// providers.dart
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBackgroundService {
  final Ref ref;
  RealtimeChannel? _channel;
  bool _isRunning = false;
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  Timer? _periodicCheck; // 👈 periodic internet check

  MyBackgroundService(this.ref);

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _getStreaming({
    required String tableName,
    required String id,
  }) async {
    try {
      if (!await _hasInternetConnection()) {
        ref.read(errorProvider.notifier).state = {
          "status": false,
          "reason": "no internet"
        };
        return;
      }

      // Fetch current data
      final response = await Supabase.instance.client
          .from(tableName)
          .select()
          .eq('uid', id)
          .maybeSingle();

      if (response != null) {
        ref.read(userDocumentsProvider.notifier).state =
            Map<String, dynamic>.from(response);
        ref.read(errorProvider.notifier).state = {
          "status": true,
          "reason": ""
        };
      } else {
        ref.read(errorProvider.notifier).state = {
          "status": false,
          "reason": "No user data found"
        };
      }

      // Subscribe to realtime changes
      _channel = Supabase.instance.client
          .channel('public:$tableName')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: tableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'uid',
              value: id,
            ),
            callback: (payload) {
              try {
                ref.read(userDocumentsProvider.notifier).state =
                    payload.newRecord ?? {};
                print("updated User Data");
              } catch (e, st) {
                print("Realtime update error: $e\n$st");
                ref.read(errorProvider.notifier).state = {
                  "status": false,
                  "reason": "error updating"
                };
              }
            },
          )
          .subscribe();
    } catch (e, st) {
      print("Error in getStreaming: $e\n$st");
      ref.read(errorProvider.notifier).state = {
        "status": false,
        "reason": "error starting"
      };
      _isRunning = false;
    }
  }

  Future<void> startService({
    required String tableName,
    required String id,
  }) async {
    if (_isRunning) return;
    _isRunning = true;
    print("started user data fetching");

    // connectivity_plus listener (fast)
    Connectivity().onConnectivityChanged.listen((result) async {
      final hasInternet = await _hasInternetConnection();
      if (result == ConnectivityResult.none || !hasInternet) {
        ref.read(errorProvider.notifier).state = {
          "status": false,
          "reason": "no internet"
        };
      } else {
        await _getStreaming(tableName: tableName, id: id);
      }
    });

    // 👇 periodic check (ensures no → yes also works)
    _periodicCheck = Timer.periodic(const Duration(seconds: 5), (_) async {
      final hasInternet = await _hasInternetConnection();
      final currentError = ref.read(errorProvider);

      if (!hasInternet) {
        if (currentError?["reason"] != "no internet") {
          ref.read(errorProvider.notifier).state = {
            "status": false,
            "reason": "no internet"
          };
        }
      } else {
        if (currentError?["reason"] == "no internet") {
          // just recovered → re-fetch
          await _getStreaming(tableName: tableName, id: id);
        }
      }
    });

    // initial check
    if (await _hasInternetConnection()) {
      await _getStreaming(tableName: tableName, id: id);
    } else {
      ref.read(errorProvider.notifier).state = {
        "status": false,
        "reason": "no internet"
      };
    }
  }

  void stopService() {
    if (!_isRunning) return;
    _isRunning = false;

    _channel?.unsubscribe();
    _channel = null;

    _connectivitySub?.cancel();
    _connectivitySub = null;

    _periodicCheck?.cancel();
    _periodicCheck = null;
  }
}

final backgroundServiceProvider = Provider<MyBackgroundService>((ref) {
  return MyBackgroundService(ref);
});
