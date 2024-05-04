import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:my_web_app/presentation/controlador_presentacio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MyHomePage extends StatefulWidget {
  final ControladorPresentacio controladorPresentacio;

  const MyHomePage({Key? key, required this.controladorPresentacio}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState(controladorPresentacio);
}

class _MyHomePageState extends State<MyHomePage> {
  late ControladorPresentacio _controladorPresentacio;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late String _textValueInQuestionBox;
  TextEditingController _textEditingController = TextEditingController(text: '');
  double _confidence = 1.0;
  String answerValueInScreen = '';
  bool _isMicrophoneActive = false;

  _MyHomePageState(ControladorPresentacio controladorPresentacio) {
    _controladorPresentacio = controladorPresentacio;
    _textValueInQuestionBox = '';
  }

  void enviarMissatge() {
    _loadResposta();
  }

  Future<void> _loadResposta() async {
    String resultRequest =
        await _controladorPresentacio.sendPost(_textValueInQuestionBox, "english");

    setState(() {
      answerValueInScreen = resultRequest;
    });
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void startListening() async {
    if (_isMicrophoneActive) {
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
                _textValueInQuestionBox = val.recognizedWords;
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
        backgroundColor: Theme.of(context).colorScheme.secondary,
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
                    fontFamily: 'Montserrat',
                    fontSize: 20.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
        const SizedBox(width: 10.0),
        Column(
          children: [

            // SEND QUESTION BUTTON
            _buildIconButton(Icons.send, () => enviarMissatge()),
            const SizedBox(height: 10.0),

            // MIC BUTTON
            _buildIconButton(Icons.mic_rounded, () {
              startListening();
              setState(() {
                _isMicrophoneActive = !_isMicrophoneActive;
              });
            }),
            const SizedBox(height: 10.0),

            // erase button
            _buildIconButton(Icons.delete, () {
              setState(() {
                log("erase values");
                _textValueInQuestionBox = '';
                answerValueInScreen = '';
              });
            }),
          ],
        ),
      ],
    );
  }

// Question Text Area
  Widget _buildTextBox() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.70,
      child: _isMicrophoneActive ? _buildVoiceInput() : _buildTextInput(),
    );
  }

  Widget _buildTextInput() {

    _textEditingController.text = _textValueInQuestionBox; // Set text value
    
    return TextField(
      controller: _textEditingController,
      maxLines: 4,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Enter Question...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(width: 5.0, color: Colors.purple),
        ),
      ),
      onChanged: (value) {
        _textValueInQuestionBox = value;
        //setState(() {
        //  _isMicrophoneActive = false;
        //});
      },
    );
  }

  Widget _buildVoiceInput() {
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
        _textValueInQuestionBox,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }


  // PARENT CLASS for ICON BUTTONS
  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: icon == Icons.mic_rounded ? (_isMicrophoneActive ? Colors.red : Colors.grey) : Colors.purple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 30,
        onPressed: onPressed,
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
              answerValueInScreen,
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
