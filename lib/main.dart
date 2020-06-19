import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/models/mediaQueryModels.dart';
import 'package:youmusic2/playerClient/playerClient.dart';
import 'package:youmusic2/temp/TabView.dart';
import 'package:youmusic2/views/appScaffoldView.dart';

import 'package:youmusic2/views/homeView.dart';
import 'package:youmusic2/views/playlistView.dart';
import 'models/controllerModels.dart';
import 'models/homeModels.dart';
import 'models/playerModels.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<TabControllerProvider>(TabControllerProvider());
  getIt.registerSingleton<BottomSheetControllerProvider>(
      BottomSheetControllerProvider());
  getIt.registerSingleton<HomeNavigatorController>(
      HomeNavigatorController(getIt<BottomSheetControllerProvider>()));
  getIt.registerSingleton<PlayerClient>(PlayerClient());
}

void main() {
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(color: Color.fromRGBO(30, 30, 30, 1)),
        textTheme: TextTheme(
          headline5:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
//          display4: TextStyle(color: Colors.white)
          bodyText2: TextStyle(color: Colors.white54),
        ),
      ),
      home: MediaQueryWrapper(),
//      home: ForTestScaffold(),
    );
  }
}

class MediaQueryWrapper extends StatelessWidget{

  final widgetAppScaffold = AppScaffold();

  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = MediaProvider(MediaQuery.of(context));
    print('[$this]');
    return Provider.value(
        value: mediaProvider,
        child: widgetAppScaffold
    );
  }
}

class ForTestScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Colors.green),
          alignment: Alignment.center,
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red,
                      blurRadius: 20.0,
                      spreadRadius: 20.0
                    ),
                    BoxShadow(
                        color: Colors.blue,
                        blurRadius: 20.0,
                        spreadRadius: 15.0
                    ),
                  ]
              ),
              height: 50, width: 50,
            child: Marquee(
              text: 'There once was a boy who told this story about a boy: "',
            ) ,
          )),
    );
  }
}
