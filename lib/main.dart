
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/temp/TabView.dart';
import 'package:youmusic2/views/appScaffoldView.dart';

import 'package:youmusic2/views/homeView.dart';
import 'package:youmusic2/views/playlistView.dart';
import 'models/homeModels.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<ApiClient>(ApiClient());
}

void main(){
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(color: Color.fromRGBO(30,30,30,1)),
        textTheme: TextTheme(
          headline5: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
//          display4: TextStyle(color: Colors.white)
          bodyText2: TextStyle(color: Colors.white54),
        ),
      ),
      home: AppScaffold(),
    );
  }
}