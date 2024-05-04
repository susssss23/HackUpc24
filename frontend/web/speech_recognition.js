// speech_recognition.js

let recognition;

function initializeSpeechRecognition() {
    if (!('webkitSpeechRecognition' in window)) {
        console.log('Speech recognition not supported.');
        return;
    }

    recognition = new webkitSpeechRecognition();
    recognition.continuous = true;
    recognition.interimResults = true;

    recognition.onresult = function(event) {
        let transcript = '';
        for (let i = event.resultIndex; i < event.results.length; ++i) {
            if (event.results[i].isFinal) {
                transcript += event.results[i][0].transcript;
            }
        }
        // Pass the transcript back to Flutter
        window.flutter_inappwebview.callHandler('onSpeechRecognitionResult', transcript);
    }

    recognition.onerror = function(event) {
        console.error('Speech recognition error:', event.error);
    }
}

function startSpeechRecognition() {
    if (recognition) {
        recognition.start();
    }
}

function stopSpeechRecognition() {
    if (recognition) {
        recognition.stop();
    }
}
