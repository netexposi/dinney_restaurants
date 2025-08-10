import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapsView extends StatefulWidget {
  LatLng location;
  final double borderRadius;
  final bool myLocationButton;

  MapsView({
    super.key,
    required this.location,
    required this.borderRadius,
    this.myLocationButton = false,
  });

  
  @override
  State<MapsView> createState() => MapsViewState();
}

class MapsViewState extends State<MapsView> {
  late GoogleMapController mapController;
  Marker? currentMarker; // store current marker


  @override
  void initState() {
    super.initState();
    // Initial marker
    currentMarker = Marker(
      markerId: const MarkerId("customMarker"),
      position: widget.location,
      infoWindow: const InfoWindow(
        title: "Custom Location",
        snippet: "Here is your marker",
      ),
    );
  }

  void setMarker(LatLng position) {
    setState(() {
      currentMarker = Marker(
        markerId: const MarkerId("customMarker"),
        position: position,
        infoWindow: const InfoWindow(
          title: "Custom Location",
        ),
      );
      mapController.animateCamera(CameraUpdate.newLatLng(currentMarker!.position));
    });
  }
  //TODO make it have a permission handler first
  Future<void> _goToMyLocation() async {
    Location locationService = Location();
    var currentLocation = await locationService.getLocation();

    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      LatLng myLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);

      mapController.animateCamera(
        CameraUpdate.newLatLng(myLatLng),
      );
      setMarker(myLatLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false, // we'll handle it manually
            myLocationEnabled: widget.myLocationButton,
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: widget.location,
              zoom: 10.0,
            ),
            markers: currentMarker != null ? {currentMarker!} : {},
            onTap: (latLng) {
              if(widget.myLocationButton){
                setMarker(latLng);
              }
            },
          ),
          if (widget.myLocationButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _goToMyLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
        ],
      ),
    );
  }
}
