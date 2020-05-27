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
          bottomNavigationBar: AnimateScaffold(topPadding: topPadding)),
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

class AnimateScaffold extends StatelessWidget {
  static const minBottomListHeight = 56.0;
  static const wrapImgHeight = 300.0;
  static const closedHeight = 54.0;
  static const s1 = 0.2;
  static const s2 = 0.6;

  final topPadding;
  AnimateScaffold({Key key, this.topPadding}) : super(key: key);

  BottomSheetControllerProvider controllerProvider =
      getIt<BottomSheetControllerProvider>();

  final Widget imgWidget = TestImg();
  final Widget widgetClosedTitle = ClosedTitle();
  final Widget widgetOpenedTitle = OpenedTitle();
  final Widget widgetOpenedSlider = OpenedSlider();
  final Widget widgetButtonGroups = ButtonGroups();
  final Widget widgetAppBottomNavigationBar = AppBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final screenWidth = mediaData.size.width;
    final screenHeight = mediaData.size.height - topPadding;
    final imgHeight = screenWidth / 16 * 9;
    final itemHeight = (screenHeight - wrapImgHeight - minBottomListHeight) / 3;

    Animation<double> containerHeightS1 = Tween<double>(
            begin: kBottomNavigationBarHeight,
            end: kBottomNavigationBarHeight + closedHeight)
        .animate(CurvedAnimation(
            parent: controllerProvider.controller, curve: Interval(0.0, s1)));

    Animation<double> containerHeightS2 = Tween<double>(
            begin: kBottomNavigationBarHeight + closedHeight, end: screenHeight)
        .animate(CurvedAnimation(
            parent: controllerProvider.controller, curve: Interval(s1, s2)));

    Animation<double> closedRowWidth = Tween<double>(begin: 1.0, end: 2.0)
        .animate(CurvedAnimation(
            parent: controllerProvider.controller, curve: Interval(s1, s2)));

    Animation<double> aImgHeight =
        Tween<double>(begin: closedHeight, end: imgHeight).animate(
            CurvedAnimation(
                parent: controllerProvider.controller,
                curve: Interval(s1, s2 - 0.02)));

    Animation<double> imgContainerHeightS1 =
        Tween<double>(begin: closedHeight, end: wrapImgHeight).animate(
            CurvedAnimation(
                parent: controllerProvider.controller,
                curve: Interval(s1, s2 - 0.02)));

    Animation<double> imgContainerHeightS2 =
        Tween<double>(begin: wrapImgHeight, end: imgHeight).animate(
            CurvedAnimation(
                parent: controllerProvider.controller,
                curve: Interval(s2, 1.0)));

    Animation<double> basicTrans = Tween<double>(begin: 200.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: controllerProvider.controller, curve: Interval(s1, s2)));

    Animation<double> buttonTrans =
        Tween<double>(begin: 0.0, end: -(imgHeight / 2 + 2.5 * itemHeight))
            .animate(CurvedAnimation(
                parent: controllerProvider.controller,
                curve: Interval(s2, 1.0)));

    Animation<double> bottomNavTrans =
        Tween<double>(begin: 0.0, end: kBottomNavigationBarHeight).animate(
            CurvedAnimation(
                parent: controllerProvider.controller,
                curve: Interval(s1, s2)));

    Animation<double> bottomListTrans =
        Tween<double>(begin: 0.0, end: -3 * itemHeight).animate(CurvedAnimation(
            parent: controllerProvider.controller, curve: Interval(s2, 1.0)));

    Animation<double> closedRowOpacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: controllerProvider.controller,
            curve: Interval(s1, (s1 + s2) / 2)));

    Animation<double> dropDownOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: controllerProvider.controller,
            curve: Interval(s1, (s1 + s2) / 2)));

    Animation<double> openTitleOpacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: controllerProvider.controller, curve: Interval(s2, 1.0)));

    return AnimatedBuilder(
      child: TestImg(),
      animation: controllerProvider.controller,
      builder: (context, child) {
        var animatedVal = controllerProvider.controller.value;
        return GestureDetector(
          onVerticalDragStart: controllerProvider.onDragStart,
          onVerticalDragUpdate: controllerProvider.onDragUpdate,
          onVerticalDragEnd: controllerProvider.onDragEnd,
          onTap: controllerProvider.controller.isDismissed
              ? controllerProvider.onTap
              : () => {},
          child: Stack(children: [
            Container(
              height: (animatedVal < s1)
                  ? containerHeightS1.value
                  : containerHeightS2.value, //todo
              color: Color.fromRGBO(0, 0, 0, 0.3),
              child: Column(
                children: [
                  FractionallySizedBox(
                    widthFactor: closedRowWidth.value,
                    alignment: Alignment.topLeft,
                    child: Row(children: [
                      Container(
                        alignment: Alignment.centerLeft,
//                            color: Colors.blue,
                        height: (animatedVal < s2)
                            ? imgContainerHeightS1.value
                            : imgContainerHeightS2.value,
                        child: Container(
                          alignment: Alignment.center,
                          height: aImgHeight.value,
                          child: child,
//                                color: Colors.black
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Opacity(
                            opacity: closedRowOpacity.value,
                            child: widgetClosedTitle),
                      )
                    ]),
                  ),
                  Transform.translate(
                      offset: Offset(0, basicTrans.value),
                      child: Container(
                          height: itemHeight,
                          child: Opacity(
                              opacity: openTitleOpacity.value,
                              child: widgetOpenedTitle))),
                  Transform.translate(
                      offset: Offset(0, basicTrans.value * 2),
                      child: Container(
                          height: itemHeight,
                          child: Opacity(
                              opacity: openTitleOpacity.value,
                              child: widgetOpenedSlider))),
                  Transform.translate(
                      offset: Offset(
                          0,
                          (animatedVal < s2)
                              ? basicTrans.value * 3
                              : buttonTrans.value),
                      child: Container(
                          height: itemHeight, child: widgetButtonGroups)),
                  Transform.translate(
                      offset: Offset(
                          0,
                          (animatedVal < s2)
                              ? basicTrans.value * 4
                              : bottomListTrans.value),
                      child: Container(
                        height: screenHeight - itemHeight - 50,
                        color: Colors.red,
                      ))
                ],
              ),
            ),
            Positioned(
              left: 5,
              height: topPadding * 2 + kToolbarHeight,
              child: Opacity(
                opacity: dropDownOpacity.value,
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 30),
                  onPressed: () =>
                      {controllerProvider.controller.reverse()}, //todo
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Transform.translate(
                  offset: Offset(0, bottomNavTrans.value),
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
        Text(title, style: Theme.of(context).textTheme.headline5),
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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
          IconButton(
              icon: Icon(Icons.skip_previous),
              onPressed: testModel.changeTitle),
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
