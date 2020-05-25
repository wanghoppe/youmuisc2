
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/temp/TabView.dart';

import 'package:youmusic2/views/homeView.dart';
import 'package:youmusic2/views/playlistView.dart';
import 'models/homeModels.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<ApiClient>(ApiClient());
}

void main(){
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  Route onGenRoute(RouteSettings settings){
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
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(color: Color.fromRGBO(20,20,20,1)),
        textTheme: TextTheme(
          headline5: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
//          display4: TextStyle(color: Colors.white)
          bodyText2: TextStyle(color: Colors.white54),
        ),
      ),
//      initialRoute: '/',
//      routes: {
//        '/' : (context) => HomeScaffold(),
////        '/playlist' : (context) => PlayListScaffold()
//      },
//      onGenerateRoute: onGenRoute,
      home: AppScaffold(),
    );
  }
}


class AppScaffold extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => TabControllerModel(),
      child: Builder(
        builder: (context){
          return Scaffold(
            body: HomeTabView(),
            bottomNavigationBar: HomeBottomNavigationBar()
          );
        }
      ),
    );
  }
}

class HomeTabView extends StatefulWidget{

  HomeTabView();

  @override
  _HomeTabViewState createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> 
    with SingleTickerProviderStateMixin{

  TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this, length: 3, initialIndex: 0
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final tabModel = Provider.of<TabControllerModel>(context,listen: false);
    tabModel.setController(_tabController);
    return TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeUnderTab(),
          Icon(Icons.directions_transit),
          Icon(Icons.directions_bike),
        ]
    );
  }
}

class HomeBottomNavigationBar extends StatefulWidget{
  @override
  _HomeBottomNavigationBarState createState() => _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  var _currentIdx = 0;

  void _onTap(int idx, TabController tabController){
    if (idx != _currentIdx){
      tabController.animateTo(idx);
      setState(() {
        _currentIdx = idx;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('building bottom bar');
    final tabController = Provider.of<TabControllerModel>(context, listen: false)
        .tabController;
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).appBarTheme.color ,
      type: BottomNavigationBarType.fixed ,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home) ,
          title: Text("Home") ,
        ) ,
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle) ,
            title: Text("Account")
        ) ,
        BottomNavigationBarItem(
          icon: Icon(Icons.settings) ,
          title: Text("Settings") ,
        )
      ] ,
      onTap: (idx) => _onTap(idx, tabController),
      currentIndex: _currentIdx ,
    );
  }
}