import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pizzeria/Model_View_LoginPage/LoginPage.dart';
import 'package:pizzeria/Model_Authentication/Authentication.dart';

import '../CustomColors.dart';

class AppBarTitle extends StatefulWidget {
  @override
  _AppBarTitleState createState() => _AppBarTitleState();
  final String displayName;
  final String photoURL;

  AppBarTitle(this.displayName, this.photoURL);

  bool _isSigningOut = false;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

  class _AppBarTitleState extends State<AppBarTitle> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        SizedBox(width: 8),
       widget.photoURL != null
            ? CircleAvatar(
          backgroundImage: NetworkImage(
            widget.photoURL,


          ),

        ): CircleAvatar(
          backgroundImage: NetworkImage(
            widget.photoURL.toString(),


          ),
        ),


        Expanded(child: Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: Center(child: Text(
      widget.displayName,
    style: TextStyle(
    color: CustomColors.firebaseYellow,
    fontSize: 18,
    ),
    )),
    ), ),
        widget._isSigningOut
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Colors.redAccent,
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          onPressed: () async {



            widget. _isSigningOut = true;

            await Authentication.signOut(context: context);

            widget._isSigningOut = false;


             Navigator.of(context).pushReplacement(widget._routeToSignInScreen());
          },
          child: Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Icon(Icons.exit_to_app,color: Colors.white,),
          ),
        ),



      ],
    );
  }
}