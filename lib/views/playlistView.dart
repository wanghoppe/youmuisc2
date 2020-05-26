//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/PlaylistModels.dart';
import 'package:youmusic2/test/playlist/listdata.dart';

import 'homeView.dart';

class PlaylistScreenArgs{
  final Map navigationEndPoint;
  final String thumbnail;
  final String title;
  final String subtitle;
  final String rowName;

  PlaylistScreenArgs(
    this.rowName,
    this.title,
    this.subtitle,
    this.thumbnail,
    this.navigationEndPoint
  );
}


class PlayListScaffold extends StatelessWidget{

  final PlaylistScreenArgs args;

  PlayListScaffold(this.args, {Key key}): super(key:key);

  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);

    return Scaffold(
      body: MultiProvider(
        providers: [
          Provider<OpacityController>(
            create: (_) => OpacityController()
          ),
          Provider<InfolistModel>(
            create: (_) => InfolistModel(args.navigationEndPoint)
          ),
          Provider<PlaylistScreenArgs>.value(value: args)
        ],
        child: Stack(children:[
          PlaylistSliver(),
          Positioned(
            left: 5,
            height: mediaData.padding.top * 2 + kToolbarHeight,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 26),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            right: 5,
            height: mediaData.padding.top * 2 + kToolbarHeight,
            child: IconButton(
                icon: Icon(Icons.search, color: Colors.white, size:26)
            ),
          )
        ]),
      )
    );
  }
}

class PlaylistSliver extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    final opController = Provider.of<OpacityController>(context, listen: false);
    final infoListModel = Provider.of<InfolistModel>(context);

    return ChangeNotifierProvider(
      create: (_) => DisableButtonModel(infoListModel.futureList),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification){
          opController.changeScrollPos(notification.metrics.pixels);
          return true;
        },
        child: CustomScrollView(
          physics:
            const AlwaysScrollableScrollPhysics(parent: const CustomScrollPhysics()),
          slivers: <Widget>[
            OpaqueSliverAppBar(),
            OpacitySliverHead(),
            SliverPlayButtons(),
            FutureBuilder(
              future: infoListModel.futureList,
              builder: (context, snapshot){
                if (snapshot.hasData){
                  return MainSliverList(snapshot.data, isAlbum: infoListModel.isAlbum);
                }else{
                  return SliverToBoxAdapter(
                    child: AlwaysActivityIndicator(),
                  );
                }
              }
            )
          ],
        ),
      ),
    );
  }
}

class OpaqueSliverAppBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final opController = Provider.of<OpacityController>(context, listen: false);
    final screenArgs = Provider.of<PlaylistScreenArgs>(context, listen: false);
    return ChangeNotifierProvider.value(
      value: opController.appBar,
      child: Builder(
        builder: (context){
          final model = Provider.of<OpacityModel>(context);
          return SliverOpacity(
            opacity: model.opacity,
            sliver: SliverAppBar(
              leading: Container(),
              pinned: true,
              title: Padding(
                padding: EdgeInsets.only(right: 40),
                child: Text(screenArgs.title)), //todo
            ),
          );
        }
      ),
    );
  }
}

class OpacitySliverHead extends StatelessWidget{

  final sliverHead = SliverHead();

  @override
  Widget build(BuildContext context) {
    final opController = Provider.of<OpacityController>(context, listen: false);
    return ChangeNotifierProvider.value(
      value: opController.header,
      child: Builder(
        builder: (context){
          final model = Provider.of<OpacityModel>(context);
          return SliverOpacity(
            opacity: model.opacity,
            sliver: sliverHead
          );
        }
      ),
    );
  }

}

class MainSliverList extends StatelessWidget{

  final List<Map> infoList;
  final bool isAlbum;

  MainSliverList(this.infoList, {@required this.isAlbum});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, idx){
        return isAlbum?
            AlbumItem(json: infoList[idx], index: idx + 1)
            :PlaylistItem(json: infoList[idx]);
      },
      childCount: infoList.length),
    );
  }

}


class SliverHead extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    print('building silver head');
    final screenArgs = Provider.of<PlaylistScreenArgs>(context, listen: false);
    return SliverToBoxAdapter(
      child: Container(
        height: 210,
//        color: Colors.black26,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: <Widget>[
              Hero(
                tag: screenArgs.rowName + screenArgs.title,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      screenArgs.thumbnail, //Todo
                      width: 150,
                      height: 150,
                    )
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(screenArgs.title, //todo
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.headline5
                        ),
                        maxLines: 3
                      ),
                      Text(screenArgs.subtitle, //todo
                          style: Theme.of(context).textTheme.bodyText2,
                          maxLines: 2
                      ),
                      HeadButtonGroup()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HeadButtonGroup extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final isDisable = Provider.of<DisableButtonModel>(context).isDisable;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.add_to_photos, size: 30),
          onPressed:isDisable?null:()=>{}
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.file_download, size: 30),
          onPressed:isDisable?null:()=>{}
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.more_vert, size: 30,),
          onPressed:isDisable?null:()=>{}
        ),
        Spacer()
      ],
    );
  }

}

class SliverPlayButtons extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final isDisable = Provider.of<DisableButtonModel>(context).isDisable;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton.icon(
                color: Colors.white,
                textColor: Colors.black,
                icon: Icon(Icons.shuffle),
                label: Text('SHUFFLE'),
                onPressed:isDisable?null:()=>{},
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlineButton.icon(

                borderSide: BorderSide(
                  color: Colors.white
                ),
                icon: Icon(Icons.play_arrow),
                label: Text('PLAY'),
                onPressed:isDisable?null:()=>{},
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class PlaylistItem extends StatelessWidget{

  final List thumbnails;
  final String title;
  final String subtitle;
  final Map navigationEndpoint;

  PlaylistItem({@required json}):
    thumbnails = json['thumbnails'],
    title = json['title'],
    subtitle = json['subtitle'],
    navigationEndpoint = json['navigationEndpoint'];


  @override
  Widget build(BuildContext context) {

    return ListTile(
      dense: true,
//      isThreeLine: true,
      leading: Container(
        width: 80,
        child: Image.network(
          thumbnails.first['url']
        ),
      ),
      title: Text(title,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 2,
      ),
      subtitle: Text(subtitle,
        style: Theme.of(context).textTheme.bodyText2,
        maxLines: 1,
      ),
      trailing: Container(
        width: 30,
//        color: Colors.black,
        child: IconButton(
          iconSize: 24,
          icon: Icon(Icons.more_vert),
          onPressed: ()=>{},
        ),
      ),
    );
  }
}

class AlbumItem extends StatelessWidget{

  final String title;
  final String subtitle;
  final String videoId;
  final int index;

  AlbumItem({@required json, @required this.index}):
        title = json['title'],
        subtitle = json['subtitle'],
        videoId = json['videoId'];

  @override
  Widget build(BuildContext context) {

    return ListTile(
      dense: true,
//      isThreeLine: true,
      leading: Container(
        width: 40,
        child: Center(child:
        Text(index.toString(), style: Theme.of(context).textTheme.headline6))
      ),
      title: Text(title,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 2,
      ),
      subtitle: Text(subtitle,
        style: Theme.of(context).textTheme.bodyText2,
        maxLines: 1,
      ),
      trailing: Container(
        width: 30,
//        color: Colors.black,
        child: IconButton(
          iconSize: 24,
          icon: Icon(Icons.more_vert),
          onPressed: ()=>{},
        ),
      ),
    );
  }
}

class AlwaysActivityIndicator extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 128,
        child: const Center(child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
        ))
    );
  }
}