//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/mediaQueryModels.dart';
import 'package:youmusic2/models/playerModels.dart';
import 'package:youmusic2/models/playlistModels.dart';
import 'package:youmusic2/models/watchListModels.dart';
import 'package:youmusic2/test/watch.dart';

import '../main.dart';
import 'package:youmusic2/models/controllerModels.dart';
import 'homeView.dart';

class PlaylistScreenArgs {
  final Map navigationEndPoint;
  final String thumbnail;
  final String title;
  final String subtitle;
  final String heroIdx;

  PlaylistScreenArgs(
    this.heroIdx,
    this.title,
    this.subtitle,
    this.thumbnail,
    this.navigationEndPoint,
  );
}

class PlayListScaffold extends StatefulWidget {
  final PlaylistScreenArgs args;

  PlayListScaffold(this.args, {Key key}) : super(key: key);

  @override
  _PlayListScaffoldState createState() => _PlayListScaffoldState();
}

class _PlayListScaffoldState extends State<PlayListScaffold> {
  bool _canPop = false;

  void _onDragEnd(DragEndDetails details) {
    if (details.primaryVelocity > 360 && _canPop) {
      Navigator.pop(context);
    }
    _canPop = false;
  }

  void _onDragDown(DragDownDetails details) {
    if (details.globalPosition.dx < 10.0) {
      _canPop = true;
    } else {
      _canPop = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = Provider.of<MediaProvider>(context, listen: false).data;

    return GestureDetector(
      onHorizontalDragDown: _onDragDown,
      onHorizontalDragEnd: _onDragEnd,
      child: Scaffold(
          body: MultiProvider(
        providers: [
          Provider<OpacityController>(create: (_) => OpacityController()),
          Provider<InfolistModel>(
              create: (_) => InfolistModel(widget.args.navigationEndPoint)),
          Provider<PlaylistScreenArgs>.value(value: widget.args)
        ],
        child: Stack(children: [
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
              icon: Icon(Icons.search, color: Colors.white, size: 26),
              onPressed: () => Navigator.pushNamed(context, '/search'),
            ),
          )
        ]),
      )),
    );
  }
}

class PlaylistSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final opController = Provider.of<OpacityController>(context, listen: false);
    final infoListModel = Provider.of<InfolistModel>(context);

    return ChangeNotifierProvider(
      create: (_) => DisableButtonModel(infoListModel.futureList),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          opController.changeScrollPos(notification.metrics.pixels);
          return true;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: const CustomScrollPhysics()),
          slivers: <Widget>[
            OpaqueSliverAppBar(),
            SliverPlayButtons(),
            FutureBuilder(
                future: infoListModel.futureList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return MainSliverList(snapshot.data,
                        isAlbum: infoListModel.isAlbum);
                  } else {
                    return SliverToBoxAdapter(
                      child: AlwaysActivityIndicator(),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}

class OpaqueSliverAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final opController = Provider.of<OpacityController>(context, listen: false);
    final screenArgs = Provider.of<PlaylistScreenArgs>(context, listen: false);
    return ChangeNotifierProvider.value(
      value: opController.appBar,
      child: Builder(builder: (context) {
        return SliverAppBar(
          leading: Container(),
          pinned: true,
          title: Padding(
              padding: EdgeInsets.only(right: 40),
              child: Consumer<OpacityModel>(
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.opacity,
                      child: child,
                    );
                  },
                  child: Text(screenArgs.title))),
          expandedHeight: 175 + kToolbarHeight,
          flexibleSpace: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                reverse: true,
                child: OpacityHead()),
          ), //todo
        );
      }),
    );
  }
}

