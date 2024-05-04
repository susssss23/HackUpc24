import 'package:flutter/material.dart';
import 'package:my_web_app/presentation/controlador_presentacio.dart';
import 'package:my_web_app/presentation/screens/my_home_page.dart';

void main() {
  final controladorPresentacio = ControladorPresentacio();

  runApp(MyApp(controladorPresentacio: controladorPresentacio));
}

class MyApp extends StatefulWidget {
  final ControladorPresentacio controladorPresentacio;

  MyApp({Key? key, required this.controladorPresentacio}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState(controladorPresentacio);
}

class _MyAppState extends State<MyApp> {
  late ControladorPresentacio _controladorPresentacio;

  _MyAppState(ControladorPresentacio controladorPresentacio) {
    _controladorPresentacio = controladorPresentacio;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        body: MyHomePage(controladorPresentacio: _controladorPresentacio),
      ),
    );
  }
}
