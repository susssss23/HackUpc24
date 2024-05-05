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
  late Timer _timer2;
  int i = 0;

   List<String> chatHistory = [];

  late String _textValueInQuestionBox;
  final TextEditingController _textEditingController = TextEditingController(text: '');
  String answerValueInScreen = '';

  _MyHomePageState(ControladorPresentacio controladorPresentacio) {
    _controladorPresentacio = controladorPresentacio;
    _textValueInQuestionBox = '';
  }

  // SEND QUESTION to DJANGO BACKEND
  void enviarMissatge() {
    setState(() {
      chatHistory = [_textValueInQuestionBox];
      _textValueInQuestionBox = '';
      chatHistory.add("...");
    });
    _timer2 = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      i = (i % 3) + 1;
      setState(() {
        chatHistory[chatHistory.length-1] = "." * i + " "*(3-i);
      });
    });
    _loadResposta();
  }

  Future<void> _loadResposta() async {
    String resultRequest =
        await _controladorPresentacio.sendPost(_textValueInQuestionBox, "english");
    _timer2.cancel();
    setState(() {
      _timer2.cancel();
      chatHistory[chatHistory.length-1] = resultRequest;
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
      body: Column(
        children: [
          Expanded(
            child: _buildChatHistory(),
          ),
          const SizedBox(height: 35.0),
          _buildEnterBar(),
          const SizedBox(height: 35.0),
        ],
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
                _confidence = 1.0;
                chatHistory = [];
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
      width: MediaQuery.of(context).size.width * 0.77,
      child: _buildTextInput(),
    );
  }

  Widget _buildTextInput() {

    _textEditingController.text = _textValueInQuestionBox; // Set text value
  
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          width: _isListeningToUser ? 6.0 : 3.0,
          color: _isListeningToUser ? Colors.red : Colors.purple,
        ),
        color: Colors.white,
      ),
      child: TextField(
        controller: _textEditingController,
        minLines: 6,
        maxLines: 10,
        decoration: const InputDecoration(
          hintText: 'Enter Question...',
          fillColor: Colors.white,
          filled: true,
          border: InputBorder.none,
        ),
        onChanged: (value) {
          setState(() {
            _textValueInQuestionBox = value;
          });
        },
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: (icon == Icons.mic_rounded && _isListeningToUser) ? Colors.red : 
          (icon == Icons.delete && _textValueInQuestionBox == '' && chatHistory.length == 0) ? Colors.grey : Colors.purple,    
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 30,
        onPressed: (icon == Icons.delete && _textValueInQuestionBox == '' && chatHistory.length == 0) ? null : onPressed,
        padding: const EdgeInsets.all(9.0),
        splashRadius: 20,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildChatHistory() {
    return Container(
      width: double.infinity,
      height: 300, // Or any other fixed height
      //color: Colors.blue,
      child: Column(
        children: [
          const SizedBox(height: 40.0),
          const Text(
            'Ask me anything',
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              fontSize: 30.0,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(chatHistory[index], index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildChatBubble(String message, int index) {
    final isUserMessage = index % 2 == 0; // Alternate message alignment

    return Column(
      crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: isUserMessage ? [Colors.purple, const Color.fromARGB(255, 114, 27, 130)] : [Color.fromARGB(255, 212, 161, 222), Color.fromARGB(255, 208, 114, 227)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75, // Set maximum width as 80% of screen width
          ),
          child: Text(
            message,
            
            style: const TextStyle(color: Colors.white, fontSize: 16.0,),
          ),
        ),
        if (!isUserMessage) const SizedBox(height: 10), // Add extra space after every second message
      ],
    );
  }
}