import 'package:firebase_database/firebase_database.dart';

class History
{
  String paymentMethod;
  String createdAt;
  String status;
  String fares;
  String dropOff;
  String pickUp;

  History({this.paymentMethod, this.createdAt, this.status, this.fares, this.dropOff, this.pickUp});

  History.fromSnapShot(DataSnapshot snapshot)
  {
    paymentMethod = snapshot.value["payment_method"];
    createdAt = snapshot.value["created_at"];
    status = snapshot.value["status"];
    fares = snapshot.value["fares"];
    dropOff = snapshot.value["dropoff_address"];
    pickUp = snapshot.value["pickup_address"];

  }

}