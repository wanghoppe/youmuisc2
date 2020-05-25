import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youmusic2/views/homeView.dart';

class TabViewAppScaffold extends StatefulWidget {
  @override
  _TabViewAppScaffoldState createState() => _TabViewAppScaffoldState();
}

class _TabViewAppScaffoldState extends State<TabViewAppScaffold> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomeUnderScaffold(),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ]),
        bottomSheet: TabBar(
          tabs: [
            Tab(
                icon: Icon(Icons.directions_car), text: 'HOME',),
            Tab(
              icon: Icon(Icons.directions_transit),
            ),
            IconButton(icon: Icon(Icons.arrow_back)),
          ],
        ),
      ),
    );
  }
}
