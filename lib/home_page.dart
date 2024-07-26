import 'package:fefoada_app/gallery_page.dart';
import 'package:fefoada_app/ranking_page.dart';
import 'package:fefoada_app/register/check_logged/checagem_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget centralWidget = Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xff5f2c82), Color(0xff49a09d)],
        stops: [0, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Container(
        margin: EdgeInsets.all(5),
        child: Image(
          image: AssetImage('assets/convite.jpg'),
        ),
      ),
    ),
  );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      setState(() {
        centralWidget = Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff5f2c82), Color(0xff49a09d)],
              stops: [0, 1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              margin: EdgeInsets.all(5),
              child: Image(
                image: AssetImage('assets/convite.jpg'),
              ),
            ),
          ),
        );
      });
    } else if (_selectedIndex == 1) {
      setState(() {
        centralWidget = const GalleryPage();
      });
    } else if (_selectedIndex == 2) {
      setState(() {
        centralWidget = Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff5f2c82), Color(0xff49a09d)],
              stops: [0, 1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'DESAFIOS',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      });
    } else if (_selectedIndex == 3) {
      setState(() {
        centralWidget = Center(
          child: Container(
            color: Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RankingList(),
            ),
          ),
        );
      });
    }
  }

  void showUserDialog(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userName = user.email ?? 'Usuário';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Bem-vindo, $userName',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Você está logado como $userName',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const CheckLoginPage();
                    },
                  ));
                },
                child: const Text(
                  'Sair',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showUserDialog(context);
              },
              icon: const Icon(Icons.account_circle)),
        ],
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          'FEFOADA APP',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: centralWidget,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Galeria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Desafios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Ranking',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
