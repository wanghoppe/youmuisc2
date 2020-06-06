import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/controllerModels.dart';
import 'package:youmusic2/models/playerModels.dart';
import 'package:youmusic2/views/homeView.dart';
import 'package:youmusic2/views/utilsView.dart';
import '../main.dart';

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
    } else {
      getIt<BottomSheetControllerProvider>()
          .controller
          .animateTo(BottomSheetControllerProvider.s1);
    }
  }

  @override
  Widget build(BuildContext context) {
//    print('[AppBottomNavigationBar]');
    final tabController = getIt<TabControllerProvider>().tabController;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onVerticalDragUpdate: (update) {},
      onTap: () {},
      child: Container(
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
      ),
    );
  }
}

class AnimateScaffold extends StatelessWidget {
  static const minBottomListHeight = 56.0;
  static const wrapImgHeight = 300.0;
  static const closedHeight = 54.0;

  final topPadding;
  AnimateScaffold({Key key, this.topPadding}) : super(key: key);

  final BottomSheetControllerProvider controllerProvider =
      getIt<BottomSheetControllerProvider>();
  final s1 = BottomSheetControllerProvider.s1;
  final s2 = BottomSheetControllerProvider.s2;

  final Widget imgWidget = TestImg();
  final Widget widgetClosedTitle = ClosedTitle();
  final Widget widgetOpenedTitle = OpenedTitle();
  final Widget widgetOpenedSlider = OpenedSlider();
  final Widget widgetButtonGroups = ButtonGroups();
  final Widget widgetAppBottomNavigationBar = AppBottomNavigationBar();

  Widget _buildImgMask(BuildContext context, double opacity){
    final audioPlayer = Provider.of<AudioPlayerProvider>(context, listen: false);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child:Container(
        alignment: Alignment.center,
        color: Color.fromRGBO(0, 0, 0, opacity),
        child: StreamBuilder<bool>(
          stream: audioPlayer.bufferingStream,
          initialData: true,
          builder: (context, snapshot) {
//            print('stream buffering, ${snapshot.hasError}');
            return VisibleActivityIndicator(visible: snapshot.data);
          }
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final screenWidth = mediaData.size.width;
    final screenHeight = mediaData.size.height - topPadding;
    final imgHeight = screenWidth / 16 * 9;
    final itemHeight = (screenHeight - wrapImgHeight - minBottomListHeight) / 3;
    final maxSlide =
        screenHeight - kBottomNavigationBarHeight - closedHeight / 2;

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
                curve: Interval(s1, s2 - 0.00)));

    Animation<double> imgContainerHeightS1 =
        Tween<double>(begin: closedHeight, end: wrapImgHeight).animate(
            CurvedAnimation(
                parent: controllerProvider.controller,
                curve: Interval(s1, s2 - 0.00)));

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

    Animation<double> imgBackOpacity = Tween<double>(begin: 0.0, end: 0.55)
        .animate(CurvedAnimation(
            parent: controllerProvider.controller, curve: Interval(s2, 1.0)));

    void onDragUpdate(DragUpdateDetails details) {
      final AnimationController _controller = controllerProvider.controller;
      double delta = details.primaryDelta / (maxSlide) * (s2 - s1);
      final nextVal = _controller.value - delta;

      if (_controller.value >= s1 && nextVal >= s1) {
        _controller.value = nextVal;
      }
    }

    void onDragEnd(DragEndDetails details) {
      //I have no idea what it means, copied from Drawer
      const double _kMinFlingVelocity = 365.0;
      final AnimationController _controller = controllerProvider.controller;
      final dy = details.velocity.pixelsPerSecond.dy;

//      print(dy);

      if (_controller.isDismissed ||
          _controller.isCompleted ||
          _controller.value < s1) {
        return;
      }
      if (dy.abs() >= _kMinFlingVelocity) {
        if (dy > 0)
          controllerProvider.nextDown();
        else
          controllerProvider.nextUp();
      } else {
        controllerProvider.onZeroDrop();
      }
    }


    return AnimatedBuilder(
      child: TestImg(),
      animation: controllerProvider.controller,
      builder: (context, child) {
        var animatedVal = controllerProvider.controller.value;
        return GestureDetector(
//          onVerticalDragStart: onDragStart,
          onHorizontalDragStart: (details) {},
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: onDragEnd,
          onTap: controllerProvider.onClosedTap,
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
                        alignment: Alignment.center,
//                        color: Colors.blue,
                        height: (animatedVal < s2)
                            ? imgContainerHeightS1.value
                            : imgContainerHeightS2.value,
                        child: Container(
//                            color: Colors.green,
                            height: aImgHeight.value,
                            child: Stack(children: [
                              child,
                              _buildImgMask(context, imgBackOpacity.value)
                            ])),
                      ),
                      SizedBox(width: 16),
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
                          height: itemHeight - 20,
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
                          height: itemHeight + 20, child: widgetButtonGroups)),
                  Transform.translate(
                      offset: Offset(
                          0,
                          (animatedVal < s2)
                              ? basicTrans.value * 8
                              : bottomListTrans.value),
                      child: Container(
                        height: screenHeight - imgHeight, //todo
                        color: Colors.blueGrey,
                      ))
                ],
              ),
            ),
            Positioned(
              left: 5,
              height: kToolbarHeight,
              child: Opacity(
                opacity: dropDownOpacity.value,
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 30),
                  onPressed: (dropDownOpacity.value == 1.0)
                      ? controllerProvider.onDropDownClick
                      : null, //todo
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
    final info = Provider.of<PlayerInfoProvider>(context);
    final audioPlayer = Provider.of<AudioPlayerProvider>(context, listen: false);
    return Row(
      children: <Widget>[
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            FutureBuilder<String>(
              future: info.futureTitle,
              builder: (context, snapshot) {
                return Text(snapshot.data ?? '',
                    style: Theme.of(context).textTheme.bodyText1, maxLines: 1);
              }
            ),
            FutureBuilder<String>(
              future: info.futureSubtitle,
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? '',
                  style: Theme.of(context).textTheme.bodyText2,
                  maxLines: 1,
                );
              }
            )
          ]),
        ),
        StreamBuilder<bool>(
          stream: audioPlayer.playingStream,
          builder: (context, snapshot) {
            final _isPlaying =  snapshot.data ?? false;

            void onPlayPressed(){
              print(_isPlaying);
              if (_isPlaying){
                audioPlayer.pause();
              }else{
                audioPlayer.play();
              }
            }

            return IconButton(
                icon: Icon(_isPlaying? Icons.pause : Icons.play_arrow),
                onPressed: (snapshot.data != null) ? onPlayPressed : null
            );
          }
        ),
        IconButton(
            icon: Icon(Icons.close),
            onPressed: getIt<BottomSheetControllerProvider>().onCloseClick)
      ],
    );
  }
}

class OpenedTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final info = Provider.of<PlayerInfoProvider>(context);
    print('[OpenedTitle]');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FutureBuilder<String>(
          future: info.futureTitle,
          builder: (context, snapshot) {
            final text = snapshot.data?? ' ';
            return Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: (text.length < 28)
                  ? Text(text, style: Theme.of(context).textTheme.headline5)
                  : Marquee(text: text,
                      style: Theme.of(context).textTheme.headline5,
                      startPadding: 10.0,
                      blankSpace: 50.0,
                      fadingEdgeEndFraction: 0.1,
                      fadingEdgeStartFraction: 0.1,
                      showFadingOnlyWhenScrolling: false,
                      pauseAfterRound: Duration(seconds: 1)
                  ),
            );
          }
        ),
        SizedBox(height: 5),
        FutureBuilder<String>(
          future: info.futureSubtitle,
          builder: (context, snapshot) {
            return Text(snapshot.data ?? '',
                style: Theme.of(context).textTheme.bodyText1);
          }
        )
      ],
    );
  }
}

class AutoTextScroller extends StatefulWidget{

  final String text;

  AutoTextScroller(this.text);

  @override
  _AutoTextScrollerState createState() => _AutoTextScrollerState();
}

class _AutoTextScrollerState extends State<AutoTextScroller> {

  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Text(
        widget.text,
        style: Theme.of(context).textTheme.headline5,
      ),
    );
  }
}


class OpenedSlider extends StatefulWidget {
  @override
  _OpenedSliderState createState() => _OpenedSliderState();
}

