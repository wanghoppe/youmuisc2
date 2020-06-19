
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/mediaQueryModels.dart';
import 'package:youmusic2/views/utilsView.dart';

class SearchScaffold extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: SearchBar(),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index){
          return ListTile(
            title: Text(index.toString()),
          );
      })
    );
  }
}

class SmallACIndicator extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
        height: kToolbarHeight,
        width: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Visibility(
            visible: false,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)
            ),
          ),
        )
    );
  }

}

class SearchBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final topPadding = Provider.of<MediaProvider>(context, listen: false).data.padding.top;
    const containerHeight = kToolbarHeight *2/3;

    return Padding(
      padding: EdgeInsets.only(top:topPadding),
      child: Stack(
        children: [Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.0 * 2),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(containerHeight/2),
              child: Container(
                height: containerHeight,
                color: Colors.white.withOpacity(0.12),
                child: Padding(
                  padding: const EdgeInsets.only(left: containerHeight/2),
                  child: TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      fillColor: Colors.red,
                      border: InputBorder.none,
                      hintText: 'Search songs, albums, artists'
                    ),
                    onSubmitted: (String text){
                      print(text);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: SmallACIndicator()
        )
        ],
      ),
    );
  }
}

class SearchResultView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}