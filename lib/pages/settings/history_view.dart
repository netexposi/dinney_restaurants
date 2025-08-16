import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryView extends ConsumerWidget{
  HistoryView({super.key});
  final orders = StateProvider<List<Map<String, dynamic>>?>((ref) => []);

  Future<void> getOrders(WidgetRef ref) async{
    final supabase = Supabase.instance.client;
    final response = await supabase.from("orders").select()
    .eq("id", ref.watch(userDocumentsProvider)["id"]);
    if(response.isEmpty){
      ref.read(orders.notifier).state = null;
    }
    ref.read(orders.notifier).state = response;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getOrders(ref);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: ref.watch(orders) != null? ref.watch(orders)!.isNotEmpty? Column(
          children: List.generate(ref.watch(orders)!.length, (index){
            return StatefulBuilder(builder: (context, setState){
              return SizedBox();
            });
          }),
        ) : LoadingSpinner()
        : Text("No Data Found")
      ),
    );
  }
}