import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

void main () => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

    
    String advice = "";
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings androidInitializationSettings;
    IOSInitializationSettings iosInitializationSettings;
    InitializationSettings initializationSettings;

    @override
    void initState(){
      super.initState();
      fetchApi();
      initializing();
    }

    var uri = "https://api.adviceslip.com/advice";

    Future fetchApi() async{
      var response = await http.get(uri);
      var data = jsonDecode(response.body);
      print(data['slip']['advice']);
      
      setState(() {
        advice = data['slip']['advice'];
      });

      return data;

    }

    void initializing() async{
      androidInitializationSettings = AndroidInitializationSettings('app_icon');
      iosInitializationSettings = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
      initializationSettings = InitializationSettings(androidInitializationSettings,iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
    } 

    Future <String> notification(){
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        "channel_Id", "channel_Name", "channel_Description",priority: Priority.High,importance: Importance.Max,ticker: 'test');
      IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
      NotificationDetails notificationDetails = NotificationDetails(androidNotificationDetails, iosNotificationDetails);
      flutterLocalNotificationsPlugin.show(0, "Daily Advice", advice, notificationDetails);
    }

    Future <void> onSelectNotification(String payload){
      if(payload != null){
        print(payload);
      }
    }

    Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async{
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: (){},
            child: Text("Okay"),
          )
        ],
      );
    }
    
    void showNotification() async{
      await notification();
      fetchApi();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      appBar: AppBar(
        title: Text("Advice App"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: showNotification,
              child: Text("Show Advice Now"))
          ],
        ),
      ),
    );
  }
}