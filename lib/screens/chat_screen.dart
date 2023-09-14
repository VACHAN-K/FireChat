import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String messagetext;
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void getCurrentUser() {
    final user = _auth.currentUser;
    try {
      if (user != null) loggedInUser = user;
      print(loggedInUser.email);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MsgStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messagetext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messagetext,
                        'sender': loggedInUser.email,
                        'time': Timestamp.now(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MsgStream extends StatelessWidget {
  const MsgStream({super.key});
  String extractNameFromEmail(String email) {
    int atIndex = email.indexOf('@');
    if (atIndex != -1) {
      return email.substring(0, atIndex);
    }
    return email; // Return the full email if "@" is not found
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore
            .collection('messages')
            .orderBy('time', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
          final messages = snapshot.data!.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final msgText = message.data()['text'];
            final messsageSender = message.data()['sender'];
            final messageTime = message.data()['time'];
            final name = extractNameFromEmail(messsageSender);

            final messageBubble = MessageBubble(
              text: msgText,
              sender: name,
              time: messageTime,
              isME: loggedInUser.email == messsageSender,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
              reverse: true,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.text,
      required this.sender,
      required this.isME,
      required this.time});
  String text;
  String sender;
  bool isME;
  Timestamp time;


  @override
  Widget build(BuildContext context) {
    // DateTime dateTime = time.toDate();
    // String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    // String formattedTime = '${dateTime.hour}:${dateTime.minute}';

    // Convert the Timestamp to DateTime
    DateTime dateTime = time.toDate();
    // Add the necessary time offset for Indian Standard Time (IST)
    // DateTime istDateTime = dateTime.add(const Duration(hours: 5, minutes: 30));
    // Format the DateTime to display the date and time in IST with AM/PM notation
    String formattedDateTime =
        DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isME ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$sender - $formattedDateTime',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Material(
            borderRadius: BorderRadius.only(
                topLeft: isME ? Radius.circular(30) : Radius.circular(0),
                topRight: isME ? Radius.circular(0) : Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            elevation: 5.0,
            color: isME ? Colors.blueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  '$text',
                  style: TextStyle(
                      fontSize: 15,
                      color: isME ? Colors.white : Colors.black54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
