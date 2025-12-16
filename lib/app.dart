import 'package:flutter/material.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/scanner/presentation/scanner_page.dart';

class MealTrack extends StatefulWidget {
  const MealTrack({super.key});

  @override
  State<MealTrack> createState() => _MealTrackState();
}

class _MealTrackState extends State<MealTrack> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    InventoryPage(title: 'Digitaler Kühlschrank'),
    ScannerPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Inventar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scanner',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
