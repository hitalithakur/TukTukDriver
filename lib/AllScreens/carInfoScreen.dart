
import 'package:flutter/material.dart';
import 'package:uber_clone_driver/AllScreens/mainscreen.dart';
import 'package:uber_clone_driver/congifMaps.dart';
import 'package:uber_clone_driver/main.dart';
import 'package:uber_clone_driver/AllScreens/registerScreen.dart';

class CarInfoScreen extends StatelessWidget
{

  static const String idScreen = "carinfo";
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController = TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  String selectedCarType;
  List<String> carTypesList = ["male", "female"];

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 22.0,),
              Image.asset("images/rickshaw.png", width: 390.0, height: 250.0,),
              Padding(
                padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    Text("Enter Rickshaw Details", style: TextStyle(fontFamily: "Brand Bold", fontSize: 24.0),),

                    SizedBox(height: 26.0,),
                    TextField(
                      controller: carModelTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Vehicle Registration Number",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),

                    SizedBox(height: 10.0,),
                    TextField(
                      controller: carNumberTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Vehicle Number",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),

                    SizedBox(height: 10.0,),
                    TextField(
                      controller: carColorTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Vehicle Color",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),

                    SizedBox(height: 26.0,),

                    DropdownButton(
                      iconSize: 40,
                      hint: Text("Gender"),
                      value: selectedCarType,
                      onChanged: (newValue)
                      {
                        selectedCarType = newValue;
                        displayToastMessage(selectedCarType, context);
                      },
                      items: carTypesList.map((car)
                      {
                        return DropdownMenuItem(
                          child: new Text(car),
                          value: car,
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 42.0,),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: RaisedButton(
                        onPressed: ()
                        {
                          if(carModelTextEditingController.text.isEmpty)
                          {
                            displayToastMessage("Please provide car model.", context);
                          }
                          else if(carNumberTextEditingController.text.isEmpty)
                          {
                            displayToastMessage("Please provide car number.", context);
                          }
                          if(carColorTextEditingController.text.isEmpty)
                          {
                            displayToastMessage("Please provide car color.", context);
                          }
                          if(selectedCarType == null)
                          {
                            displayToastMessage("Please select car type.", context);
                          }
                          else
                          {
                            saveDriverCarInfo(context);
                          }
                        },
                        color: Theme.of(context).accentColor,
                        child: Padding(
                          padding: EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Next", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 26.0,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void saveDriverCarInfo(context)
  {
    String userId = currentFirebaseUser.uid;
    
    Map carInfoMap = 
    {
      "car_color": carColorTextEditingController.text,
      "car_number": carNumberTextEditingController.text,
      "car_model": carModelTextEditingController.text,
      "type": selectedCarType ,
    };
    
    driversRef.child(userId).child("car_details").set(carInfoMap);
    
    Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
  }
}
