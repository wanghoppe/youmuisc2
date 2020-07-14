import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/playerModels.dart';
import 'package:youmusic2/models/watchListModels.dart';
import 'package:youmusic2/views/utilsView.dart';

class WatchListFull extends StatelessWidget {
  static const minBottomListHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).appBarTheme.color,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          height: minBottomListHeight,
          child: Row(
            children: [
              Icon(Icons.queue_music, size: 34),
              SizedBox(width: 8),
              Text('Up Next', style: Theme.of(context).textTheme.headline5),
            ],
          )),
        Expanded(child: WatchListView())
      ],
    );
  }
}

class WatchListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final watchListProvider = Provider.of<WatchListProvider>(context);
    if (watchListProvider.loading) {
      return GeneralActivityIndicatorContainer();
    } else {
      return ListView.builder(
        itemBuilder: (context, index) {
          return ChangeNotifierProvider<WatchItemProvider>.value(
              value: watchListProvider.watchList[index],
              child: WatchItemView(idx: index));
        },
        itemCount: watchListProvider.watchList.length
      );
    }
  }
}

class WatchItemView extends StatelessWidget {
  final int idx;

  WatchItemView({Key key, this.idx}) : super(key: key);

  void _onItemTap(BuildContext context, WatchItemProvider itemProvider) {
    final watchListProvider =
        Provider.of<WatchListProvider>(context, listen: false);
    final player = Provider.of<AudioPlayerProvider>(context, listen: false);
    final playerInfo = Provider.of<PlayerInfoProvider>(context, listen: false);

    watchListProvider.changePlayIndex(idx);
    playerInfo.setValue(
        Future.value(itemProvider.videoId),
        Future.value(itemProvider.thumbnail2),
        Future.value(itemProvider.title),
        Future.value(itemProvider.channel)
    );
    player.playFromVideoId(itemProvider.videoId);
  }

  @override
  Widget build(BuildContext context) {
//    print('[$this]');
    final itemProvider = Provider.of<WatchItemProvider>(context);
    return InkWell(
      onTap: () => _onItemTap(context, itemProvider),
      child: Container(
        color: itemProvider.playing ? Colors.white12 : null,
        child: CustomListTile(
          title: itemProvider.title,
          subtitle: itemProvider.subtitle,
          heroIdx: itemProvider.videoId,
          imgUrl: itemProvider.thumbnail1,
        ),
      ),
    );
  }
}