class _OpenedSliderState extends State<OpenedSlider> {
  static const kPadding = 16.0;
  double sliderWidth;
  double _sliderVal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sliderWidth = MediaQuery.of(context).size.width - 2 * kPadding;
  }

  void _onDragDown(DragDownDetails details) {
    final _val = details.localPosition.dx / sliderWidth;
    setState(() {
      _sliderVal = _val;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
//    print('DragUpdate');
    final _dVal = details.delta.dx / sliderWidth;
    setState(() {
      _sliderVal += _dVal;
    });
  }

  void _onDragEnd (Duration totalDuration) async{
    final audioPlayer = Provider.of<AudioPlayerProvider>(context, listen: false);
    Duration nextDuration = Duration(
      milliseconds: (_sliderVal * totalDuration.inMilliseconds).floor()
    );
    await audioPlayer.seek(nextDuration);
    _sliderVal = null;
  }

  String _durationToStr(Duration duration){
    var sec = duration.inSeconds;
    final min = (sec/60).floor();
    sec = sec%60;
    return '$min:${sec.toString().padLeft(2,'0')}';
  }

  String _valueToStr(Duration totalDuration){
    var sec = (totalDuration.inSeconds * _sliderVal).round();
    final min = (sec/60).floor();
    sec = sec%60;
    return '$min:${sec.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
//    print('[$this]');
    final audioPlayer =
        Provider.of<AudioPlayerProvider>(context, listen: false);

    return StreamBuilder<Duration>(
      stream: audioPlayer.durationStream,
      builder: (context, snapshot) {
        Duration duration = snapshot.data ?? Duration.zero;
//        print('stream duration, Error, ${snapshot.hasError}');
//        print('stream duration, data, ${snapshot.data}');
        final hasData = (snapshot.data != null);
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPadding),
              child: GestureDetector(
                onHorizontalDragDown: hasData ? _onDragDown: null,
                onHorizontalDragUpdate: hasData ? _onDragUpdate: null,
                onHorizontalDragEnd: hasData ? (details) => _onDragEnd(duration): null,
                onHorizontalDragCancel: hasData ? () => _onDragEnd(duration): null,
                child: Container(
                  color: Colors.white.withOpacity(.0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Stack(
                    children: [
                      StreamBuilder<Duration>(
                          stream: audioPlayer.bufferStream,
                          builder: (context, snapshot) {
                            Duration buffer = snapshot.data ?? Duration.zero;
                            final bufferVal = (duration == Duration.zero)
                                ? 0.0
                                : buffer.inMilliseconds / duration.inMilliseconds;
                            return LinearProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.blueGrey),
                                value: bufferVal,
                                backgroundColor: Colors.white.withOpacity(0.2));
                          }),
                      StreamBuilder<Duration>(
                          stream: audioPlayer.positionStream,
                          builder: (context, snapshot) {
                            Duration position = snapshot.data ?? Duration.zero;
//                            print('stream position error: ${snapshot.hasError}');
                            final computeVal = (duration == Duration.zero)
                              ? 0.0
                              : position.inMilliseconds / duration.inMilliseconds;
//                            print('position value: $computeVal');
                            return LinearProgressIndicator(
                              value: _sliderVal ?? computeVal,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              backgroundColor: Colors.white.withOpacity(0.0),
                            );
                          }),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<Duration>(
                        stream: audioPlayer.positionStream,
                        builder: (context, snapshot) {
                          Duration position = snapshot.data ?? Duration.zero;
                          return Text(
                              (_sliderVal != null)
                                  ? _valueToStr(duration)
                                  : _durationToStr(position),
                              style: Theme.of(context).textTheme.subtitle2);
                        }),
                    Text(_durationToStr(duration),
                        style: Theme.of(context).textTheme.subtitle2)
                  ]),
            )
          ],
        );
      },
    );
  }
}

class ButtonGroups extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final testModel = Provider.of<AnimationTestModel>(context, listen: false);
    final audioPlayer = Provider.of<AudioPlayerProvider>(context, listen: false);
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(),
          IconButton(
              icon: Icon(Icons.skip_previous),
              onPressed: (){
                testModel.changeTitle();
//                audioPlayer.setUrl(AudioPlayerProvider.testUrl2);
              }),
          StreamBuilder<bool>(
            stream: audioPlayer.playingStream,
            builder: (context, snapshot) {
              final _isPlaying =  snapshot.data ?? false;

              void onPlayPressed(){
                print(_isPlaying);
                if (_isPlaying){
                  audioPlayer.pause();
                }else{
                  audioPlayer.play();
                }
              }

//              print('stream playing . ${snapshot.data}');
//              print('stream playing Error:  ${snapshot.hasError}');

              return IconButton(
                icon: Icon(_isPlaying? Icons.pause : Icons.play_arrow),
                iconSize: 50,
                onPressed: (snapshot.data != null) ? onPlayPressed : null
              );
            }
          ),
          IconButton(icon: Icon(Icons.skip_next),
            onPressed: (){
//              audioPlayer.setUrl(AudioPlayerProvider.testUrl);
            },
          ),
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
    final info = Provider.of<PlayerInfoProvider>(context);
    return FutureBuilder<String>(
      future: info.futureUrl,
      builder: (context, snapshot) {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: snapshot.hasData
              ? Image.network(
              snapshot.data,
              fit: BoxFit.fitHeight,
            )
          : Center(child: VisibleActivityIndicator(visible: true))
        );
      }
    );
  }
}
