import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
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
  String resposta = '';
  bool Micro = false;
  String respostaBack = '';

  late String textEntered;

  _MyHomePageState(ControladorPresentacio controladorPresentacio) {
    _controladorPresentacio = controladorPresentacio;
    textEntered = '';
  }

  void enviarMissatge() {
    //crida backend
    /*si el backend torna-> respostaBack*/
    _loadResposta();

    setState(() {
      resposta = respostaBack;
    });
  }

  Future<void> _loadResposta() async {
    String list = await _controladorPresentacio.sendPost(_text, "english");
    respostaBack = list;
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void startListening() async {
    if (Micro) {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (status) => print('Speech recognition status: $status'),
          onError: (error) => print('Error: $error'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(
              () {
                _text = val.recognizedWords;
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _confidence = val.confidence;
                }
              },
            ),
          );
        }
      } else {
        setState(() => _isListening = false);

        _speech.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Hack24"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(right: 100.0, bottom: 5.0, top: 10.0),
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
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
                child: _buildEnterBar(),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: Text(
                  'Confidence: $_confidence',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              _buildResposta(),
            ],
          ),
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
            const SizedBox(
              height: 10.0,
            ),
            _buildIconDelete(),
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
      child: Micro ? notEntering() : enteringTextField(),
    );
  }

  Widget enteringTextField() {
    return TextField(
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
        setState(() {
          Micro = false;
        });
      },
    );
  }

  Widget notEntering() {
    return Container(
      width: 280,
      height: 150,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(width: 5.0, color: Colors.purple),
        color: Colors.white,
      ),
      child: Text(
        _text,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildIconSend() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.send),
        color: Colors.white,
        iconSize: 30,
        onPressed: () {
          enviarMissatge();
        },
        padding: const EdgeInsets.all(9.0),
        splashRadius: 20,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildIconMicro() {
    return Container(
      decoration: BoxDecoration(
        color: Micro ? Colors.grey : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.mic_rounded),
        color: Colors.white,
        iconSize: 30,
        onPressed: () {
          startListening();
          setState(() {
            Micro = !Micro;
          });
        },
        padding: const EdgeInsets.all(9.0),
        splashRadius: 20,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildIconDelete() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.delete),
        color: Colors.white,
        iconSize: 30,
        onPressed: () {
          setState(() {
            _text = '';
            resposta = '';
          });
        },
        padding: const EdgeInsets.all(9.0),
        splashRadius: 20,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildResposta() {
    return SizedBox(
      width: 350,
      height: 470,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              resposta,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
