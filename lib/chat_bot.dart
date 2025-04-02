import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:gallery_saver/gallery_saver.dart';

import 'dart:io';
import 'login.dart';


class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController promptController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  String? authToken;
  String? loginPromptMessage;
  int attemptCount = 0;

  @override
  void initState() {
    super.initState();
    loadTokenAndAttempts();
    addInitialBotMessage();
  }

  void addInitialBotMessage() {
    setState(() {
      messages.add({
        "role": "bot",
        "message": "Hi!🖐🏻❤️\nHow can I help you today?😊",
        "type": "text",
      });

      messages.add({
        "role": "bot",
        "message": "🚀 For the ultimate experience in quality and performance, please use this app ONLY for creating user interfaces! 🎨✨",
        "type": "text",
      });
    });
  }


  Future<void> loadTokenAndAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('user_token');
      attemptCount = prefs.getInt('attempt_count') ?? 0;
      if (authToken == null) {
        attemptCount = 0;
        prefs.setInt('attempt_count', 0);
      }
    });
  }

  Future<void> saveAttemptCount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('attempt_count', attemptCount);
  }

  Future<void> sendMessage({String? resendMessage}) async {
    String userMessage = resendMessage ?? promptController.text;
    if (userMessage.isEmpty) return;

    if (authToken == null && attemptCount >= 3) {
      setState(() {
        loginPromptMessage = "You have reached 3 prompts. Want more, please ";
      });
      return;
    }

    setState(() {
      messages.add({"role": "user", "message": userMessage});
      isLoading = true;
      loginPromptMessage = null;

      if (authToken == null) {
        attemptCount++;
        saveAttemptCount();
      }
    });

    if (!userMessage.toLowerCase().contains("ui")) {
      setState(() {
        messages.add({
          "role": "bot",
          "message": "🎨🤖 UI magic only!\nWe only do UI, no AI overlords here!✨😎",
          "type": "text",

        });
        messages.add({
          "role": "bot",
          "message": "assets/images/put ui.png",
          "type": "image",
        });
      });
      isLoading = false;
      promptController.clear();
      return;
    }

    try {
      http.Response response = await http.post(
        Uri.parse('https://5f6a-197-53-108-220.ngrok-free.app/home/chat'),
        headers: {
          "Content-Type": "application/json",
          if (authToken != null) "Authorization": "Bearer $authToken",
          "ngrok-skip-browser-warning": "true",
        },
        body: jsonEncode({"message": userMessage}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String? imageUrl = data['imagePath'];

        if (imageUrl != null && imageUrl.isNotEmpty) {
          setState(() {
            messages.add({
              "role": "bot",
              "message": imageUrl,
              "type": "image",
              "showPoll": true,
            });
          });
        } else {
          setState(() {
            messages.add({
              "role": "bot",
              "message": "Failed to generate the UI😔.\nInvalid response from the server❌",
              "type": "text",
            });
            messages.add({
              "role": "bot",
              "message": "assets/images/Not-Found12.png",
              "type": "image",
            });
          });
        }
      } else {
        setState(() {
          messages.add({
            "role": "bot",
            "message": "Failed to connect to the server😔🚫. Please try again🔄️.",
            "type": "text",
          });
          messages.add({
            "role": "bot",
            "message": "assets/images/Error13.png",
            "type": "image",
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "role": "bot",
          "message": "Failed to connect to the server😔🚫. Please try again🔄️.",
          "type": "text",
        });
        messages.add({
          "role": "bot",
          "message": "assets/images/Error13.png",
          "type": "image",
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData.fallback().copyWith(color: Colors.white),
        title: const Text("UI Evolution Chat", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          if (loginPromptMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    loginPromptMessage!,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                if (message["role"] == "bot" && message["type"] == "image") {
                  String imageUrl = message["message"]!;
                  bool isLocal = imageUrl.startsWith("assets/");

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: isLocal
                                  ? Image.asset(
                                imageUrl,
                                fit: BoxFit.cover,
                              )
                                  : FadeInImage.assetNetwork(
                                placeholder: 'assets/loading.gif',
                                image: imageUrl,
                                fit: BoxFit.cover,
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return const Text('⚠️ Image can\'t load');
                                },
                              ),
                            ),
                          ),


                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download, color: Colors.green),
                                onPressed: () async {
                                  if (!isLocal) {
                                    final tempDir = await getTemporaryDirectory();
                                    final filePath = '${tempDir.path}/downloaded_image.png';
                                    final response = await http.get(Uri.parse(imageUrl));
                                    final file = File(filePath);
                                    await file.writeAsBytes(response.bodyBytes);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Image saved to gallery 📥")),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.blue),
                                onPressed: () {

                                },
                              ),
                            ],
                          ),
                        ],
                      ),


                      if (message["showPoll"] == true)
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Are you satisfied with the result? 😊",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),


                      if (message["showPoll"] == true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  messages.add({
                                    "role": "bot",
                                    "message": "Hope to reach your expectations.....🤩",
                                    "type": "text",
                                  });
                                  message["showPoll"] = false;
                                  promptController.clear();
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.green),
                              ),
                              child: const Text(
                                "Satisfied😁",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                sendMessage(resendMessage: messages[index - 1]["message"]);
                                setState(() {
                                  message["showPoll"] = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text(
                                "Not Satisfied😔",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }





                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: message["role"] == "user" ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    message["message"]!,
                    style: TextStyle(
                      color: message["role"] == "user" ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promptController,
                    decoration: InputDecoration(
                      hintText: "Enter your prompt here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


