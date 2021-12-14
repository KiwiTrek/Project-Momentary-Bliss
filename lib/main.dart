import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:momentary_bliss/screens/todos_list_screen.dart';

const String user = "C7SK12awVm132rddXTQE"; //sample@gmail.com

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
    final stream = db.doc("/Users/$user").snapshots();
    return MaterialApp(
      title: 'Bentleys of Doom App',
      theme: ThemeData(primarySwatch: Colors.purple),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("FreundQuest"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                  stream: stream,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        snapshot,
                  ) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final doc = snapshot.data!;
                    final data = doc.data()!;
                    if (doc.data() != null) {
                      return Row(
                        children: [
                          const Icon(IcoFontIcons.moneyBag),
                          const SizedBox(width: 1),
                          Text(data['coins'].toString(),
                              style: const TextStyle(fontSize: 18))
                        ],
                      );
                    } else {
                      return Row(
                        children: const [
                          Icon(IcoFontIcons.moneyBag),
                          Text("<undefined>"),
                        ],
                      );
                    }
                  }),
            )
          ],
        ),
        body: const TodoListScreen(user: user),
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

// final db = FirebaseFirestore.instance;
// body: StreamBuilder(
//   stream: db.doc("/Testing/qtuQ0ddx22pLoPFNcOs3").snapshots(),
//   builder: (
//     BuildContext context,
//     AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
//   ) {
//     if (!snapshot.hasData) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     final doc = snapshot.data!.data();
//     if (doc != null) {
//       return Center(child: Text(doc['Prueba']));
//     } else {
//       return const Center(child: Text("Null!"));
//     }
//   },
// ),
