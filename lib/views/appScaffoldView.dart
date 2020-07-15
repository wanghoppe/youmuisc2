
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/controllerModels.dart';
import 'package:youmusic2/models/playerModels.dart';
import 'package:youmusic2/temp/localViews.dart';
import 'package:youmusic2/views/playerView.dart';
import 'package:youmusic2/models/watchListModels.dart';
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
    print('rebuiling app scaffold');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AnimationTestModel>(
          create: (context) => AnimationTestModel(),
        ),
        Provider<AudioPlayerProvider>.value(
          value: _audioPlayer,
        ),
        ChangeNotifierProvider<PlayerInfoProvider>(
          create: (context) => PlayerInfoProvider(),
        ),
        ChangeNotifierProvider<WatchListProvider>(
          create: (context) => WatchListProvider(),
        ),
        ChangeNotifierProvider<TabViewMaskOpacity>(
          create: (context) => TabViewMaskOpacity(),
        )
      ],
      child:WillPopScope(
        onWillPop: getIt<HomeNavigatorController>().handleAndroidBack,
        child: Scaffold(
            body: AppTabView(),
            bottomNavigationBar: AnimateScaffold()),
        ),
      );
  }
}

class AppTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TabBarView(
          controller: getIt<TabControllerProvider>().tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeUnderTab(),
//          AnimateScaffold(),
            LocalUnderTab(),
            ThirdTab(),
          ]),
        TabViewMask()
      ]
    );
  }
}

class TabViewMask extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final opacity = Provider.of<TabViewMaskOpacity>(context).opacity;
    return Expanded(
      child: Container(
        color: (opacity == 0.0) ? null : Color.fromRGBO(0, 0, 0, opacity)
      )
    );
  }
}
