import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:youmusic2/test/data.dart';

import 'client/client.dart';
import 'models/homePageModels.dart';
import 'package:flutter/physics.dart';

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

class HomeScaffold extends StatelessWidget {

  final homeScrollView = HomeScrollView();

  @override
  Widget build(BuildContext context) {
//    final json = MyMap['itemList'][0];
//    final json2 = MyItem2;
//    final lstJson = RowData;
//    print(MyMap);

    return Provider(
      create: (context){
        return AnimatedListModel(loadModel: Provider.of<LoadModel>(context, listen: false));
      },
      child: Scaffold(
        body: homeScrollView
      ),
    );
  }
}

class HomeScrollView extends StatefulWidget{
  @override
  _HomeScrollViewState createState() => _HomeScrollViewState();
}

class _HomeScrollViewState extends State<HomeScrollView> {
  @override
  Widget build(BuildContext context) {
    final listModel = Provider.of<AnimatedListModel>(context, listen: false);

    return CustomScrollView(
      physics:
        const AlwaysScrollableScrollPhysics(parent: const CustomScrollPhysics()),
      slivers: <Widget>[
        SliverAppBar(
          title: Text('YouMuisc', style: Theme.of(context).textTheme.title),
          floating: true,
        ),
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 100,
          refreshIndicatorExtent: 0,
          builder: buildSimpleRefreshIndicator,
          onRefresh: () async {
            listModel.resetList();
//            stateRef.current.resetList();
//            await Future.delayed(Duration(seconds: 2));
          },
        ),
        HomePageListView(listModel: listModel),
        MyOtherSliverList()
      ],
    );
  }
}

class Reference{
  var current;
}

Widget buildSimpleRefreshIndicator(context, refreshState, pulledExtent,
    refreshTriggerPullDistance, refreshIndicatorExtent) {
  const Curve opacityCurve = Interval(0.4, 0.8, curve: Curves.easeInOut);

  if (refreshState == RefreshIndicatorMode.drag){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Opacity(
          opacity: opacityCurve.transform(
              min(pulledExtent / refreshTriggerPullDistance, 1.0)
          ),
          child: Icon(
            CupertinoIcons.down_arrow,
            color: CupertinoDynamicColor.resolve(CupertinoColors.inactiveGray, context),
            size: 50.0,
          ),
        )
      )
    );
  }else{
    return Container(color:Colors.blue, height: 0);
  }
}

class CustomScrollPhysics extends BouncingScrollPhysics{

  const CustomScrollPhysics({ ScrollPhysics parent }) : super(parent: parent);

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 0.3,
    stiffness: 500.0,
    ratio: 1.1,
  );
////
//  @override
//  Tolerance get tolerance =>  Tolerance(distance: 0.1,time: 2, velocity: 2);

  @override
  double get maxFlingVelocity => 4000;
//
//  @override
//  double get minFlingVelocity => 10000;
//  @override
//  double get dragStartDistanceMotionThreshold => 100.5;
  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }
}

class HomePageListView extends StatefulWidget {

  final listModel;

  HomePageListView({@required this.listModel});

  @override
  _HomePageListViewState createState() => _HomePageListViewState();
}

class _HomePageListViewState extends State<HomePageListView> {

  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();

  List<HomeRow> _list;


  @override
  void initState() {
    super.initState();
    widget.listModel.consume();
  }

  
  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {

    return SizeTransition( // Todo: change
      sizeFactor: animation,
      axisAlignment: 1.0,
      child: FadeTransition(
          opacity: animation,
          child: widget.listModel[index]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[CustomScrollView]');
    return SliverAnimatedList(
      key: widget.listModel.listKey,
      initialItemCount: widget.listModel.length, // Todo: change
      itemBuilder: _buildItem,
    );
  }
}

class MyOtherSliverList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    print('[MyOtherSliverList]');
    return SliverList(
      delegate: SliverChildListDelegate(  // Todo: change
        [ActivityIndicatorContainer()]
      ),
    );
  }
}

class ActivityIndicatorContainer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    print('[ActivityIndicatorContainer]');
    final loadModel = Provider.of<LoadModel>(context);
    return Visibility(
        visible: !loadModel.finished,
        child: Container(
            height: 128,
            child: const Center(child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
            ))
        )
    );
  }
}

class HomeRow extends StatefulWidget{

  final itemList;
  final title;

  HomeRow({@required json}):
        itemList = json['itemList'],
        title = json['title'];

  @override
  _HomeRowState createState() => _HomeRowState();
}

class _HomeRowState extends State<HomeRow> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('[HomeRow] ${widget.title}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          child: Text(
              widget.title,
              style: GoogleFonts.lato(
                  textStyle: Theme.of(context).textTheme.headline)
          ),
        ),
        Container(
//          color: Colors.green,
          height: 275,
          child: CustomScrollView(
            scrollDirection: Axis.horizontal,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, idx) {
                      return CardItem(json: widget.itemList[idx]);
                    },
                        childCount: widget.itemList.length
                    )
                ),
              )],
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CardItem extends StatelessWidget{

  static const widthMap = <String, double>{
    'MUSIC_TWO_ROW_ITEM_THUMBNAIL_ASPECT_RATIO_SQUARE' :150,
    'MUSIC_TWO_ROW_ITEM_THUMBNAIL_ASPECT_RATIO_RECTANGLE_16_9': 266
  };

  final thumbnail;
  final width;
  final title;
  final subtitle;
  final navigationEndpoint;

  CardItem({@required json}):
    thumbnail = json['thumbnails'].last['url'],
    width = widthMap[json['aspectRatio']],
    title = json['title'],
    subtitle = json['subtitleList'].join(' '),
    navigationEndpoint = json['navigationEndpoint'];

  @override
  Widget build(BuildContext context) {
    print('[CardItem] $title');
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
//        color: Colors.blue,
        height: 250,
        width: width,
//        color: Colors.green,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                thumbnail,
                width: width,
                height: 150,
              )),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text('$title',
                style: Theme.of(context).textTheme.subtitle,
                maxLines: 2
              ),
            ),
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text('$subtitle', maxLines: 2),
            )
          ],
        ),
      ),
    );
  }
}
