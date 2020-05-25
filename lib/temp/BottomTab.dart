import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youmusic2/views/homeView.dart';

class AppScaffoldBottomTab extends StatefulWidget{
  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffoldBottomTab> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  var _currentTabIndex = 0;

  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "Account":
        return MaterialPageRoute(builder: (context) => HomeUnderScaffold());
      case "Settings":
        return MaterialPageRoute(builder: (context) =>
            Container(
                color: Colors.green , child: Center(child: Text("Settings"))));
      default:
        return MaterialPageRoute(builder: (context) =>
            Container(
                color: Colors.white , child: Center(child: Text("Home"))));
    }
  }

  void _onTap(int tabIndex) {
    switch (tabIndex) {
      case 0:
        _navigatorKey.currentState.pushNamed("Home");
        break;
      case 1:
        _navigatorKey.currentState.pushNamed("Account");
        break;
      case 2:
        _navigatorKey.currentState.pushNamed("Settings");
        break;
    }
    setState(() {
      _currentTabIndex = tabIndex;
    });
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
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
      onTap: _onTap ,
      currentIndex: _currentTabIndex ,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey ,
        onGenerateRoute: generateRoute ,
      ) ,
      bottomSheet: IntrinsicHeight(
        child: Column(
            children: [ Container(color: Colors.blue , height: 100 ,) ,
              _bottomNavigationBar()]) ,
      ) ,
//      bottomNavigationBar: _bottomNavigationBar(),
    );
  }
}