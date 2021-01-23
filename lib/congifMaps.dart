import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_clone_driver/Models/allUsers.dart';
import 'package:uber_clone_driver/Models/drivers.dart';

String mapKey = "AIzaSyCMP2_zI0MY984ob8WeZeXGR8Mm1UUTYfY";

User firebaseUser;

Users userCurrentInfo;

User currentFirebaseUser;

StreamSubscription<Position> homeTabPageStreamSubscription;

StreamSubscription<Position> rideStreamSubscription;

final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

Drivers driversInformation;

String title = "";

double starCounter = 0.0;

String rideType = "";