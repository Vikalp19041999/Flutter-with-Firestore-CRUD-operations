import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String myText;
  StreamSubscription<DocumentSnapshot> subscription;
  final DocumentReference documentReference =
      Firestore.instance.collection('myDB').document('dummy');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)) as FirebaseUser;
    print("signed in " + user.displayName);
    return user;
  }

  _signOut() {
    googleSignIn.signOut();
  }

  _addData() {
    Map<String, String> data = <String, String>{
      "name": "Vikalp Chakravorty",
      "position": "Flutter Developer"
    };
    documentReference.setData(data).whenComplete(() {
      print("Document added");
    }).catchError((e) => print(e));
  }

  _updateData() {
    Map<String, String> data = <String, String>{
      "name": "Vikalp Chakravorty",
      "position": "Flutter and React Native Developer"
    };
    documentReference.updateData(data).whenComplete(() {
      print('Document updated');
    }).catchError((e) => print(e));
  }

  _deleteData() {
    documentReference.delete().whenComplete(() {
      print('Deleted Successfully');
      setState(() {});
    }).catchError((e) => print(e));
  }

  _fetchData() {
    documentReference.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          myText = datasnapshot.data["position"];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = documentReference.snapshots().listen((datasnapshot) {
      if (datasnapshot.exists) {
        setState(() {
          myText = datasnapshot.data['desc'];
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD operations Firebase"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              onPressed: () =>
                  _signIn().then((FirebaseUser user) => print(user)),
              child: Text('Sign In'),
              color: Colors.red,
            ),
            Padding(padding: EdgeInsets.all(10)),
            RaisedButton(
                onPressed: _signOut,
                child: Text('Sign Out'),
                color: Colors.lightBlue),
            Padding(padding: EdgeInsets.all(10)),
            RaisedButton(
                onPressed: _addData,
                child: Text('Add Data'),
                color: Colors.teal),
            Padding(padding: EdgeInsets.all(10)),
            RaisedButton(
                onPressed: _updateData,
                child: Text('Update Data'),
                color: Colors.amberAccent),
            Padding(padding: EdgeInsets.all(10)),
            RaisedButton(
                onPressed: _deleteData,
                child: Text('Delete Data'),
                color: Colors.deepOrangeAccent),
            Padding(padding: EdgeInsets.all(10)),
            RaisedButton(
                onPressed: _fetchData,
                child: Text('Fetch Data'),
                color: Colors.purpleAccent),
            Padding(padding: EdgeInsets.all(10)),
            myText == null
                ? Container()
                : Text(myText, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
