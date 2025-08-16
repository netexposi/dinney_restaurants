// providers.dart
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBackgroundService {
  final Ref ref;
  RealtimeChannel? _channel;
  bool _isRunning = false;

  MyBackgroundService(this.ref);

  Future<void> startService({
  required String tableName,
  required String id,
}) async {
  if (_isRunning) return;
  _isRunning = true;
  print("started user data fetching");

  // Fetch current data first
  final response = await Supabase.instance.client
      .from(tableName)
      .select()
      .eq('uid', id)
      .maybeSingle();

  if (response != null) {
    ref.read(userDocumentsProvider.notifier).state =
        Map<String, dynamic>.from(response);
    print("initial User Data fetched");
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
          ref.read(userDocumentsProvider.notifier).state =
              payload.newRecord ?? {};
          print("updated User Data");
        },
      )
      .subscribe();
}


  void stopService() {
    if (!_isRunning) return;
    _isRunning = false;
    _channel?.unsubscribe();
    _channel = null;
  }
}

final backgroundServiceProvider = Provider<MyBackgroundService>((ref) {
  return MyBackgroundService(ref);
});
