import 'package:flutter/material.dart';

import 'finalpagesimplex.dart';
import 'simplex_Home_Page.dart';

/*
void main() {
  runApp(SimplexApp());
}

class SimplexApp extends StatelessWidget {
  const SimplexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Méthode du Simplexe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SimplexPage(simplex: null,),
    );
  }
}

*/

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Simplex Method App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SimplexSolver());
  }
}
