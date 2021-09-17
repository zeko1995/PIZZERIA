
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:pizzeria/CustomColors.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:pizzeria/Model/Category.dart';
import 'package:pizzeria/Model/PizzaType.dart';

class AddProduct extends StatefulWidget {
  final User _user;
  AddProduct(this._user);
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  FirebaseStorage storage = FirebaseStorage.instance;
  File _image;
  var  _value="Spicy";

  List<QueryDocumentSnapshot> listCategory;
  List<QueryDocumentSnapshot> listPizzaType;
  List<Category>categoryList = new List<Category>();
  List<PizzaType>pizzaTypeList = new List<PizzaType>();

  var tmpArray = [];

  TextEditingController mycontrollerTitle = TextEditingController();
  TextEditingController mycontrollerDesc= TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataCategory();
    getDataPizzaType();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Builder(
        builder: (context) =>
          SingleChildScrollView(child:  Column(children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: CustomColors.firebaseNavy,
                    child: ClipOval(
                      child: new SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: (_image != null) ? Image.file(
                          _image,
                          fit: BoxFit.fill,
                        ) : Image.network(
                          widget._user.photoURL,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child:   Padding(
                    padding: EdgeInsets.only(top: 70.0),
                    child: IconButton(
                      icon: Icon(
                        FontAwesomeIcons.camera,
                        size: 30.0,
                      ),
                      onPressed: () {
                        getImage();
                      },
                    ),
                  ),
                ),


              ],
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(

                controller: mycontrollerTitle,
                cursorColor: CustomColors.firebaseOrange,

                decoration: InputDecoration(


                  border: OutlineInputBorder(),
                  labelText: 'Add Title',
                  hintText: 'Add Title',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                cursorColor: CustomColors.firebaseOrange,

                controller: mycontrollerDesc,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Add Description',
                  hintText: 'Add Description',
                ),
              ),
            ),
             ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: categoryList==null?0:categoryList.length,
                itemBuilder: (context,index){

                  return ListTile(
                    title: Text(
                      categoryList[index].name.toString(),
                      style: Theme.of(context).textTheme.subtitle1.
                      copyWith(color: CustomColors.firebaseNavy),
                    ),
                    leading: Radio(
                      activeColor: CustomColors.firebaseOrange,
                      value:  categoryList[index].name,
                      groupValue: _value,


                      onChanged : (value) {
                        setState(() {
                          _value=value;
                          print(value.toString());


                          

                          
                          


                        });
                      },
                    ),
                  );
                }),

            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: pizzaTypeList==null?0 :pizzaTypeList.length,
                itemBuilder: (context,index){
                  return  CheckboxListTile(
                    title: new Text(pizzaTypeList[index].size),
                    subtitle: new Text(pizzaTypeList[index].price.toString()),
                    value: pizzaTypeList[index].check,
                    activeColor: Colors.pink,
                    checkColor: Colors.white,
                    onChanged: (bool value) {
                      setState(() {

                        pizzaTypeList[index].check=value;
                        if(pizzaTypeList[index].check){
                          tmpArray.add(pizzaTypeList[index].size+" \$"+pizzaTypeList[index].price.toString());

                        }else{
                          tmpArray.remove(pizzaTypeList[index].size+" \$"+pizzaTypeList[index].price.toString());
                        }

                        print(tmpArray);
                      });
                    },
                  );
                }),


            Align(alignment: Alignment.bottomCenter,child: RaisedButton(
              color: CustomColors.firebaseYellow,
              onPressed: () {
                uploadPicWithData(context);
              },

              elevation: 6.0,
              splashColor: Colors.blueGrey,
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),)
          ],),scrollDirection: Axis.vertical,)
      ),
    );
  }

  UploadIsDone(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      headerAnimationLoop: false,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Upload Success',
      desc: '',
      buttonsTextStyle: TextStyle(color: Colors.black),
      

      btnOkOnPress: () {

      },
    )..show();
  }



  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future uploadPicWithData(BuildContext context) async {

    try{

      String fileName = basename(_image.path);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref()
          .child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(_image);

      var snapshot = await uploadTask.whenComplete(() =>   UploadIsDone(context));
      var imageUrl = await firebaseStorageRef.getDownloadURL();

      CollectionReference collectionReference=
      FirebaseFirestore.instance.collection("Products");
      collectionReference.add(
        {
          "username": widget._user.displayName,
          "userUid":widget._user.uid,
          "image": imageUrl.toString(),
          "pizza_type":tmpArray.toList(),
          "type":_value.toString(),
          "title":mycontrollerTitle.text.toString(),
          "desc":mycontrollerDesc.text.toString()
        },
      );


    }catch(e){
      print(e.toString()+">>>>");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        headerAnimationLoop: false,
        animType: AnimType.BOTTOMSLIDE,
        title: 'Try Again',
        desc: e.toString(),
        btnOkColor: Colors.red,
        buttonsTextStyle: TextStyle(color: Colors.black),


        btnOkOnPress: () {

        },
      )..show();
    }


  }
   


  getDataCategory()async{

    CollectionReference collectionReference=
    FirebaseFirestore.instance.collection("Category");
    await collectionReference.get().then((value) {
      QuerySnapshot querySnapshot= value;
      setState(() {
      listCategory=querySnapshot.docs;
      listCategory.forEach((element) {
        categoryList.add(Category(element["id"], element["name"]));
      });




      });



    });
  }


  getDataPizzaType()async{

    CollectionReference collectionReference=
    FirebaseFirestore.instance.collection("Pizza_Type");
    await collectionReference.get().then((value) {
      QuerySnapshot querySnapshot= value;
      setState(() {
        listPizzaType=querySnapshot.docs;
        listPizzaType.forEach((element) {
          pizzaTypeList.add(PizzaType(element["price"], element["size"],element.id,false));
        });




      });



    });
  }
}