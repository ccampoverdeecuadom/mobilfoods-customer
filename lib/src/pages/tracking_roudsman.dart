import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/src/controllers/tracking_controller.dart';
import 'package:customer/src/models/address.dart';
import 'package:customer/src/models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class TrackingRoundsman extends StatefulWidget {
  final RouteArgument routeArgument;

  TrackingRoundsman({Key key, this.title, this.routeArgument})
      : super(key: key);
  final String title;

  @override
  _TrackingRoundsmanState createState() => _TrackingRoundsmanState();
}

class _TrackingRoundsmanState extends StateMVC<TrackingRoundsman> {
  TrackingController _con;
  Address currentDriverAddress;
  String distance;
  String duration;
  String goTo;

  _TrackingRoundsmanState() : super(TrackingController()) {
    _con = controller;
  }

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  double zoom = 17;

  CameraPosition initialLocation;

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load("assets/img/marker_icon.png");
    return byteData.buffer.asUint8List();
  }

  goToDriverLocation() async {
    LocationData locationDataDriver = LocationData.fromMap({
      "latitude": currentDriverAddress.latitude,
      "longitude": currentDriverAddress.longitude
    });
    Uint8List imageData = await getMarker();
    updateMarkerAndCircle(locationDataDriver, imageData);
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          visible: true,
          infoWindow: distance != null && duration != null
              ? InfoWindow(title: distance + " " + duration)
              : _con.order.driver != null
                  ? InfoWindow(title: _con.order.driver.name)
                  : InfoWindow(title: 'Conductor'),
          // rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          // flat: true,
          // anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Theme.of(context).accentColor,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
      if (_controller != null) {
        _controller
            .animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
          // bearing: 192.8334901395799,
          bearing: 90.0,
          target: LatLng(newLocalData.latitude, newLocalData.longitude),
          tilt: 0,
          zoom: zoom,
        )));
        updateMarkerAndCircle(newLocalData, imageData);
      }
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller
              .animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
                  // bearing: 192.8334901395799,
                  bearing: 90.0,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: zoom)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void initState() {
    _con.order = (widget.routeArgument?.param as TrackingController).order;
    _con.orderStatus =
        (widget.routeArgument?.param as TrackingController).orderStatus;
    loadDriverLocation();
    super.initState();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  loadDriverLocation() {
    FirebaseFirestore.instance
        .collection("locations")
        .doc(_con.order.driver.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.data() == null) {
        Future.delayed(Duration(milliseconds: 2000), () {
          _con.listenForOrder(
              orderId: _con.order.id, message: "Localizando al Conductor");
          loadDriverLocation();
        });
      } else {
        setState(() => {
              currentDriverAddress = new Address.newLatLgn(
                  snapshot.data()['latitude'], snapshot.data()['longitude']),
              distance = snapshot.data()['distance'],
              duration = snapshot.data()['duration'],
              goTo = snapshot.data()['goTo'],
              goToDriverLocation()
            });
      }
    }).onError((handleError) => {
              print(handleError),
              Future.delayed(Duration(milliseconds: 2000), () {
                _con.listenForOrder(
                    orderId: _con.order.id,
                    message: "Localizando al Conductor");
                loadDriverLocation();
              })
            });
    print(currentDriverAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            currentDriverAddress == null ||
                    currentDriverAddress.isLatLnUnknown()
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: initialLocation = CameraPosition(
                      target: LatLng(currentDriverAddress.latitude,
                          currentDriverAddress.longitude),
                      zoom: zoom,
                    ),
                    markers: Set.of((marker != null) ? [marker] : []),
                    circles: Set.of((circle != null) ? [circle] : []),
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      goToDriverLocation();
                    },
                  ),
            Container(
              height: 110,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _con.order?.orderStatus?.id == '5'
                      ? Container(
                    width: 60,
                    height: 70,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.2)),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 32,
                    ),
                  )
                      : Container(
                    width: 60,
                    height: 70,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        Theme.of(context).hintColor.withOpacity(0.1)),
                    child: Icon(
                      Icons.update,
                      color: Theme.of(context).hintColor.withOpacity(0.8),
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 15),
                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              distance == null
                                  ? SizedBox(
                                height: 0,
                              )
                                  : Text("Distancia: " +
                                  distance),
                              duration == null
                                  ? SizedBox(
                                height: 0,
                              )
                                  : Text("Tiempo: " +
                                  duration),
                              Text(
                                "Repartidor",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Text(
                                _con.order.driver.name ?? 'Sin nombre'  ,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.caption,
                              ),
                              Text(
                                "Camino a " + goTo,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
