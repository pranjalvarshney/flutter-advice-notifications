import 'dart:async';
import 'dart:convert';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

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
  var adviceid;
  var timeInterval = 1;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  @override
  void initState() {
    super.initState();
    fetchApi();
    initializing();
  }

  var uri = "https://api.adviceslip.com/advice";

  Future fetchApi() async {
    var response = await http.get(uri);
    var data = jsonDecode(response.body);
    print(data['slip']['advice']);

    setState(() {
      adviceid = data['slip']['id'];
      advice = data['slip']['advice'];
    });

    return data;
  }

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> notification() {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            "channel_Id", "channel_Name", "channel_Description",
            priority: Priority.High,
            importance: Importance.Max,
            ticker: 'test');
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails =
        NotificationDetails(androidNotificationDetails, iosNotificationDetails);
    flutterLocalNotificationsPlugin.show(
        0, "Daily Advice", advice, notificationDetails);
  }

  Future<void> onSelectNotification(String payload) {
    if (payload != null) {
      print(payload);
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {},
          child: Text("Okay"),
        )
      ],
    );
  }

  // void showNotification() async{
  //       await
  //       // showNotification();
  //     }

  void showNote() {
    Timer.periodic(new Duration(seconds: timeInterval), (call) {
      print("hi");
      notification();
      fetchApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text("Daily Advice"),
        centerTitle: true,
        backgroundColor: Colors.black26,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.2),
                  borderRadius: BorderRadius.circular(25)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text("Advice",
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 20))),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      advice.toString(),
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  splashColor: Colors.blueAccent,
                  color: Colors.white,
                  onPressed: fetchApi,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                      child: Text(
                    "Show more",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ))),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      child: Text("Advanced Settings",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w400,
                              fontSize: 20))),
                  ToggleSwitch(
                      minWidth: 60.0,
                      cornerRadius: 20,
                      activeBgColor: Colors.green,
                      activeTextColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveTextColor: Colors.white,
                      activeColors: [Colors.green, Colors.red.withOpacity(.7)],
                      labels: ['On', 'Off'],
                      onToggle: (index) {
                        print('switched to: $index');
                      }),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                    "Get an advice automatically in your notifications. Set the time interval",
                    style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w300,
                        fontSize: 17))),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  child: Icon(Icons.remove),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)
                  ),
                  onPressed: () {
                    setState(() {
                      timeInterval = timeInterval - 1;
                    });
                  },
                ),
                Text(timeInterval.toString(), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),),
                RaisedButton(
                  child: Icon(Icons.add),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)
                  ),
                  onPressed: () {
                    setState(() {
                      timeInterval = timeInterval + 1;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  splashColor: Colors.blueAccent,
                  color: Colors.white,
                  onPressed: showNote,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                      child: Text(
                    "Save",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ))),
            ),
          ],
        ),
      ),
    );
  }
}
