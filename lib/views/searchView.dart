import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/client/searchUtils.dart';
import 'package:youmusic2/models/controllerModels.dart';
import 'package:youmusic2/models/mediaQueryModels.dart';
import 'package:youmusic2/models/playerModels.dart';
import 'package:youmusic2/models/searchModels.dart';
import 'package:youmusic2/views/playlistView.dart';
import 'package:youmusic2/views/utilsView.dart';

import '../main.dart';

class SearchScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SearchCloseProvider>(
          create: (context) => SearchCloseProvider(),
        ),
        ChangeNotifierProvider<SearchBodyProvider>(
          create: (context) => SearchBodyProvider(),
        )
      ],
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.color,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 26),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Builder(
                builder: (context) {
                  final bodyProvider = Provider.of<SearchBodyProvider>(context, listen: false);
                  return ChangeNotifierProvider<SearchingIndicator>.value(
                    value: bodyProvider.indicator,
                    child: SearchBar());
                }),
          ),
          body: SearchBodyView()
      ),
    );
  }
}

class SmallACIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: kToolbarHeight,
        width: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<SearchingIndicator>(
            builder: (context, value, child){
              return Visibility(visible: value.searching, child: child);
            },
            child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
        ));
  }
}

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  final _controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text){
    final searchClose = Provider.of<SearchCloseProvider>(context, listen: false);
    if (text == ''){
      searchClose.setShow(false);
    }else{
      searchClose.setShow(true);
    }
  }

  void _onClosePressed(){
    final searchClose = Provider.of<SearchCloseProvider>(context, listen: false);
    _controller.clear();
    searchClose.setShow(false);
  }


  @override
  Widget build(BuildContext context) {
    final topPadding =
        Provider.of<MediaProvider>(context, listen: false).data.padding.top;
    const containerHeight = kToolbarHeight * 2 / 3;

    final bodyProvider = Provider.of<SearchBodyProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.0 * 2),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(containerHeight / 2),
                child: Container(
                  height: containerHeight,
                  color: Colors.white.withOpacity(0.12),
                  child: Padding(
                    padding: const EdgeInsets.only(left: containerHeight / 2),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                          fillColor: Colors.red,
                          border: InputBorder.none,
                          hintText: 'Search songs, albums, artists'),
                      onSubmitted: bodyProvider.search,
                      onChanged: _onTextChanged,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(right: 0, child: SmallACIndicator()),
          Positioned(
            right: 26.0 * 2,
            child: Container(
              height: kToolbarHeight,
              child: Consumer<SearchCloseProvider>(
                builder: (context, value, child) {
                  return Visibility(visible: value.show, child: child);
                },
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _onClosePressed,
                ),
              )
            ),
          )
        ],
      ),
    );
  }
}

class SearchBodyView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final searchBody = Provider.of<SearchBodyProvider>(context);
    switch (searchBody.type){
      case SearchBodyType.result:
        return SearchResultView(searchBody.json);
      default:
        return Container();
    }
  }

}

class SearchResultView extends StatelessWidget {

  final List<Map> sections;
  final List<Map> header;

  SearchResultView(Map json, {Key key}):
      sections = json['sections'],
      header = json['header'],
      super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (context, index) => SearchResultSection(sections[index]),
    );
  }
}


class SearchResultSection extends StatelessWidget{

  final String title;
  final bool hasMore;
  final Map searchEndpoint;
  final List<Map> rows;

  SearchResultSection(json, {Key key}):
    title = json['title'],
    hasMore = json['hasMore'],
    searchEndpoint = (json['hasMore'])? json['searchEdpoint'] :null,
    rows = json['rows'],
    super(key:key);


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left:16.0, top: 4.0, bottom: 4.0),
            child: Container(
              height: kToolbarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(title,
                    style: GoogleFonts.lato(
                      textStyle: Theme.of(context).textTheme.headline)
                  ),
                  Visibility(
                    visible: hasMore,
                    child: IconButton(icon: Icon(Icons.navigate_next),
                      iconSize: 26,
                      color: Colors.white,
                      onPressed: (){},
                    ),
                  )
                ],
              ),
            ),
          ),
          ...rows.asMap().entries.map<Widget>((e){
            final idx = e.key;
            final json = e.value;
            return SearchResultRow(json, superTitle: title, idx:idx);
          }),
          SizedBox(height: 16),
          Container(color: Colors.white30, height: 1)
        ],
      ),
    );
  }
}

class SearchResultRow extends StatelessWidget{

  final String title;
  final String subtitle;
  final String thumbnail1;
  final String thumbnail2;
  final SearchRowType type;
  final Map endpoint;
  final bool cropCircle;
  final String superTitle;
  final int idx;


  SearchResultRow(json, {Key key, this.superTitle, this.idx}):
        title = json['title'],
        subtitle = json['subtitle'],
        thumbnail1 = json['thumbnail1'],
        thumbnail2 = json['thumbnail2'],
        type = json['type'],
        endpoint = json['endpoint'],
        cropCircle = json['cropCircle'],
        super(key:key);

  void _onItemTap(BuildContext context){

    if (type == SearchRowType.player) {
      final audioPlayer = Provider.of<AudioPlayerProvider>(
          context , listen: false);
      final infoProvider = Provider.of<PlayerInfoProvider>(
          context , listen: false);
      final animationController = getIt<BottomSheetControllerProvider>();

      infoProvider.setValue(
          Future.value(thumbnail2) ,
          Future.value(title) ,
          Future.value(subtitle.split(' • ')[1]));
      animationController.animatedToS2();

      String videoId = endpoint['videoId'];
      audioPlayer.playFromVideoId(videoId);

    } else if (type == SearchRowType.playlist){
        Navigator.pushNamed(
          context,
          '/playlist',
          arguments: PlaylistScreenArgs(
              superTitle + idx.toString(),
              title,
              subtitle,
              thumbnail2,
              {'browseEndpoint': endpoint}
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onItemTap(context),
      child: CustomListTile(
        title: title,
        subtitle: subtitle,
        imgUrl: (type == SearchRowType.player)? thumbnail1: thumbnail2,
        cropCircle: cropCircle,
        heroIdx: superTitle + idx.toString(),
        morePressed: (){},
      ),
    );
  }
}
