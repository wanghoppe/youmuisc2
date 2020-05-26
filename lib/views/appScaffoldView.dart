import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:youmusic2/models/animationModels.dart';
import '../main.dart';
import 'homeTabView.dart';

class AppScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Builder(builder: (context) {
      return Scaffold(
        body: AppTabView(),
        bottomNavigationBar: AnimateScaffold(topPadding: topPadding)
      );
    });
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

class AnimateScaffold extends StatefulWidget {
  final topPadding;

  const AnimateScaffold({Key key, this.topPadding}) : super(key: key);

  @override
  _AnimateScaffoldState createState() => _AnimateScaffoldState();
}

class _AnimateScaffoldState extends State<AnimateScaffold>
    with SingleTickerProviderStateMixin {

  static const double maxSlide = 800;
  static const double minDragStartEdge = 60;
  static const double maxDragStartEdge = maxSlide - 16;
  AnimationController _controller;
  bool _canBeDragged = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
//    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_controller.isDismissed) {
//      _controller.forward();
      _controller.animateTo(0.5);
    } else if (_controller.isCompleted) {
      _controller.reverse();
    }
  }

  double getOpenOpacity(double animatedVal) {
    return max((1 - animatedVal * 3), 0);
  }

  double getCloseOpacity(double animatedVal) {
    return max(1 - (1 - animatedVal) * 2, 0);
  }

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = _controller.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = _controller.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
    _canBeDragged = true;

  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      _controller.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    //I have no idea what it means, copied from Drawer
    double _kMinFlingVelocity = 365.0;

    if (_controller.isDismissed || _controller.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.height;

      _controller.fling(velocity: visualVelocity);
    } else if (_controller.value < 0.5) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  Widget imgWidget = TestImg();
  Widget widgetClosedTitle = ClosedTitle();
  Widget widgetOpenedTitle = OpenedTitle();
  Widget widgetOpenedSlider = OpenedSlider();
  Widget widgetButtonGroups = ButtonGroups();
  Widget widgetAppBottomNavigationBar = AppBottomNavigationBar();
  

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final screenWidth = mediaData.size.width;
    final screenHeight = mediaData.size.height - widget.topPadding;
    final imgHeight = screenWidth / 16 * 9;

    var myTween = Tween<double>(
        end: 63 + kBottomNavigationBarHeight, begin: screenHeight);
    var myTween3 = Tween<double>(end: 1.0, begin: 2.0);
    var imgHeightTween = Tween<double>(end: 63, begin: imgHeight * 1.3);
    var imgContainerHeightTween = Tween<double>(end: 63, begin: 300 * 1.3);
    var itemTransformTween = Tween<double>(end: 100.0, begin: 0.0);
    var bottomNavigationTween = Tween<double>(end:0.0, begin: kBottomNavigationBarHeight);

    return AnimatedBuilder(
      child: TestImg(),
      animation: _controller,
      builder: (context, child) {
        var animatedVal = _controller.value;
        var transVal = itemTransformTween.transform(animatedVal);
        final width = MediaQuery.of(context).padding.top;
        return GestureDetector(
          onVerticalDragStart: _onDragStart,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          onTap:_controller.isCompleted ?_onTap: () => {},
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
                      offset: Offset(0, transVal), child: widgetOpenedTitle),
                  Transform.translate(
                      offset: Offset(0, transVal * 2),
                      child: widgetOpenedSlider),
                  Transform.translate(
                      offset: Offset(0, transVal * 3),
                      child: widgetButtonGroups)
                ],
              ),
            ),
            Positioned(
              left: 5,
              height: widget.topPadding * 2 + kToolbarHeight,
              child: Opacity(
                opacity: getOpenOpacity(animatedVal),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 30),
                  onPressed: () => {_controller.forward()}, //todo
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
    return Row(
      children: <Widget>[
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Test Main title,',
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
    final itemHeight =
        (mediaData.size.height - mediaData.padding.top - 356) / 3;
    print('[OpenedTitle]');
    return Container(
//      color: Colors.yellow,
      height: itemHeight,
      child: Column(
        children: [
          Text('This is a big title',
              style: Theme.of(context).textTheme.headline5),
          Text('This is a subtitile',
              style: Theme.of(context).textTheme.bodyText1)
        ],
      ),
    );
  }
}

class OpenedSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('[OpenedSlider]');
    final mediaData = MediaQuery.of(context);
    final itemHeight =
        (mediaData.size.height - mediaData.padding.top - 356) / 3;
    return Container(
      height: itemHeight,
      child: Column(
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
      ),
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
    final mediaData = MediaQuery.of(context);
    final itemHeight =
        (mediaData.size.height - mediaData.padding.top - 356) / 3;
    return Container(
      height: itemHeight,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(),
            IconButton(icon: Icon(Icons.skip_previous)),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 50,
              onPressed: () => setState(() => isPlaying = !isPlaying),
            ),
            IconButton(icon: Icon(Icons.skip_next)),
            Container()
          ]),
    );
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
