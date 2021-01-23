import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
// 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uber_clone_driver/Assistants/requestAssistant.dart';
import 'package:uber_clone_driver/DataHandler/appData.dart';
import 'package:uber_clone_driver/Models/address.dart';
import 'package:uber_clone_driver/Models/allUsers.dart';
import 'package:uber_clone_driver/Models/directionDetails.dart';
import 'package:uber_clone_driver/Models/history.dart';
import 'package:uber_clone_driver/congifMaps.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_driver/main.dart';

class AssistantMethods
{
  // static Future<String> searchCoordinateAddress(Position position, context) async
  // {
  //   String placeAddress = "";
  //   String st1, st2, st3, st4;
  //   String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
  //
  //   var response = await RequestAssistant.getRequest(url);
  //
  //   if(response != "failed")
  //   {
  //     //placeAddress = response["results"][0]["formatted_address"];
  //     st1 = response["results"][0]["address_components"][0]["long_name"];
  //     st2 = response["results"][0]["address_components"][1]["long_name"];
  //     st3 = response["results"][0]["address_components"][2]["long_name"];
  //     st4 = response["results"][0]["address_components"][3]["long_name"];
  //
  //     placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;
  //
  //     Address userPickUpAddress = new Address();
  //     userPickUpAddress.longitude = position.longitude;
  //     userPickUpAddress.latitude = position.latitude;
  //     userPickUpAddress.placeName = placeAddress;
  //
  //     Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
  //
  //   }
  //
  //   return placeAddress;
  // }

  static Future<DirectionDetails> obtainPlaceDirectionsDetails(LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude}, ${initialPosition.longitude}&destination=${finalPosition.latitude}, ${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if(res == "failed")
    {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;

  }

  static int calculateFares(DirectionDetails directionDetails)
  {
    //in terms USD
    //double timeTravelledFare = (directionDetails.durationValue / 60) * 0.10;
    double distanceTravelledFare = (directionDetails.distanceValue / 1000) * 8;
    double totalFareAmount = distanceTravelledFare; //timeTravelledFare + distanceTravelledFare;

    //Local Currency
    //1$ = 70Rs
    double totalLocalAmount = totalFareAmount; //* 70;
    if(rideType == "male")
    {
      double result = totalLocalAmount;
      return result.truncate();
    }
    else if(rideType == "female")
    {
      double result = totalLocalAmount;
      return result.truncate();
    }
    else
    {
      return totalLocalAmount.truncate();
    }

  }

  // static void getCurrentOnlineUserInfo() async
  // {
  //   firebaseUser = FirebaseAuth.instance.currentUser;
  //   String userId = firebaseUser.uid;
  //   DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);
  //
  //   reference.once().then((DataSnapshot dataSnapshot)
  //   {
  //     if(dataSnapshot.value != null)
  //     {
  //       userCurrentInfo = Users.fromSnapshot(dataSnapshot);
  //     }
  //   });
  // }

  static void disableHomeTabLiveLocationUpdates()
  {
    homeTabPageStreamSubscription.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }

  static void enableHomeTabLiveLocationUpdates()
  {
    homeTabPageStreamSubscription.resume();
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
  }

  static void retrieveHistInfo(context)
  {

    // Retrieve and display earnings
    driversRef.child(currentFirebaseUser.uid).child("earnings").once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value != null)
      {
        String earnings = dataSnapshot.value.toString();
        Provider.of<AppData>(context, listen: false).updateEarnings(earnings);
      }
    });

    // Retrieve and display trip history
    driversRef.child(currentFirebaseUser.uid).child("history").once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value != null)
      {
        // update the trip keys to provider
        Map<dynamic, dynamic> keys = dataSnapshot.value;
        int tripCounter = keys.length;
        Provider.of<AppData>(context, listen: false).updateTripCounter(tripCounter);

        List<String> tripHistoryKeys = [];

        keys.forEach((key, value) {
          tripHistoryKeys.add(key);
        });
        Provider.of<AppData>(context, listen: false).updateTripKeys(tripHistoryKeys);
        obtainTripRequestHistoryData(context);
      }
    });
  }

  static void obtainTripRequestHistoryData(context)
  {
    var keys = Provider.of<AppData>(context, listen: false).tripHistoryKeys;

    for(String key in keys)
    {
      newRequestRef.child(key).once().then((DataSnapshot snapshot) {
        if(snapshot.value != null)
        {
          var history = History.fromSnapShot(snapshot);
          Provider.of<AppData>(context, listen: false).updateTripHistoryData(history);
        }
      });
    }
  }

  static String formatTripDate(String date)
  {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDate;
  }
}