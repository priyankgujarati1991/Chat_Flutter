import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/message_bubble.dart';

class Messages extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> getCurrentUID() async {
    final User user = await _auth.currentUser;
//    final String uid = user.uid;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCurrentUID(),
      builder: (ctx, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (ctx, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            QuerySnapshot chatDoc = chatSnapshot.data;

            return ListView.builder(
              reverse: true,
              itemCount: chatDoc.size,
              itemBuilder: (ctx, index) => MessageBubble(
                (chatDoc.docs[index]).get('text'),
                (chatDoc.docs[index]).get('userId') == snapShot.data.uid,
                ValueKey(chatDoc.docs[index].id),
                (chatDoc.docs[index]).get('userName'),
                (chatDoc.docs[index]).get('userImage'),
              ),
            );
          },
        );
      },
    );
  }
}
