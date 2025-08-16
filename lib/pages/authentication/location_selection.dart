import 'package:dinney_restaurant/utils/app_navigation.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/widgets/circles_indicator.dart';
import 'package:dinney_restaurant/widgets/maps_view.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationSelection extends ConsumerWidget{
  LocationSelection({super.key});
  final mapKey = GlobalKey<MapsViewState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            spacing: 16.sp,
            children: [
              ThreeDotsIndicator(),
              Text(
                "Select Location",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                key: mapKey,
                width: 100.w,
                height: 50.h,
                child: MapsView(
                  location: LatLng(28.0290, 1.6666),
                  borderRadius: 24.sp,
                  myLocationButton: true,
                ),
              ),
              Align(
                child: ElevatedButton(
                  onPressed: () async{
                    ref.read(savingLoadingButton.notifier).state = true;
                    final supabase = Supabase.instance.client;
                    LatLng markerPosition = mapKey.currentState?.currentMarker?.position?? LatLng(28.0290, 1.6666);
                    await supabase.from("restaurants")
                    .update({
                      "lat" : markerPosition.latitude,
                      "lng" : markerPosition.longitude,
                    }).eq("uid", supabase.auth.currentUser!.id)
                    .whenComplete((){
                      ref.read(savingLoadingButton.notifier).state = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SuccessMessage("Account Created Successfully")
                      );
                      ref.read(signUpProvider.notifier).state = 0; 
                      AppNavigation.navRouter.go("/home");
                    });
                  }, 
                  child: Text("Start Working")
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}