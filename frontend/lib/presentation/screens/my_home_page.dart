import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_web_app/presentation/controlador_presentacio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class MyHomePage extends StatefulWidget {
  final ControladorPresentacio controladorPresentacio;

  const MyHomePage({Key? key, required this.controladorPresentacio}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState(controladorPresentacio);
}

class _MyHomePageState extends State<MyHomePage> {
  late ControladorPresentacio _controladorPresentacio;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechIsEnabled = false;
  bool _isListeningToUser = false;
  double _confidence = 1.0;

  late Timer _timer;

  late String _textValueInQuestionBox;
  final TextEditingController _textEditingController = TextEditingController(text: '');
  String answerValueInScreen = '';

  _MyHomePageState(ControladorPresentacio controladorPresentacio) {
    _controladorPresentacio = controladorPresentacio;
    _textValueInQuestionBox = '';
  }

  // SEND QUESTION to DJANGO BACKEND
  void enviarMissatge() {_loadResposta(); }

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
    _initSpeech();
  }

  // Listening methods
  /// INIT: This has to happen only once per app
    void _initSpeech() async {
      _speechIsEnabled = await _speechToText.initialize();
      setState(() {});
    }


    /// Each time to start a speech recognition session
    void _startListening() async {
      await _speechToText.listen(
        listenOptions: SpeechListenOptions(cancelOnError: true, listenMode: ListenMode.dictation),
        onResult: _onSpeechResult,
        localeId: "en_En",
        pauseFor: const Duration(seconds: 10), //adjustt duration as needed
        listenFor: const Duration(seconds: 25), //adjustt duration as needed
      );
      setState(() {
        _isListeningToUser = true;
      });

      
      // Start the timer to periodically check if still listening
      _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (_speechToText.isNotListening) {
          // Speech recognition stopped
          _stopListening();
        }
      });
    }

    /// Manually stop the active speech recognition session
    /// Note that there are also timeouts that each platform enforces and the SpeechToText plugin supports setting timeouts on the listen method.
    void _stopListening() async {
      await _speechToText.stop();
      setState(() {
        _isListeningToUser = false;
        _timer.cancel();
      });
      log("END");
    }

    /// This is the callback that the SpeechToText plugin calls when the platform returns recognized words.
    void _onSpeechResult(SpeechRecognitionResult result) {
      setState(() {
        _textValueInQuestionBox = result.recognizedWords;
        if (result.hasConfidenceRating && result.confidence > 0) {
          _confidence = result.confidence;
        }
      });

      if (!_speechToText.isNotListening) {
        // Call _stopListening if speech recognition is still active
        log("IM USEFUL");
        _stopListening();
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(114, 28, 130, 1),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(114, 28, 130, 1), // Start color
                Color.fromRGBO(95, 36, 162, 1), // End color
              ],
            ),
          ),
        ),
        toolbarHeight: 80,
        title: const Text(
                  'AI Student Support Assistant',
                  style: TextStyle(
                    color: Color.fromARGB(255, 216, 185, 222),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic,
                  ),
        ),
        titleSpacing: 35.0,

      ),
      
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 100.0),
              const Padding(
                padding: EdgeInsets.only(right: 100.0, bottom: 5.0, top: 10.0),
                child: Text(
                  'Ask me anything',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    fontSize: 20.0,
                    fontStyle: FontStyle.italic,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextBox(),
        const SizedBox(width: 10.0),
        Column(
          children: [

            // SEND QUESTION BUTTON
            _buildIconButton(Icons.send, () => enviarMissatge()),
            const SizedBox(height: 10.0),

            // MIC BUTTON
            _buildIconButton(Icons.mic_rounded, 
              _speechToText.isNotListening ? _startListening : _stopListening
            ),
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
      child: _isListeningToUser ? _buildVoiceInput() : _buildTextInput(),
    );
  }

  Widget _buildTextInput() {

    _textEditingController.text = _textValueInQuestionBox; // Set text value
    
    return TextField(
      controller: _textEditingController,
      minLines: 5,
      maxLines: 10,
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
        setState(() {
          _textValueInQuestionBox = value;
        });
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

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: (icon == Icons.mic_rounded && _isListeningToUser) ? Colors.red : 
          (icon == Icons.delete && _textValueInQuestionBox == '') ? Colors.grey : Colors.purple,    
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
