import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:youmusic2/test/data.dart';

import 'client/client.dart';
import 'models/homePageModels.dart';

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

    return Scaffold(
      body: homeScrollView
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
    final loadModel = Provider.of<LoadModel>(context, listen: false);
    final stateRef = Reference();

    return RefreshIndicator(
      onRefresh: () async{
        stateRef.current.resetList();
        return null;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('YouMuisc', style: Theme.of(context).textTheme.title),
            floating: true,
          ),
          HomePageListView(loadModel: loadModel, stateRef: stateRef),
          MyOtherSliverList()
        ],
      ),
    );
  }
}

class Reference{
  var current;
}

class HomePageListView extends StatefulWidget {

  final loadModel;
  final stateRef;
  
  HomePageListView({@required this.loadModel, @required this.stateRef});

  @override
  _HomePageListViewState createState() {
    final state = _HomePageListViewState();
    stateRef.current = state;
    return state;
  }

}

class _HomePageListViewState extends State<HomePageListView> {

  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();

  List<HomeRow> _list;


  @override
  void initState() {
    super.initState();
    _list = [];
    _consume();
  }

  void _consume(){
    widget.loadModel.start();

    final rowStream = HomePageStream().stream;
    rowStream.listen(
      (json) => _insert(json),
      onDone: () => widget.loadModel.finish()
    );
  }

  void _insert(Map<String, dynamic> json) {
    _list.add(HomeRow(json: json));
    _listKey.currentState
        .insertItem(_list.length-1, duration:const Duration(milliseconds: 1000));
  }

  void resetList(){
    _removeAnimatedAll();
    _list = [];
    _consume();
  }

  void _removeAnimatedAll(){
    for (var i = _list.length-1; i>=0; i--){
      _listKey.currentState.removeItem(i, (context, animation) => Container());
    }
  }
  
  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {

    if (index >= _list.length){
      print('idx: ${index.toString()}, but length: ${_list.length.toString()}');
      return Container();
    }
    return SizeTransition( // Todo: change
      sizeFactor: animation,
      axisAlignment: 1.0,
      child: FadeTransition(
          opacity: animation,
          child: _list[index]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[CustomScrollView]');
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _list.length, // Todo: change
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
            child: const Center(child: CircularProgressIndicator(backgroundColor: Colors.white))
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
