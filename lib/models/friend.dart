import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  String id;
  String mail;
  String avatar;
  String uid;
  bool selected;

  Friend()
      : id = "-1",
        mail = "undefined",
        avatar = "undefined",
        uid = "undefined",
        selected = false,
        super();

  Friend.fromFirestore(this.id, Map<String, dynamic> json)
      : avatar = json['avatar'],
        uid = json['uid'],
        mail = json['mail'],
        selected = json['selected'];

  Friend.foundFriend(this.id, Map<String, dynamic> json)
      : avatar = json['avatar'],
        uid = json['uid'],
        mail = json['mail'],
        selected = false;
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

Stream<List<Friend>> findFriendList(String mail) {
  final db = FirebaseFirestore.instance;
  final stream = db.collection("/Users/").orderBy("uid").snapshots();
  return stream.map((query) {
    List<Friend> friends = [];
    for (final doc in query.docs) {
      if (doc.data()['mail'].toString().contains(mail)) {
        friends.add(Friend.foundFriend(doc.id, doc.data()));
      }
    }
    return friends;
  });
}

void addFriend(String user, String who) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$who").get().then((value) => {
        db.collection("/Users/$user/friends").add({
          'avatar': value["avatar"],
          'uid': value["uid"],
          'mail': value["mail"],
          'selected': value["selected"]
        })
      });
}

void setSelected(String user, Friend who, bool selected) {
  final db = FirebaseFirestore.instance;
  db.collection("/Users/$user/friends/").get().then((snapshot) {
    List<Friend> friends = [];
    for (final doc in snapshot.docs) {
      friends.add(Friend.fromFirestore(doc.id, doc.data()));
    }
    for (final friend in friends) {
      db.doc("/Users/$user/friends/${friend.id}").update({'selected': false});
    }
    db.doc("/Users/$user/friends/${who.id}").update({'selected': selected});
  });
}

void deleteFriend(String user, String docId) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/friends/$docId").delete();
}

void undeleteFriend(String user, Friend friend) {
  final db = FirebaseFirestore.instance;
  db.doc("/Users/$user/friends/${friend.id}").set({
    'avatar': friend.avatar,
    'mail': friend.mail,
    'uid': friend.uid,
    'selected': friend.selected
  });
}
