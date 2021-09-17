import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizzeria/Model/Products.dart';
import 'package:pizzeria/Widget/AppBarTitle.dart';
import 'package:pizzeria/Widget/ProvidedStyles.dart';

import '../CustomColors.dart';

class HomePage extends StatefulWidget {
   HomePage({  User user})
      : _user = user,
        super();

  final User _user;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  User user;
  List<QueryDocumentSnapshot> listProducts;
  List<Products> productList =new List<Products>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataProducts();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child: Padding(child: ListView.builder(

            itemCount: productList==null?0:productList.length,
            itemBuilder: (context,index){

              return Card(child: Column(children: [
                Padding(padding: EdgeInsets.all(3),child:  CircleAvatar(
                  radius: 50,
                  backgroundColor: CustomColors.firebaseNavy,
                  child:  ClipOval(
                    child: new SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: Image.network(
                        productList[index].image.toString(),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),




                ),),
                Padding(padding: EdgeInsets.all(3),child: Center(child:  Text(
                  productList[index].username.toString(),
                  style: Theme.of(context).textTheme.headline5.
                  copyWith(color: CustomColors.firebaseNavy),
                ),),),
                Padding(padding: EdgeInsets.all(3),child:Text(
                  productList[index].title.toString(),
                  style: Theme.of(context).textTheme.headline6.
                  copyWith(color: CustomColors.firebaseNavy),

                ),),


                Row(children: [
                  Padding(padding:
                  EdgeInsets.all(3),child:
                  Text(
                    productList[index].type.toString(),
                    style: Theme.of(context).textTheme.subtitle1.
                    copyWith(color: CustomColors.firebaseNavy),
                  ),),




                ],),
                Padding(padding:
                EdgeInsets.all(3),child:
                Text(
                  productList[index].pizza_type.toString(),
                  style: Theme.of(context).textTheme.subtitle1.
                  copyWith(color: CustomColors.firebaseNavy),
                ),),
                Row(children: [
                  Padding(padding: EdgeInsets.all(3),child:  Text(
                    productList[index].desc.toString(),
                    style: Theme.of(context).textTheme.subtitle1.
                    copyWith(color: CustomColors.firebaseNavy),
                  ),),




                ],)

              ],),color: CustomColors.firebaseYellow,);
            }),padding: EdgeInsets.all(12),),)


    );
  }

  getDataProducts()async{

    CollectionReference collectionReference=
    FirebaseFirestore.instance.collection("Products");
    await collectionReference.get().then((value) {
      QuerySnapshot querySnapshot= value;
      setState(() {
        listProducts=querySnapshot.docs;
        listProducts.forEach((element) {
          productList.add(Products(element["image"],element["username"],
              element["title"],element["desc"],
              element["pizza_type"],element["type"],element["userUid"]));
        });




      });



    });
  }
}
