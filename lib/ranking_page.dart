import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RankingList extends StatefulWidget {
  @override
  _RankingListState createState() => _RankingListState();
}

class _RankingListState extends State<RankingList> {
  String loggedUsername = '';

  @override
  void initState() {
    super.initState();
    findingLoggedUsername();
  }

  void findingLoggedUsername() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        setState(() {
          loggedUsername = doc['nome'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .orderBy('pontos', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Nenhum dado encontrado'));
        }

        final users = snapshot.data!.docs;

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'PESSOA - PONTOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  Icon? medalIcon;
                  if (index == 0) {
                    medalIcon =
                        const Icon(Icons.looks_one, color: Colors.amber);
                  } else if (index == 1) {
                    medalIcon = const Icon(Icons.looks_two, color: Colors.grey);
                  } else if (index == 2) {
                    medalIcon = const Icon(Icons.looks_3, color: Colors.brown);
                  }

                  return ListTile(
                    title: Row(
                      children: [
                        if (medalIcon != null) medalIcon,
                        const SizedBox(
                          width: 10,
                        ),
                        Text('${index + 1}. ${user['nome']}'),
                        if (user['nome'] == loggedUsername)
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                      ],
                    ),
                    trailing: Text('${user['pontos']} pontos',
                        style: const TextStyle(color: Colors.black)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
