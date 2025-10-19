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
  Timer? _periodicCheck;
  int _failedChecks = 0; // track consecutive failures

  MyBackgroundService(this.ref);

  /// Reliable internet check using HTTP request
  Future<bool> _hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) return false;

    try {
      final response = await HttpClient()
          .getUrl(Uri.parse('https://www.google.com'))
          .then((r) => r.close())
          .timeout(const Duration(seconds: 3));

      final ok = response.statusCode == 200;
      print("🔍 Internet check: $ok");
      return ok;
    } catch (e) {
      print("❌ Internet check failed: $e");
      return false;
    }
  }

  /// Subscribe to realtime data
  Future<void> _getStreaming({
    required String tableName,
    required String id,
  }) async {
    try {
      // Retry once before marking no internet
      if (!await _hasInternetConnection()) {
        await Future.delayed(const Duration(seconds: 1));
        if (!await _hasInternetConnection()) {
          ref.read(errorProvider.notifier).state = {
            "status": false,
            "reason": "no internet",
          };
          return;
        }
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
        ref.read(errorProvider.notifier).state = {"status": true, "reason": ""};
      } else {
        ref.read(errorProvider.notifier).state = {
          "status": false,
          "reason": "No user data found",
        };
      }

      // Subscribe to realtime updates
      _channel?.unsubscribe();
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
                print("✅ Realtime user data updated");
              } catch (e, st) {
                print("❌ Realtime update error: $e\n$st");
                ref.read(errorProvider.notifier).state = {
                  "status": false,
                  "reason": "error updating",
                };
              }
            },
          )
          .subscribe();
    } catch (e, st) {
      print("❌ Error in _getStreaming: $e\n$st");
      ref.read(errorProvider.notifier).state = {
        "status": false,
        "reason": e.toString(),
      };
      _isRunning = false;
    }
  }

  /// Start the service (only once)
  Future<void> startService({
    required String tableName,
    required String id,
  }) async {
    if (_isRunning) return;
    _isRunning = true;
    print("🚀 Started background service for $tableName → $id");

    // Clean old listeners if any
    _connectivitySub?.cancel();

    // Connectivity listener
        Connectivity().onConnectivityChanged.listen((result) async {
      final hasInternet = await _hasInternetConnection();
      if (result == ConnectivityResult.none || !hasInternet) {
        print("⚠️ Lost internet connection");
        ref.read(errorProvider.notifier).state = {
          "status": false,
          "reason": "no internet",
        };
      } else {
        print("🌐 Internet restored, re-fetching data...");
        await _getStreaming(tableName: tableName, id: id);
      }
    });

    // Periodic internet recheck (every 5s)
    _periodicCheck = Timer.periodic(const Duration(seconds: 5), (_) async {
      final hasInternet = await _hasInternetConnection();
      final currentError = ref.read(errorProvider);

      if (!hasInternet) {
        _failedChecks++;
        if (_failedChecks >= 2 &&
            currentError?["reason"] != "no internet") {
          print("🚫 Internet still unavailable after 2 checks");
          ref.read(errorProvider.notifier).state = {
            "status": false,
            "reason": "no internet",
          };
        }
      } else {
        if (_failedChecks > 0) {
          print("✅ Internet restored after ${_failedChecks} failed checks");
          _failedChecks = 0;
        }

        if (currentError?["reason"] == "no internet") {
          await _getStreaming(tableName: tableName, id: id);
        }
      }
    });

    // Initial startup check
    if (await _hasInternetConnection()) {
      await _getStreaming(tableName: tableName, id: id);
    } else {
      print("❌ No internet on startup");
      ref.read(errorProvider.notifier).state = {
        "status": false,
        "reason": "no internet",
      };
    }
  }

  /// Stop everything cleanly
  void stopService() {
    if (!_isRunning) return;
    _isRunning = false;
    print("🛑 Stopping background service");

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
