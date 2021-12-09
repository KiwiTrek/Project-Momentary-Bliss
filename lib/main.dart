import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  // For Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;
    return MaterialApp(
      title: 'Bentleys of Doom App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: StreamBuilder(
          stream: db.doc("/Testing/qtuQ0ddx22pLoPFNcOs3").snapshots(),
          builder: (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final doc = snapshot.data!.data();
            if (doc != null) {
              return Center(child: Text(doc['Prueba']));
            } else {
              return const Center(child: Text("Null!"));
            }
          },
        ),
      ),
    );
  }
}
