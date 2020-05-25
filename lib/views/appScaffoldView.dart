
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmusic2/models/homeModels.dart';
import 'homeTabView.dart';

class AppScaffold extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => TabControllerModel(),
      child: Builder(
          builder: (context){
            return Scaffold(
                body: AppTabView(),
                bottomNavigationBar: AppBottomNavigationBar()
            );
          }
      ),
    );
  }
}

class AppTabView extends StatefulWidget{

  AppTabView();

  @override
  _AppTabViewState createState() => _AppTabViewState();
}

class _AppTabViewState extends State<AppTabView>
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

class AppBottomNavigationBar extends StatefulWidget{
  @override
  _AppBottomNavigationBarState createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
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
      selectedItemColor: Colors.white,
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

class AnimateScaffold extends StatefulWidget{
  @override
  _AnimateScaffoldState createState() => _AnimateScaffoldState();
}

class _AnimateScaffoldState extends State<AnimateScaffold>
    with SingleTickerProviderStateMixin{

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(microseconds: 500)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

  }
}