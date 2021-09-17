import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/Widget/AppBarTitle.dart';
import '../CustomColors.dart';


import 'dart:async';
import 'dart:convert';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'EasyWebViewImpl.dart';



class GoogleMaps extends StatefulWidget implements EasyWebViewImpl {

  final User _user;
  GoogleMaps(this._user);


  @override
  _GoogleMapsState createState() => _GoogleMapsState();

  @override
  // TODO: implement convertToWidgets
  bool get convertToWidgets => throw UnimplementedError();

  @override
  // TODO: implement headers
  Map<String, String> get headers => throw UnimplementedError();

  @override
  // TODO: implement height
  num get height => throw UnimplementedError();

  @override
  // TODO: implement isHtml
  bool get isHtml => throw UnimplementedError();

  @override
  // TODO: implement isMarkdown
  bool get isMarkdown => throw UnimplementedError();

  @override
  // TODO: implement onLoaded
  void Function() get onLoaded => throw UnimplementedError();

  @override
  // TODO: implement src
  String get src => throw UnimplementedError();

  @override
  // TODO: implement webAllowFullScreen
  bool get webAllowFullScreen => throw UnimplementedError();

  @override
  // TODO: implement widgetsTextSelectable
  bool get widgetsTextSelectable => throw UnimplementedError();

  @override
  // TODO: implement width
  num get width => throw UnimplementedError();
}


var geolocator = Geolocator();
var locationOptions =
LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
StreamSubscription<Position> positionStream =
geolocator.getPositionStream(locationOptions).listen((Position position) {
  print(position == null
      ? 'Unknown'
      : position.latitude.toString() + ', ' + position.longitude.toString());
});

class _GoogleMapsState extends State<GoogleMaps> {
  List<Marker> allMarkers = [];
  double lat = 31.955688;
  double lang = 35.917484;

  GoogleMapController _controllerMap;

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  LatLng _lastMapPosition = _center;





  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentPosition();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            initialCameraPosition:
            CameraPosition(target: _lastMapPosition, zoom: 9.0),
            markers: Set.from(allMarkers),
            onMapCreated: mapCreated,
          ),
        ),


        Align(
          alignment: Alignment.topRight,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () => getCurrentPosition(),
                  // materialTapTargetSize: MaterialTapTargetSize.padded,
                  // backgroundColor: Colors.green,
                  child:  Icon(
                    Icons.my_location,
                    size: 45.0,
                    color:CustomColors.firebaseYellow,
                  ),
                ),
              ),

            ],

          ),
        ),
      ]),
    );
  }



  void mapCreated(controller) {
    setState(() {
      _controllerMap = controller;
    });
  }

  void checkPermission() {
    geolocator.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });
    geolocator
        .checkGeolocationPermissionStatus(
        locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });
    geolocator.checkGeolocationPermissionStatus(
        locationPermission: GeolocationPermission.locationWhenInUse)
      ..then((status) {
        print('whenInUse status: $status');
      });
  }

  getCurrentPosition() async {
    checkPermission();
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    debugPrint("User location=> ");
    debugPrint(position.latitude.toString());

    debugPrint(position.longitude.toString());

    lat = position.latitude;
    lang = position.longitude;
    _lastMapPosition = new LatLng(lat, lang);
    _controllerMap.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(lat, lang), zoom:12.0, bearing: 45.0, tilt: 45.0),
    ));
    setState(() {


      allMarkers.add(Marker(
          markerId: MarkerId('myMarker'),
          draggable: true,

          onTap: () {},
          infoWindow: InfoWindow(title: 'Your Location'),
          position: _lastMapPosition));
    });
  }

  getAllMarkers(double lat, double long, int id,String name,
      String logofileimgurl) async {

    var name1 = parse(name);


    allMarkers.add(Marker(
        markerId: MarkerId(id.toString()),
        draggable: true,
        icon: await BitmapDescriptor.defaultMarker,
        onTap: () {

        },
        infoWindow: InfoWindow(title: name1.body.text.toString()  ),
        position: LatLng(lat, long)));
  }


}


