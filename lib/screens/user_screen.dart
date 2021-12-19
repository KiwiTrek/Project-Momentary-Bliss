import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  final User user;
  const UserScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .doc("/Users/${widget.user.email}")
        .snapshots();
    return Column(children: [
      Container(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              const Text("My Profile",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Expanded(child: SizedBox()),
              IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                    size: 32,
                  ))
            ],
          ),
        ),
      ),
      const Divider(
        height: 0,
        thickness: 2,
        color: Colors.blueAccent,
      ),
      const SizedBox(
        height: 10,
      ),
      StreamBuilder(
          stream: stream,
          builder: (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final doc = snapshot.data!;
            final data = doc.data()!;
            if (doc.data() != null) {
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: NetworkImage(data["avatar"]),
                    ),
                    title: Text(widget.user.uid),
                    subtitle: Text(widget.user.email.toString()),
                  ),
                  ListTile(
                    leading: const Icon(
                      IcoFontIcons.coins,
                      size: 32,
                      color: orange,
                    ),
                    title: const Text("Coins"),
                    trailing: Text("${data["coins"]}",
                        style: const TextStyle(fontSize: 32)),
                  )
                ],
              );
            } else {
              return const ListTile(
                  leading: CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.blueGrey,
                  ),
                  title: Text("<<Undefined>>"));
            }
          })
    ]);
  }
}
