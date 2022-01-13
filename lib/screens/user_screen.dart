import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:momentary_bliss/models/globals.dart';

class UserScreen extends StatefulWidget {
  final User user;
  const UserScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  void changeState(bool value)
  {
    final db = FirebaseFirestore.instance;
  db.doc("/Users/${widget.user.email}").update({"reward_checker" : value});
  }
  @override
  Widget build(BuildContext context) {
    final systemBarHeight = MediaQuery.of(context).viewPadding.top;
    final stream = FirebaseFirestore.instance
        .doc("/Users/${widget.user.email}")
        .snapshots();
    return Column(children: [
      Container(
        decoration: const BoxDecoration(color: Colors.blue),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10 + systemBarHeight, 16, 10),
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
                    trailing: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Text("${data["coins"]}",
                          style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      CommunityMaterialIcons.treasure_chest,
                      size: 32,
                      color: Colors.deepOrange,
                    ),
                    title: const Text("Enable friend approval"),
                    subtitle: const Text("Allow friends to choose for your rewards", style: TextStyle(fontSize: 13),),
                    trailing: Switch(value: data['reward_checker'], onChanged: changeState, activeColor: Colors.blue, inactiveThumbColor: Colors.grey[600],),
                  ),
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
