import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:momentary_bliss/models/globals.dart';
import 'package:momentary_bliss/models/todo.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  final String user;

  const NotificationScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Provider.value(
    //   value: user,
    //   builder: (context, _) => StreamBuilder(
    //     stream: userTodoSnapshots(user),
    //     builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
    //       if (snapshot.hasError) {
    //         return ErrorWidget(snapshot.error!);
    //       }
    //       switch (snapshot.connectionState) {
    //         case ConnectionState.waiting:
    //           return const Scaffold(
    //             body: Center(child: CircularProgressIndicator()),
    //           );
    //         case ConnectionState.active:
    //           return _Screen(snapshot.data!, user);
    //         case ConnectionState.none:
    //           return ErrorWidget("The stream was wrong (connectionState.none)");
    //         case ConnectionState.done:
    //           return ErrorWidget("The stream has ended??");
    //       }
    //     },
    //   ),
    // );
    return _Screen(user);
  }
}

class _Screen extends StatefulWidget {
  // final List<Friends> friends;
  final String user;
  const _Screen(this.user);

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(color: green),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
            child: Row(
              children: const[
                Text("Notifications",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
        const Divider(
          height: 0,
          thickness: 2,
          color: lightGreen,
        ),
        // #### THE LIST ####
        // Expanded(
        //   child: ListView.separated(itemBuilder: itemBuilder, separatorBuilder: separatorBuilder, itemCount: itemCount),
        // ),
        const Expanded(
          child: Center(
            child: Text(
              "You got no notifications :)",
              style: TextStyle(color: Colors.green, fontSize: 22),
            ),
          ),
        ),
      ],
    );
  }
}