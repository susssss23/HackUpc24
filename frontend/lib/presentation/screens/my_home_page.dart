import "package:flutter/material.dart";
import "package:my_web_app/presentation/controlador_presentacio.dart";
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MyHomePage extends StatefulWidget {
  final ControladorPresentacio controladorPresentacio;

  const MyHomePage({super.key, required this.controladorPresentacio});

  @override
  State<MyHomePage> createState() => _MyHomePageState(controladorPresentacio);
}

class _MyHomePageState extends State<MyHomePage> {
  late ControladorPresentacio _controladorPresentacio;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'aqui anira la veu';
  double _confidence = 1.0;
  String transcription = '';

  late String textEntered;

  _MyHomePageState(ControladorPresentacio controladorPresentacio) {
    _controladorPresentacio = controladorPresentacio;
    textEntered = '';
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void startListening() async {
    if (!_isListening) {
      bool available = await _speech!.initialize(
        onStatus: (status) => print('Speech recognition status: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
            onResult: (val) => setState(() {
                  _text = val.recognizedWords;
                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _confidence = val.confidence;
                  }
                }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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
              padding: EdgeInsets.only(right: 100.0, bottom: 25.0),
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
            Text(
              'Transcription: $_text',
              style: TextStyle(
                color: Colors.white,
              ),
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
        _buildTextBox(),
        const Padding(
          padding: EdgeInsets.all(10.0),
        ),
        Column(
          children: [
            _buildIconSend(),
            const SizedBox(
              height: 10.0,
            ),
            _buildIconMicro(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextBox() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.70,
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
    );
  }

  Widget _buildIconSend() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.send),
        color: Colors.white,
        iconSize: 30,
        onPressed: () {},
        padding: const EdgeInsets.all(9.0),
        splashRadius: 20,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildIconMicro() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.mic_rounded),
        color: Colors.white,
        iconSize: 30,
        onPressed: startListening,
        padding: const EdgeInsets.all(9.0),
        splashRadius: 20,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
