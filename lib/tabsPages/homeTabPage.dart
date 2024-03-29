import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_clone_driver/AllScreens/registerScreen.dart';
import 'package:uber_clone_driver/Assistants/assisstantMethods.dart';
import 'package:uber_clone_driver/Models/drivers.dart';
import 'package:uber_clone_driver/Notifications/pushNotificationService.dart';
import 'package:uber_clone_driver/congifMaps.dart';
import 'package:uber_clone_driver/main.dart';

class HomeTabPage extends StatefulWidget
{
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController newGoogleMapController;



  var geoLocator = Geolocator();

  String driverStatusText = "Offline now - Go Online  ";

  Color driverStatusColor = Colors.black;

  bool isDriverAvailable = false;

  @override
  void initState() {
    super.initState();

    getCurrentDriverInfo();
  }

  getRideType()
  {
    driversRef.child(currentFirebaseUser.uid).child("car_details").child("type").once().then((DataSnapshot snapshot) {
      if(snapshot.value != null)
      {
        setState(() {
          rideType = snapshot.value.toString();
        });
      }
    });
  }

  getRatings()
  {
    // Update Ratings
    driversRef.child(currentFirebaseUser.uid).child("ratings").once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value != null)
      {
        double ratings = double.parse(dataSnapshot.value.toString());
        setState(() {
          starCounter = ratings;
        });
        if(starCounter <= 1)
        {
          setState(() {
            title = "Very Bad";
          });
          return;
        }
        if(starCounter <= 2)
        {
          setState(() {
            title = "Bad";
          });
          return;
        }
        if(starCounter <= 3)
        {
          setState(() {
            title = "Good";
          });
          return;
        }
        if(starCounter <= 4)
        {
          setState(() {
            title = "Very Good";
          });
          return;
        }
        if(starCounter <= 5)
        {
          setState(() {
            title = "Excellent";
          });
          return;
        }
      }
    });
  }

  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //String address = await AssistantMethods.searchCoordinateAddress(position, context);
    //print("This is your Address :: " + address);
  }

  void getCurrentDriverInfo() async
  {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    
    driversRef.child(currentFirebaseUser.uid).once().then((DataSnapshot dataSnapShot){
      if(dataSnapShot.value != null)
      {
        driversInformation = Drivers.fromSnapShot(dataSnapShot);
      }
    });
    
    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();

    AssistantMethods.retrieveHistInfo(context);
    getRatings();
    getRideType();
  }

  @override
  Widget build(BuildContext context)
  {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: HomeTabPage._kGooglePlex,
          myLocationEnabled : true,
          //zoomGesturesEnabled: true,
          //zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController controller)
          {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locatePosition();
          },
        ),

        //online offline driver container
        Container(
          height: 140.0,
          width: double.infinity,
          color: Colors.black54,

        ),

        Positioned(
          top: 60.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: RaisedButton(
                  onPressed: ()
                  {
                    if(isDriverAvailable != true)
                    {
                      makeDriverOnlineNow();
                      getLocationLiveUpdates();

                      setState(() {
                        driverStatusColor = Colors.green;
                        driverStatusText = "Online Now  ";
                        isDriverAvailable = true;
                      });

                      displayToastMessage("You are Online now.", context);
                    }
                    else
                    {
                      makeDriverOfflineNow();
                      setState(() {
                        driverStatusColor = Colors.black;
                        driverStatusText = "Offline now - Go Online  ";
                        isDriverAvailable = false;
                      });
                      displayToastMessage("You are Offline now.", context);
                    }
                  },
                  color: driverStatusColor,
                  child: Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(driverStatusText, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                        Icon(Icons.phone_android, color: Colors.white, size: 26.0,),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void makeDriverOnlineNow() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);


    rideRequestRef.set("searching");
    rideRequestRef.onValue.listen((event) {

    });
  }

  void getLocationLiveUpdates()
  {

    homeTabPageStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if(isDriverAvailable == true)
      {
        Geofire.setLocation(currentFirebaseUser.uid, position.latitude, position.longitude);
      }
      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef = null;
  }
}
