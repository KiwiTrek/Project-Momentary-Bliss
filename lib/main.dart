import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'globals.dart';

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
      theme: ThemeData(primarySwatch: Colors.purple),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("FreundQuest"),
        ),
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
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.task), label: "Checklist"),
            BottomNavigationBarItem(
                icon: Icon(CommunityMaterialIcons.treasure_chest),
                label: "Rewards")
          ],
          backgroundColor: darkPurple,
          fixedColor: Colors.white,
        ),
      ),
    );
  }
}
