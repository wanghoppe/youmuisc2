import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youmusic2/main.dart';
import 'package:youmusic2/models/ControllerModels.dart';
import 'package:youmusic2/views/homeView.dart';
import 'package:youmusic2/views/playlistView.dart';


class HomeUnderTab extends StatefulWidget{
  @override
  _HomeUnderTabState createState() => _HomeUnderTabState();
}

class _HomeUnderTabState extends State<HomeUnderTab> {

  HeroController _heroController;

  @override
  void initState() {
    super.initState();
    _heroController = HeroController(createRectTween: _createRectTween);
  }

  RectTween _createRectTween(Rect begin, Rect end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  Route _generateRoute(RouteSettings settings){
    if (settings.name == '/playlist') {

      final PlaylistScreenArgs args = settings.arguments;
      return PageRouteBuilder(
        pageBuilder: (context , animation , secondaryAnimation) =>
            PlayListScaffold(args) ,
        transitionsBuilder: (context , animation , secondaryAnimation , child) {
          return FadeTransition(
            opacity: animation,
            child: child ,
          );
        } ,
      );
    }else{
      return MaterialPageRoute(builder: (context) => HomeScaffold());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: getIt<HomeNavigatorController>().homeNavigator,
      observers: [_heroController],
      onGenerateRoute: _generateRoute
    );
  }
}