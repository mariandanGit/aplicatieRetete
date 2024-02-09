import 'package:aplicatie_retete/pages/search.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key}); // Constructorul clasei MainApp

  @override
  _MainAppState createState() => _MainAppState();
}

@override // Acest decorator trebuie să fie în interiorul clasei _MainAppState
class _MainAppState extends State<MainApp> {
  int _currentIndex = 0; // Indexul paginii curente
  late PageController _pageController; // Controller pentru PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex); // Inițializare PageController
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PageView( // Pagina principală este un PageView
          controller: _pageController,
          onPageChanged: (index) { // Funcție apelată când pagina se schimbă
            setState(() {
              _currentIndex = index; // Actualizare index pagină curentă
            });
          },
          children: [
            SearchPage(), // Adăugarea paginii de căutare în PageView
          ],
        ),
      ),
    );
  }
}
