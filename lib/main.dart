import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:momentary_bliss/models/quest.dart';
import 'package:momentary_bliss/models/reward.dart';
import 'package:momentary_bliss/screens/auth_gate.dart';
import 'package:momentary_bliss/screens/friends_list_screen.dart';
import 'package:momentary_bliss/screens/notifications_screen.dart';
import 'package:momentary_bliss/screens/rewards_list_screen.dart';
import 'package:momentary_bliss/screens/quests_list_screen.dart';
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

  void initialCreationFlow(User user) async {
    final userRef = FirebaseFirestore.instance.doc("/Users/${user.email}");
    final userSnap = await userRef.get();
    if (!userSnap.exists) {
      userRef.set({
        'avatar':
            "https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png",
        'coins': 0,
        'uid': user.uid,
        'mail': user.email,
        'reward_checker' : true
      });
      addQuest(user.email!, "Create a quest", 5, false);
      addReward(user.email!, "Get a cookie :)", 5);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    initialCreationFlow(user);
    return MaterialApp(
      title: 'Bentleys of Doom App',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: PersistentTabView(
        context,
        screens: [
          QuestListScreen(userMail: user.email.toString()),
          RewardListScreen(userMail: user.email.toString()),
          FriendListScreen(userMail: user.email.toString()),
          NotificationScreen(userMail: user.email.toString()),
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
                    QuestListScreen(userMail: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(userMail: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(userMail: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(userMail: user.email.toString()),
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
                    QuestListScreen(userMail: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(userMail: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(userMail: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(userMail: user.email.toString()),
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
                    QuestListScreen(userMail: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(userMail: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(userMail: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(userMail: user.email.toString()),
              },
            ),
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.notifications),
            title: ("Notifications"),
            activeColorPrimary: Colors.amber,
            inactiveColorPrimary: Colors.grey,
            routeAndNavigatorSettings: RouteAndNavigatorSettings(
              initialRoute: '/quest',
              routes: {
                '/quest': (context) =>
                    QuestListScreen(userMail: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(userMail: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(userMail: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(userMail: user.email.toString()),
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
                    QuestListScreen(userMail: user.email.toString()),
                '/reward': (context) =>
                    RewardListScreen(userMail: user.email.toString()),
                '/friends': (context) =>
                    FriendListScreen(userMail: user.email.toString()),
                '/user': (context) => UserScreen(user: user),
                '/notifications': (context) =>
                    NotificationScreen(userMail: user.email.toString()),
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
