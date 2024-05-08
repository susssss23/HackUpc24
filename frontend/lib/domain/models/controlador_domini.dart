import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';
import "dart:convert";
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";

class ControladorDomini {
  final apiUrl = "http://192.168.50.181:8000/api/post";
  final _random = Random();

  Future<String> sendPostRequest(String question, String language) async {

    dev.log("SENT QUESTION : $question");
    var response;
    try {
        response = await http.post(Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "question": question,
            "language": language,
          })).timeout(const Duration(seconds: 10));
          } on TimeoutException {
      print("throws"); // Prints "throws" after 2 seconds.
    }

    if (response != null && response.statusCode == 200) {
      dynamic jsonResponse = jsonDecode(response.body);
      // Check if jsonResponse is a List or a Map

      if (jsonResponse.containsKey('response')) {
        // Access the value of the 'attribute'
        String attributeValue = jsonResponse['response'];
        dev.log("RESPONSE : $attributeValue");
        return attributeValue.replaceAll('\n', ' ');

      } else {
        throw Exception('Attribute not found in JSON response');
      }
    } else {
      dev.log("ERROR : $response.body");
      //throw Exception('Failed to load data from API');
      return _getRandomString();

    }
  }
   String _getRandomString() {
    List<String> options = [
      '''Sembrava a prima vista tanto perbenino
      Si offre a far da guida per la città
      Pedro, Pedro, Pedro, Pedro, Pè
      Praticamente il meglio di Santa Fè
      Pedro, Pedro, Pedro, Pedro, Pè
      Fidati di me''',

      '''Albion Online es un mmorpg no lineal, en el que escribes tu propia historia sin limitarte a seguir un camino prefijado. Explora un amplio mundo abierto con 5 biomas únicos, todo cuánto hagas tendrá su repercusión en el mundo, con la economía orientada al jugador de Albion, los jugadores crean prácticamente todo el equipo a partir de los recursos que consiguen, el equipo que llevas define quién eres, cambia de arma y armadura para pasar de caballero a mago, o juega como una mezcla de ambas clases. Aventúrate en el mundo abierto frente a los habitantes y las criaturas de Albion, inicia expediciones o adéntrate en mazmorras en las que encontrarás enemigos aún más difíciles, enfréntate a otros jugadores en encuentros en el mundo abierto, lucha por los territorios o por ciudades enteras en batallas tácticas, relájate en tu isla privada, donde podrás construir un hogar, cultivar cosechas y criar animales, únete a un gremio, todo es mejor cuando se trabaja en grupo. Adéntrate ya en el mundo de Albion y escribe tu propia historia. ''',
      
      '''My scientific thesis that pee is stored in the balls:
       - Men's bathrooms have urinals, and stalls. Urinals are for peeing. Stalls are for pooping and heroin and anonymous homosex. Men have balls.
       - Women bathrooms only have stalls. and women have no balls.
       - Quod Erad Demonstrandum''',
      "IDK ask ur mom."
    ];
    return options[_random.nextInt(4)];
  }
}
