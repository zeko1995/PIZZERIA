import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:pizzeria/CustomColors.dart';
import 'package:pizzeria/Model_View_AddProducat/AddProduct.dart';
import 'package:pizzeria/Model_View_HomePage/HomePage.dart';
import 'package:pizzeria/Model_View_Map/GoogleMap.dart';
import 'package:pizzeria/Widget/AppBarTitle.dart';


class ProvidedStyles extends StatefulWidget {
  final User user;

  ProvidedStyles(this.user) ;
  @override
  _ProvidedStylesState createState() => _ProvidedStylesState();
}



class _ProvidedStylesState extends State<ProvidedStyles> {
  int _selectedIndex = 0;



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      HomePage(user: widget.user,),

      GoogleMaps(widget.user),

      AddProduct(widget.user)

    ];

    return Scaffold(
      appBar: AppBar(backgroundColor: CustomColors.firebaseNavy,
        title: AppBarTitle(widget.user.displayName, widget.user.photoURL),
      ),
      body: Center(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: CustomColors.firebaseYellow,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_sharp),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Product',
          ),

        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
