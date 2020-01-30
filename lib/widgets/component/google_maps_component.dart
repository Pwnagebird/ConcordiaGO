import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:concordia_go/blocs/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:concordia_go/utilities/concordia_constants.dart' as concordia_constants;

class GoogleMapsComponent extends StatefulWidget {
  @override
  State<GoogleMapsComponent> createState() => GoogleMapsComponentState();
}

class GoogleMapsComponentState extends State<GoogleMapsComponent> {
  Completer<GoogleMapController> _controller = Completer();
  bool polygonVisibility = true;

  void _infoPanel(String buildingCode) {
    print(buildingCode);
    // This method is triggered when a polygon is clicked. Currently it only prints the building code for the building you tap
  }

  Set<Polygon> buildingPolygons() {
    Set<Polygon> allBuildings = Set();
    for (int i = 0; i < concordia_constants.buildingCoordinates.length; i++) {
      List<LatLng> vertexCoordinates = List();
      List<double> xCoordinates = concordia_constants.buildingCoordinates[i]['xcoords'] as List<double>;
      List<double> yCoordinates = concordia_constants.buildingCoordinates[i]['ycoords'] as List<double>;
      for (int j = 0; j < (concordia_constants.buildingCoordinates[i]['xcoords'] as List<double>).length; j++) {
        vertexCoordinates.add(LatLng(xCoordinates[j], yCoordinates[j]));
      }

      allBuildings.add(Polygon(
        points: vertexCoordinates,
        visible: polygonVisibility,
        consumeTapEvents: true,
        onTap: () => _infoPanel(concordia_constants.buildingCoordinates[i]['code']),
        polygonId: PolygonId(concordia_constants.buildingCoordinates[i]['Building']),
        fillColor: Colors.redAccent.withOpacity(0.15),
        strokeColor: Colors.red,
        strokeWidth: 2,
      ));
    }
    return allBuildings;
  }

  Future<void> _switchCampus(LatLng currentPosition) async {
    double distanceToSGW =
        await Geolocator().distanceBetween(currentPosition.latitude, currentPosition.longitude, concordia_constants.sgwCoordinates.latitude, concordia_constants.sgwCoordinates.longitude);
    double distanceToLoyola =
        await Geolocator().distanceBetween(currentPosition.latitude, currentPosition.longitude, concordia_constants.loyolaCoordinates.latitude, concordia_constants.loyolaCoordinates.longitude);

    if (distanceToSGW < distanceToLoyola) {
      BlocProvider.of<MapBloc>(context).add(CameraMove(concordia_constants.loyolaCoordinates, 16.5, false));
    } else {
      BlocProvider.of<MapBloc>(context).add(CameraMove(concordia_constants.sgwCoordinates, 16.5, false));
    }
  }

  Future<void> _goToLocation(LatLng coordinates, double zoom) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: coordinates, zoom: zoom)));
  }

  Future<void> _zoomIn() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.zoomOut());
  }

  Future<LatLng> _getMyLocation() async {
    Position position;
    try {
      position = await Geolocator().getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } on PlatformException {
      print('Location access was denied.');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final bloc = BlocProvider.of<MapBloc>(context);
    LatLng currentCameraPosition = concordia_constants.sgwCoordinates;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlocListener<MapBloc, MapState>(
            listener: (context, state) {
              if (state is ExplorationMap) {
                _goToLocation(state.cameraPosition, state.zoom);
              }
            },
            child: BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                Set<Marker> markers;
                if (state is InitialMap) {
                  markers = state.markers;
                } else if (state is ExplorationMap) {
                  markers = state.markers;
                }
                return Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(concordia_constants.sgwCoordinates.latitude, concordia_constants.sgwCoordinates.longitude),
                      zoom: 15.5,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    buildingsEnabled: false,
                    markers: markers,
                    polygons: buildingPolygons(),
                    onCameraMove: (value) {
                      currentCameraPosition = value.target;
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            height: screenHeight / 13,
            width: screenHeight / 13,
            padding: EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.gps_fixed, size: screenWidth / 15),
              backgroundColor: Color(0xff800206),
              onPressed: () {
                GeolocationStatus status;
                Geolocator().checkGeolocationPermissionStatus().then((result) => status = result);
                _getMyLocation().then((myLocation) {
                  if (myLocation != null) {
                    bloc.add(CameraMove(myLocation, 17.5, false));
                  } else if (status == GeolocationStatus.denied) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Allow location permissions to access My Location'),
                    ));
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Location permission status unknown.'),
                    ));
                  }
                });
              },
            ),
          ),
          Container(
            height: screenHeight / 13,
            width: screenHeight / 13,
            padding: EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.zoom_in, size: screenWidth / 12),
              backgroundColor: Color(0xff800206),
              onPressed: () {
                _zoomIn();
              },
            ),
          ),
          Container(
            height: screenHeight / 13,
            width: screenHeight / 13,
            padding: EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.zoom_out, size: screenWidth / 12),
              backgroundColor: Color(0xff800206),
              onPressed: () {
                _zoomOut();
              },
            ),
          ),
          Container(
            height: screenHeight / 10,
            width: screenHeight / 10,
            padding: EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.sync, size: screenWidth / 10),
              backgroundColor: Color(0xff800206),
              onPressed: () {
                _switchCampus(currentCameraPosition);
              },
            ),
          ),
        ],
      ),
    );
  }
}