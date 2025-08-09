import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

class MapsView extends StatefulWidget {
  final LatLng location;
  const MapsView({super.key, required this.location});

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  late GoogleMapController mapController;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.sp),
      child: GoogleMap(
        myLocationButtonEnabled: false,
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: widget.location,
          zoom: 10.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("customMarker"),
            position: widget.location,
            infoWindow: const InfoWindow(
              title: "Custom Location",
              snippet: "Here is your marker",
            ),
          ),
        },
      ),
    );
  }
}