import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('Energy/Voice/Today');
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _recongnizedText = "";
  bool _isListening = false;

  late DatabaseReference _dbRef;
  final String _targetA = "turn on the light";
  final String _targetB = "turn off the light";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            IconButton(
              onPressed:
              _speech.isNotListening ? _startListening : _stopListening,// _startListening,
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              iconSize: 100,
              color: _isListening ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            Container(
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _recongnizedText.isNotEmpty
                      ? _recongnizedText
                      : "Result here......",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    ),
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: _recongnizedText.isNotEmpty ? _copyText : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Copy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      ),),
                ),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: _recongnizedText.isNotEmpty ? _clearText : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
    @override
  void initState() {
    super.initState();
    _initFirebase();
    _initSpeechState();
  }

  void _initFirebase() async {
    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAAgJxwkOvlu2zR7AluMjxKxRrhjqokW1E",
        authDomain: "energy-system-esp32.firebaseapp.com",
        databaseURL:
            "https://energy-system-esp32-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "energy-system-esp32",
        storageBucket: "energy-system-esp32.firebasestorage.app",
        messagingSenderId: "818419284691",
        appId: "1:818419284691:web:0e684af580bf3e914a3226",
      ),
    );
  }

  void _initSpeechState() async {
    bool available = await _speech.initialize();
    if (!mounted) return;
    setState(() {
      _isListening = available;
    });
  }

  void _startListening() {
    _speech.listen(onResult: (result) {
      setState(() {
        _recongnizedText = result.recognizedWords;
      });
    });
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
        _processRecognizedText(_recongnizedText);
    _speech.stop();
    setState(() {
      _isListening = false;
    });

    // So sánh đoạn text và gửi dữ liệu
  }

  void _processRecognizedText(String text) {
    // Loại bỏ khoảng trắng đầu/cuối và chuyển chữ thường để so sánh
    String cleanedText = text.trim().toLowerCase();
    if (cleanedText == _targetA.toLowerCase()) {
      _sendDataToFirebase(1); // Gửi số 1 nếu giống A
    } else if (cleanedText == _targetB.toLowerCase()) {
      _sendDataToFirebase(0); // Gửi số 0 nếu giống B
    }
  }

  void _sendDataToFirebase(int number) {
    _databaseReference.set(number).then((value) {
      _showSnackBar('Đã gửi giá trị: $number lên Firebase');
    }).catchError((error) {
      _showSnackBar('Lỗi khi gửi dữ liệu: $error');
    });
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: _recongnizedText));
    _showSnackBar('Text copied');
  }

  void _clearText() {
    _speech.stop();
    setState(() {
      _recongnizedText = '';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

}
