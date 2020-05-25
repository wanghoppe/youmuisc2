import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/physics.dart';
import 'package:youmusic2/models/homeModels.dart';
import 'package:youmusic2/views/playlistView.dart';

class HomeScaffold extends StatelessWidget {

  final homeScrollView = HomeScrollView();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoadModel>(
      create: (context) => LoadModel(),
      child: Builder(
        builder: (context)  {
          return Provider(
            create: (context){
              return AnimatedListModel(loadModel: Provider.of<LoadModel>(context, listen: false));
            },
            child: Scaffold(
                body: homeScrollView,
            ),
          );
        },
      ),
    );
  }
}

class HomeScrollView extends StatefulWidget{
  @override
  _HomeScrollViewState createState() => _HomeScrollViewState();
}

class _HomeScrollViewState extends State<HomeScrollView> {

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
                  color: CupertinoDynamicColor
                      .resolve(CupertinoColors.inactiveGray, context),
                  size: 50.0,
                ),
              )
          )
      );
    }else{
      return Container(color:Colors.blue, height: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listModel = Provider.of<AnimatedListModel>(context, listen: false);

    return SafeArea(
      child: CustomScrollView(
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
            },
          ),
          HomePageListView(listModel: listModel),
          MyOtherSliverList()
        ],
      ),
    );
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
                      return CardItem(widget.title, json: widget.itemList[idx]);
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
  static const watchLst = ['watchEndpoint', 'watchPlaylistEndpoint'];

  final rowName;
  final thumbnail;
  final width;
  final title;
  final subtitle;
  final navigationEndpoint;
  final watchable;


  CardItem(this.rowName, {@required json}):
        thumbnail = json['thumbnails'].last['url'],
        width = widthMap[json['aspectRatio']],
        title = json['title'],
        subtitle = json['subtitleList'].join(' '),
        navigationEndpoint = json['navigationEndpoint'],
        watchable = watchLst.any(
                (element) => json['navigationEndpoint'].containsKey(element));

  void onCardTap(BuildContext context){
    Navigator.pushNamed(
      context,
      '/playlist',
      arguments: PlaylistScreenArgs(
        rowName,
        title,
        subtitle,
        thumbnail,
        navigationEndpoint
      ),
    );
  }

  Widget _buildImage(BuildContext context){
    final image =  ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.network(
              thumbnail,
              width: width,
              height: 150,
            ),
            watchable ? Container(
              width: width,
              height: 150,
              color: Color.fromRGBO(0, 0, 0, 0.3),
              child: Center(
                child: Icon(Icons.play_arrow, size: 50),
              ),
            ): Container()
          ],
        )
    );
    print(watchable);
//    return watchable ? image : Hero(
//      tag: rowName + title,
//      child: image
//    );
    print(rowName + title);
    return Hero(
        tag: rowName + title,
        child: image
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[CardItem] $title');
    return InkWell(
      onTap: () => onCardTap(context),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
//        color: Colors.blue,
          height: 250,
          width: width,
//        color: Colors.green,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildImage(context),
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
      ),
    );
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

  @override
  double get maxFlingVelocity => 4000;

  @override
  CustomScrollPhysics applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }
}