import 'dart:convert';

import 'package:enx_flutter_plugin/enx_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'VideoConferenceScreen.dart';

void main() {
  runApp(MaterialApp(
    title: "Sample App",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple,
        accentColor: Colors.pinkAccent),
    home: MyApp(),
    /*  routes: <String, WidgetBuilder>{
      '/Conference': (context) => MyConfApp(
            token: _State.token,
          )
    },*/
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  /*Your webservice host URL, Keet the defined host when kTry = true */
  static final String kBaseURL = "https://meeting-demo-qa.enablex.io/";
  /* To try the app with Enablex hosted service you need to set the kTry = true */
  static bool kTry = false;
  /*Use enablec portal to create your app and get these following credentials*/
  /*Use enablec portal to create your app and get these following credentials*/
  static final String kAppId = "App-ID";
  static final String kAppkey = "App-Key";
  var header = (kTry)
      ? {
          "x-app-id": kAppId,
          "x-app-key": kAppkey,
          "Content-Type": "application/json"
        }
      : {"Content-Type": "application/json"};

  TextEditingController nameController = TextEditingController();
  TextEditingController roomIdController = TextEditingController();
  static String token = "";
  String role = '', roomID = '';
  Future<void> createRoomvalidations() async {
    if (nameController.text.isEmpty) {
      isValidated = false;
      Fluttertoast.showToast(
          msg: "Please Enter your name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      isValidated = true;
    }
  }

  Future<void> joinRoomValidations() async {
    // await _handleCameraAndMic();
    if (nameController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Enter your name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      isValidated = false;
    } else if (roomIdController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please Enter your roomId",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      isValidated = false;
    } else {
      isValidated = true;
    }
  }

  Future<String> createRoom() async {
    var response = await http.post(
        Uri.parse(
            kBaseURL + "createRoom"), // replace FQDN with Your Server API URL
        headers: header);
    print('sckasas');
    print(response);
    if (response.statusCode == 200) {
      Map<String, dynamic> user = jsonDecode(response.body);
      Map<String, dynamic> room = user['room'];

      setState(() => roomIdController.text = room['room_id'].toString());
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<String> getPin() async {
    var response = await http.post(
        Uri.parse(
            kBaseURL + 'getRoomByPin'), // replace FQDN with Your Server API URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pin": roomIdController.text}));
    print('sckasas');
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> user = jsonDecode(response.body);
      // Map<String, dynamic> room = user['room'];

      setState(() {
        roomID = user['room_id'].toString();
        role = user['role'].toString();
        createToken();
      });
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<String> createToken() async {
    var value = {
      'user_ref': "2236",
      "roomId": roomID,
      "role": role,
      "name": nameController.text
    };
    print(jsonEncode(value));
    var response = await http.post(
        Uri.parse(
            kBaseURL + "createToken"), // replace FQDN with Your Server API URL
        headers: header,
        body: jsonEncode(value));
    print(kBaseURL);
    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> user = jsonDecode(response.body);
      setState(() => token = user['token'].toString());
      print('apptoken${token}');

      if (token != 'null' && token.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VideoConferenceScreen(
                    token: token,
                  )),
        );
        //  Navigator.pushNamed(context, '/Conference');
        return response.body;
      }
    } else {
      throw Exception('Failed to load post');
    }
  }

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 16.0);

  bool isValidated = false;
  bool isPrecallTest = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextField(
      obscureText: false,
      style: style,
      controller: nameController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final roomIdField = TextField(
      obscureText: false,
      controller: roomIdController,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Enter pin",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    /* final createRoomButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.deepPurple,
      child: MaterialButton(
        // minWidth: MediaQuery.of(context).size.width / 2,
        minWidth: 100,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          createRoomvalidations();
          if (isValidated) {
            createRoom();
          }
        },
        child: Text("Create Room",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.normal)),
      ),
    );*/

    final joinButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.deepPurple,
      child: MaterialButton(
        minWidth: 100,
        // minWidth: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          print('sdckjcs');
          joinRoomValidations();
          if (isValidated) {
            print('ityroriyori');
            getPin();
            // createRoom();
          }
        },
        child: Text("Join",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.normal)),
      ),
    );
    final precallTestButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.deepPurple,
      child: MaterialButton(
        minWidth: 100,
        // minWidth: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (isPrecallTest)
            isPrecallTest = false;
          else
            isPrecallTest = true;

          Map<String, dynamic> map = {
            'testDurationDataThroughput': 2,
            'testDurationVideoBandwidth': 30,
            'testDurationAudioBandwidth': 30,
            'stop': isPrecallTest,
            'regionId': ['IN'],
            'testNames': ['microphone'],
          };
          print(map);
          EnxRtc.clientDiagnostics(map);

          // _addEnxrtcEventHandlers();
        },
        child: Text("Precall Test",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.normal)),
      ),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('Sample App'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Enablex',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Welcome !',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: usernameField,
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: roomIdField),
                Container(
                    alignment: Alignment.center,
                    height: 100,
                    width: 100,
                    child: Row(
                      children: <Widget>[
                        /*  Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: createRoomButon)),*/
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.all(10), child: joinButon)),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: precallTestButon)),
                      ],
                    ))
              ],
            )));
  }

  void initEnxRtc() {
    // EnxRtc.enxRtc();
  }
}
