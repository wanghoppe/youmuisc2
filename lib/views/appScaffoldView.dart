
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/controllerModels.dart';
import 'package:youmusic2/models/playerModels.dart';
import 'package:youmusic2/views/playerView.dart';
import '../main.dart';
import 'homeTabView.dart';

class AppScaffold extends StatefulWidget {
  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {

  AudioPlayerProvider _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayerProvider();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AnimationTestModel>(
          create: (context) => AnimationTestModel(),
        ),
        Provider<AudioPlayerProvider>.value(
          value: _audioPlayer,
        ),
        ChangeNotifierProvider(
          create: (context) => PlayerInfoProvider(),
        )
      ],
      child:WillPopScope(
        onWillPop: getIt<HomeNavigatorController>().handleAndroidBack,
        child: Scaffold(
            body: AppTabView(),
            bottomNavigationBar: AnimateScaffold(topPadding: topPadding)),
        ),
      );
  }
}

class AppTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
        controller: getIt<TabControllerProvider>().tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeUnderTab(),
//          AnimateScaffold(),
          Container(color: Colors.black),
          Icon(Icons.directions_bike),
        ]);
  }
}
