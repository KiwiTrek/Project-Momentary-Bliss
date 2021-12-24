import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  String id;
  String mail;
  String avatar;
  String uid;

  Friend.fromFirestore(this.id, Map<String, dynamic> json)
      : avatar = json['avatar'],
        uid = json['uid'],
        mail = json['mail'];
}

Stream<List<Friend>> userFriendSnapshots(String user) {
  final db = FirebaseFirestore.instance;
  final stream =
      db.collection("/Users/$user/friends").orderBy("uid").snapshots();
  return stream.map((query) {
    List<Friend> friends = [];
    for (final doc in query.docs) {
      friends.add(Friend.fromFirestore(doc.id, doc.data()));
    }
    return friends;
  });
}

Stream<List<Friend>> findFriends(String mail) {
  final db = FirebaseFirestore.instance;
  final stream = db.collection("/Users/").orderBy("uid").snapshots();
  return stream.map((query) {
    List<Friend> friends = [];
    for (final doc in query.docs) {
      if (doc.data()['mail'] == mail) {
        friends.add(Friend.fromFirestore(doc.id, doc.data()));
      }
    }
    return friends;
  });
}

void addFriend(String user, Friend friend) {
  final db = FirebaseFirestore.instance;
  db
      .collection("/Users/$user/friends")
      .add({'avatar': friend.avatar, 'uid': friend.uid, 'mail': friend.mail});
}

void deleteFriend(String user, String docId) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/friends/$docId").delete();
}

void undeleteFriend(String user, Friend friend) {
  final db = FirebaseFirestore.instance;
  db
      .doc("/Users/$user/friends/${friend.id}")
      .set({'avatar': friend.avatar, 'mail': friend.mail, 'uid': friend.uid});
}