class OpacityHead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('[$this]');
    final opController = Provider.of<OpacityController>(context, listen: false);
    final screenArgs = Provider.of<PlaylistScreenArgs>(context, listen: false);
    return ChangeNotifierProvider.value(
        value: opController.header,
        child: Container(
          height: 190,
          color: Theme.of(context).appBarTheme.color,
          child: Consumer<OpacityModel>(
            builder: (context, value, child) {
              return Opacity(
                opacity: value.opacity,
                child: child,
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: <Widget>[
                  Hero(
                    tag: screenArgs.heroIdx,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          screenArgs.thumbnail, //Todo
                          width: 150,
                          height: 150,
                          fit: BoxFit.fitHeight,
                        )),
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
                                  textStyle:
                                      Theme.of(context).textTheme.headline5),
                              maxLines: 3),
                          Text(screenArgs.subtitle, //todo
                              style: Theme.of(context).textTheme.bodyText2,
                              maxLines: 2),
                          HeadButtonGroup()
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class MainSliverList extends StatelessWidget {
  final List<Map> infoList;
  final bool isAlbum;

  MainSliverList(this.infoList, {@required this.isAlbum});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, idx) {
        return isAlbum
            ? AlbumItem(json: infoList[idx], index: idx + 1)
            : PlaylistItem(json: infoList[idx]);
      }, childCount: infoList.length),
    );
  }
}

class HeadButtonGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDisable = Provider.of<DisableButtonModel>(context).isDisable;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.add_to_photos, size: 30),
            onPressed: isDisable ? null : () => {}),
        Spacer(),
        IconButton(
            icon: Icon(Icons.file_download, size: 30),
            onPressed: isDisable ? null : () => {}),
        Spacer(),
        IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 30,
            ),
            onPressed: isDisable ? null : () => {}),
        Spacer()
      ],
    );
  }
}

class SliverPlayButtons extends StatelessWidget {
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
                onPressed: isDisable ? null : () => {},
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlineButton.icon(
                borderSide: BorderSide(color: Colors.white),
                icon: Icon(Icons.play_arrow),
                label: Text('PLAY'),
                onPressed: isDisable ? null : () => {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistItem extends StatelessWidget {
  final List thumbnails;
  final String title;
  final String subtitle;
  final Map navigationEndpoint;

  PlaylistItem({@required json})
      : thumbnails = json['thumbnails'],
        title = json['title'],
        subtitle = json['subtitle'],
        navigationEndpoint = json['navigationEndpoint'];

  void _onItemTap(BuildContext context) {
    final audioPlayer =
        Provider.of<AudioPlayerProvider>(context, listen: false);
    final infoProvider =
        Provider.of<PlayerInfoProvider>(context, listen: false);
    final animationController = getIt<BottomSheetControllerProvider>();
    final watchListProvider =
        Provider.of<WatchListProvider>(context, listen: false);
    String videoId = navigationEndpoint['watchEndpoint']['videoId'];

    infoProvider.setValue(
        Future.value(videoId),
        Future.value(thumbnails.last['url']),
        Future.value(title),
        Future.value(subtitle.split(' • ')[0]));
    animationController.animatedToS2();
    audioPlayer.playFromVideoId(videoId);
    watchListProvider.loadFromEndpoint(navigationEndpoint['watchEndpoint'],
        currentVideoId: videoId);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onItemTap(context),
      child: ListTile(
        dense: true,
//      isThreeLine: true,
        leading: Container(
          width: 80,
          child: Image.network(thumbnails.first['url']),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyText1,
          maxLines: 2,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyText2,
          maxLines: 1,
        ),
        trailing: Container(
          width: 30,
//        color: Colors.black,
          child: IconButton(
            iconSize: 24,
            icon: Icon(Icons.more_vert),
            onPressed: () => {},
          ),
        ),
      ),
    );
  }
}

class AlbumItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String videoId;
  final int index;

  AlbumItem({@required json, @required this.index})
      : title = json['title'],
        subtitle = json['subtitle'],
        videoId = json['videoId'];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
//      isThreeLine: true,
      leading: Container(
          width: 40,
          child: Center(
              child: Text(index.toString(),
                  style: Theme.of(context).textTheme.headline6))),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 2,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyText2,
        maxLines: 1,
      ),
      trailing: Container(
        width: 30,
//        color: Colors.black,
        child: IconButton(
          iconSize: 24,
          icon: Icon(Icons.more_vert),
          onPressed: () => {},
        ),
      ),
    );
  }
}

class AlwaysActivityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 128,
        child: const Center(
            child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
        )));
  }
}
