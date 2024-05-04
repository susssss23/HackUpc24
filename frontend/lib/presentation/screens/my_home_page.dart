import "package:flutter/material.dart";
import "package:my_web_app/presentation/controlador_presentacio.dart";

class MyHomePage extends StatefulWidget {
  final ControladorPresentacio controladorPresentacio;

  const MyHomePage({super.key, required this.controladorPresentacio});

  @override
  State<MyHomePage> createState() => _MyHomePageState(controladorPresentacio);
}

class _MyHomePageState extends State<MyHomePage> {
  late ControladorPresentacio _controladorPresentacio;

  bool defaultState = false;
  bool selectedMirco = false; //si no es selected micro es selectedText

  late String textEntered;

  _MyHomePageState(ControladorPresentacio controladorPresentacio) {
    _controladorPresentacio = controladorPresentacio;
    textEntered = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Hack24"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(right: 340.0, bottom: 25.0),
              child: Text(
                'Ask me anything',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Monsterrat',
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: _buildEnterBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.5,
          //equivalen a  50% de la pantalla
          child: TextField(
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Enter...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: const BorderSide(width: 5.0, color: Colors.purple),
              ),
            ),
            onChanged: (value) {
              textEntered = value;
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(10.0),
        ),
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.white,
                iconSize: 30,
                onPressed: () {
                  setState(() {
                    defaultState = false;
                    selectedMirco = true;
                  });
                },
                padding: const EdgeInsets.all(9.0),
                splashRadius: 20,
                constraints: BoxConstraints(),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.mic_rounded),
                color: Colors.white,
                iconSize: 30,
                onPressed: () {
                  setState(() {
                    defaultState = false;
                    selectedMirco = true;
                  });
                },
                padding: const EdgeInsets.all(9.0),
                splashRadius: 20,
                constraints: BoxConstraints(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
