import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/animationModels.dart';
import '../main.dart';
import 'homeTabView.dart';

class AppScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ChangeNotifierProvider<AnimationTestModel>(
      create: (context) => AnimationTestModel(),
      child: Scaffold(
        body: AppTabView(),
        bottomNavigationBar: AnimateScaffold(topPadding: topPadding)
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
          Container(color: Colors.white),
          Icon(Icons.directions_bike),
        ]);
  }
}

class AppBottomNavigationBar extends StatefulWidget {
  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  var _currentIdx = 0;

  void _onTap(int idx, TabController tabController) {
    if (idx != _currentIdx) {
      tabController.animateTo(idx);
      setState(() {
        _currentIdx = idx;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[AppBottomNavigationBar]');
    final tabController = getIt<TabControllerProvider>().tabController;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      child: BottomNavigationBar(
        selectedItemColor: Colors.white,
        backgroundColor: Theme.of(context).appBarTheme.color,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text("Account")),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("Settings"),
          )
        ],
        onTap: (idx) => _onTap(idx, tabController),
        currentIndex: _currentIdx,
      ),
    );
  }
}

class AnimateScaffold extends StatelessWidget{
  final topPadding;

  AnimateScaffold({Key key, this.topPadding}) : super(key: key);

  final controllerProvider = getIt<BottomSheetControllerProvider>();

  final Widget imgWidget = TestImg();
  final Widget widgetClosedTitle = ClosedTitle();
  final Widget widgetOpenedTitle = OpenedTitle();
  final Widget widgetOpenedSlider = OpenedSlider();
  final Widget widgetButtonGroups = ButtonGroups();
  final Widget widgetAppBottomNavigationBar = AppBottomNavigationBar();

  double getOpenOpacity(double animatedVal) {
    return max((1 - animatedVal * 3), 0);
  }

  double getCloseOpacity(double animatedVal) {
    return max(1 - (1 - animatedVal) * 2, 0);
  }
  

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final screenWidth = mediaData.size.width;
    final screenHeight = mediaData.size.height - topPadding;
    final imgHeight = screenWidth / 16 * 9;
    final itemHeight =
        (mediaData.size.height - mediaData.padding.top - 356) / 3;

    var myTween = Tween<double>(
        end: 63 + kBottomNavigationBarHeight, begin: screenHeight);
    var myTween3 = Tween<double>(end: 1.0, begin: 2.0);
    var imgHeightTween = Tween<double>(end: 63, begin: imgHeight * 1.3);
    var imgContainerHeightTween = Tween<double>(end: 63, begin: 300 * 1.3);
    var itemTransformTween = Tween<double>(end: 100.0, begin: 0.0);
    var bottomNavigationTween = Tween<double>(end:0.0, begin: kBottomNavigationBarHeight);

    return AnimatedBuilder(
      child: TestImg(),
      animation: controllerProvider.controller,
      builder: (context, child) {
        var animatedVal = controllerProvider.controller.value;
        var transVal = itemTransformTween.transform(animatedVal);
        final width = MediaQuery.of(context).padding.top;
        return GestureDetector(
          onVerticalDragStart: controllerProvider.onDragStart,
          onVerticalDragUpdate: controllerProvider.onDragUpdate,
          onVerticalDragEnd: controllerProvider.onDragEnd,
          onTap:controllerProvider.controller.isCompleted ? controllerProvider.onTap: () => {},
          child: Stack(children: [
            Container(
              height: myTween.transform(animatedVal),
              color: Color.fromRGBO(0, 0, 0, 0.3),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: myTween3.transform(animatedVal),
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Container(
                        alignment: Alignment.centerLeft,
//                            color: Colors.blue,
                        height: min(
                            imgContainerHeightTween.transform(animatedVal),
                            300),
                        child: Container(
                          alignment: Alignment.center,
                          height: min(
                              imgHeightTween.transform(animatedVal), imgHeight),
                          child: child,
//                                color: Colors.black
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Opacity(
                            opacity: getCloseOpacity(animatedVal),
                            child: widgetClosedTitle),
                      )
                    ]),
                  ),
                  Transform.translate(
                      offset: Offset(0, transVal),
                      child: Container(height: itemHeight,child: widgetOpenedTitle)),
                  Transform.translate(
                      offset: Offset(0, transVal * 2),
                      child: Container(height: itemHeight, child: widgetOpenedSlider)),
                  Transform.translate(
                      offset: Offset(0, transVal * 3),
                      child: Container(height: itemHeight,child: widgetButtonGroups))
                ],
              ),
            ),
            Positioned(
              left: 5,
              height: topPadding * 2 + kToolbarHeight,
              child: Opacity(
                opacity: getOpenOpacity(animatedVal),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 30),
                  onPressed: () => {controllerProvider.controller.forward()}, //todo
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0,bottomNavigationTween.transform(animatedVal)),
                child: widgetAppBottomNavigationBar),
            )
          ]),
        );
      },
    );
  }
}

class ClosedTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('[$this]');
    final title = Provider.of<AnimationTestModel>(context).curTitle;
    return Row(
      children: <Widget>[
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: Theme.of(context).textTheme.bodyText1, maxLines: 1),
            Text(
              'Test Subtitle',
              style: Theme.of(context).textTheme.bodyText2,
              maxLines: 1,
            )
          ]),
        ),
        IconButton(icon: Icon(Icons.play_arrow), onPressed: () => {}),
        IconButton(icon: Icon(Icons.close), onPressed: () => {})
      ],
    );
  }
}

class OpenedTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);

    final title = Provider.of<AnimationTestModel>(context).curTitle;
    print('[OpenedTitle]');
    return Column(
      children: [
        Text(title,
            style: Theme.of(context).textTheme.headline5),
        Text('This is a subtitile',
            style: Theme.of(context).textTheme.bodyText1)
      ],
    );
  }
}

class OpenedSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('[$this]');
    return Column(
      children: [
        Container(
          child: Slider(value: 0.5),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0:00', style: Theme.of(context).textTheme.subtitle2),
                Text('9:99', style: Theme.of(context).textTheme.subtitle2)
              ]),
        )
      ],
    );
  }
}

class ButtonGroups extends StatefulWidget {
  @override
  _ButtonGroupsState createState() => _ButtonGroupsState();
}

class _ButtonGroupsState extends State<ButtonGroups> {
  var isPlaying = true;

  @override
  Widget build(BuildContext context) {
    final testModel = Provider.of<AnimationTestModel>(context, listen: false);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(),
          IconButton(icon: Icon(Icons.skip_previous), onPressed: testModel.changeTitle),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 50,
            onPressed: () => setState(() => isPlaying = !isPlaying),
          ),
          IconButton(icon: Icon(Icons.skip_next)),
          Container()
        ]);
  }
}

class LogoWidget extends StatelessWidget {
  // Leave out the height and width so it fills the animating parent
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Container(color: Colors.white54, child: FlutterLogo()),
      );
}

class TestImg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final url =
        'https://lh3.googleusercontent.com/IeNJWoKYx1waOhfWF6TiuSiWBLfqLb18lmZYXSgsH1fvb8v1IYiZr5aYWe0Gxu-pVZX3=s360-rw';
    final url2 = 'https://i.ytimg.com/vi/gJLIiF15wjQ/hq720.jpg?sqp=-o'
        'aymwEXCNUGEOADIAQqCwjVARCqCBh4INgESFo&rs=AMzJL3lviTRRxk7IJfj6uSMboq'
        'WRHaGRMQ';
    print('testing imag');
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        url,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
