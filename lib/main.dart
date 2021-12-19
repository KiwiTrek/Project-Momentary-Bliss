import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:momentary_bliss/screens/auth_gate.dart';
import 'package:momentary_bliss/screens/friends_list_screen.dart';
import 'package:momentary_bliss/screens/notifications_screen.dart';
import 'package:momentary_bliss/screens/rewards_list_screen.dart';
import 'package:momentary_bliss/screens/todos_list_screen.dart';
import 'package:momentary_bliss/screens/user_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

void main() async {
  // For Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await dotenv.load(fileName: '.env');

  runApp(const AuthGate(app: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return MaterialApp(
      title: 'Bentleys of Doom App',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: PersistentTabView(
        context,
        screens: [
          TodoListScreen(user: user.email.toString()),
          RewardListScreen(user: user.email.toString()),
          FriendListScreen(user: user.email.toString()),
          NotificationScreen(user: user.email.toString()),
          UserScreen(user: user)
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
                '/quest': (context) =>
                    TodoListScreen(user: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(user: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(user: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(user: user.email.toString()),
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
                '/quest': (context) =>
                    TodoListScreen(user: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(user: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(user: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(user: user.email.toString()),
              },
            ),
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.people_alt),
            title: ("Friends"),
            activeColorPrimary: Colors.green,
            inactiveColorPrimary: Colors.grey,
            routeAndNavigatorSettings: RouteAndNavigatorSettings(
              initialRoute: '/quest',
              routes: {
                '/quest': (context) =>
                    TodoListScreen(user: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(user: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(user: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(user: user.email.toString()),
              },
            ),
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.notifications),
            title: ("Notifications"),
            activeColorPrimary: Colors.green,
            inactiveColorPrimary: Colors.grey,
            routeAndNavigatorSettings: RouteAndNavigatorSettings(
              initialRoute: '/quest',
              routes: {
                '/quest': (context) =>
                    TodoListScreen(user: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(user: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(user: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(user: user.email.toString()),
              },
            ),
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.person),
            title: ("My Profile"),
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
            routeAndNavigatorSettings: RouteAndNavigatorSettings(
              initialRoute: '/quest',
              routes: {
                '/quest': (context) =>
                    TodoListScreen(user: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(user: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(user: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(user: user.email.toString()),
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
