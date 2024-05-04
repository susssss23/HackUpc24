import 'package:flutter/material.dart';
import 'package:my_web_app/domain/models/controlador_domini.dart';

class ControladorPresentacio {
  final controladorDomini = ControladorDomini();

  /*void mostrarAudioToText(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioToTextScreen(
          controladorPresentacio: this,
        ),
      ),
    );
  }*/

  Future<List<String>> sendPost(String question, String language) {
    return controladorDomini.sendPostRequest(question, language);
  }
}
