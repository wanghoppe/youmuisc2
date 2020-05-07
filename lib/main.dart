
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:youmusic2/views/homeView.dart';
import 'models/homeModels.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: TextTheme(
          headline: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          display4: TextStyle(color: Colors.white),
          body1: TextStyle(color: Colors.white54),
        ),
      ),
      home: ChangeNotifierProvider<LoadModel>(
        create: (context) => LoadModel(),
        child: HomeScaffold()
      ),
    );
}
}
