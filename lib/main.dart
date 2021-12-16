import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:momentary_bliss/screens/todos_list_screen.dart';
import 'package:momentary_bliss/screens/rewards_list_screen.dart';
import 'package:momentary_bliss/screens/friends_list_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

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
    return MaterialApp(
      title: 'Bentleys of Doom App',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: PersistentTabView(
        context,
        screens: const [
          TodoListScreen(user: user),
          RewardListScreen(user: user),
          FriendListScreen(user: user)
        ],
        items: [
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.task),
            title: ("Quests"),
            activeColorPrimary: Colors.purple,
            inactiveColorPrimary: Colors.grey,
            routeAndNavigatorSettings: RouteAndNavigatorSettings(
              initialRoute: '/quest',
              routes: {
                '/quest': (context) => const TodoListScreen(user: user),
                '/reward': (context) => const RewardListScreen(user: user),
                '/friends': (context) => const FriendListScreen(user: user)
              },
            ),
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(CommunityMaterialIcons.treasure_chest),
            title: ("Rewards"),
            activeColorPrimary: Colors.deepOrange,
            inactiveColorPrimary: Colors.grey,
            routeAndNavigatorSettings: RouteAndNavigatorSettings(
              initialRoute: '/quest',
              routes: {
                '/quest': (context) => const TodoListScreen(user: user),
                '/reward': (context) => const RewardListScreen(user: user),
                '/friends': (context) => const FriendListScreen(user: user)
              },
            ),
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.people),
            title: ("Friends"),
            activeColorPrimary: Colors.green,
            inactiveColorPrimary: Colors.grey,
            routeAndNavigatorSettings: RouteAndNavigatorSettings(
              initialRoute: '/quest',
              routes: {
                '/quest': (context) => const TodoListScreen(user: user),
                '/reward': (context) => const RewardListScreen(user: user),
                '/friends': (context) => const FriendListScreen(user: user)
              },
            ),
          ),
        ],
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
