import 'package:demo_test/pages/cout_employe.dart';
import 'package:demo_test/pages/dividende.dart';
import 'package:demo_test/pages/emprunt.dart';
import 'package:demo_test/pages/salarie.dart';
import 'package:demo_test/pages/taux_marge.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    SimulationEmpruntPage(),
    DividendePage(),
    // ... other pages ...
    TauxDeMargePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300],
        elevation: 0,
        title: const Text('E M P R U N T'),
        // leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.person))],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.deepPurple[100],
          child: ListView(
            children: [
              const DrawerHeader(
                  child: Text(
                "C A L C U L E",
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              )),
              ListTile(
                  leading: const Icon(Icons.account_balance_sharp),
                  title: const Text('Salarie'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const CalculSalairePage()));
                  }),
              ListTile(
                  leading: const Icon(Icons.person_pin),
                  title: const Text('Coût employeur'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CoutEmployeurPage()));
                  }),
            ],
          ),
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'EMPRUNT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            label: 'DIVIDENDE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.balance_rounded),
            label: 'TAUX',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 106, 21, 192),
        onTap: _onItemTapped,
      ),
    );
  }
}
