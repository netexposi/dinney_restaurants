import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:dinney_restaurant/utils/variables.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryView extends ConsumerWidget{
  HistoryView({super.key});

  Future<List<Map<String, dynamic>>> fetchMenuItems(int id) async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('orders')
          .select()
          .eq("restaurant_id", id);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch menu items: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).order_history),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: FutureBuilder(
          future: fetchMenuItems(ref.watch(userDocumentsProvider)["id"]), 
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return LoadingSpinner();
            }else if(snapshot.hasError){
              return Center(child: Text("${S.of(context).error}: ${snapshot.error}"),);
            }else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(S.of(context).no_items),);
            }else {
              List<Map<String, dynamic>> completedOrders = snapshot.data!.where((order) => order['validated'] && DateTime.now().isAfter(DateTime.parse(order['delivery_at']))).toList();
              return ListView.builder(
                shrinkWrap: true,
                itemCount: completedOrders.length,
                itemBuilder: (context, index){
                  int numOrders = 0;
                  for (var item in completedOrders[index]['items']) {
                    numOrders += item['quantity'] as int;
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.sp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.sp)
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(completedOrders[index]['client_name'], style: Theme.of(context).textTheme.bodyLarge,),
                          Text(formatter.format(DateTime.parse(completedOrders[index]['delivery_at'])), style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: tertiaryColor),),
                        ],
                      ),
                      trailing: Container(
                    alignment: Alignment.center,
                    width: 30.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(24.sp),
                    ),
                    child: Text("$numOrders ${S.of(context).orders}", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
                  ),
                    ),
                  );
                });
            }
          }
        )
      ),
    );
  }
}