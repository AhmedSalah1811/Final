import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'about.dart';
import 'build_nav_button.dart';
import 'chat_bot.dart';
import 'contact.dart';
import 'login.dart';
import 'subscription.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userToken;
  late WebViewController webViewController;
  final _formKey = GlobalKey<FormState>();
  bool hasLoggedError = false;

  @override
  void initState() {
    super.initState();
    _checkUserToken();

    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
          ..setBackgroundColor(Colors.transparent)
          ..setNavigationDelegate(
            NavigationDelegate(
              onWebResourceError: (WebResourceError error) {
                if (!hasLoggedError) {
                  debugPrint("WebView Error: ${error.description}");
                  hasLoggedError = true;
                }
              },
            ),
          )
          ..loadRequest(Uri.parse("http://192.168.230.129:5173/"));

      });
    });
  }

  Future<void> _checkUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('user_token');
    });
  }

  void navigateToChatBot(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatBot()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: userToken != null
          ? AppBar(
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(controller: webViewController),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text('Create Beautiful UIs Without Writing Code',style: TextStyle(fontSize: 27,color: Colors.blue,fontWeight: FontWeight.bold, ),textAlign: TextAlign.center,),
                  ),
                  SizedBox(height: 30,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Generate professional-grade user interfaces instantly with our powerful UI Generator . save time and focus what matter most.',style: TextStyle(fontSize: 15,color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => navigateToChatBot(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size(200, 50),
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              "Start Generate",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          // const SizedBox(height: 100),
                          // SizedBox(
                          //   height: 200,
                          //   child: ListView(
                          //     scrollDirection: Axis.horizontal,
                          //     children: const [
                          //       FeaturesBox(
                          //         title: 'Speed',
                          //         description:
                          //         'Generate complete UI in seconds not hours. Streamline your development.',
                          //       ),
                          //       FeaturesBox(
                          //         title: 'Customization',
                          //         description:
                          //         'Tailor every aspect of your UI to match your brand and requirements perfectly.',
                          //       ),
                          //       FeaturesBox(
                          //         title: 'Professional',
                          //         description:
                          //         'Get production-ready code that follows best practices and modern standards.',
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          if (userToken == null) ...[
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                text: 'You have 3 free prompts, want more? ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginPage(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),

                          ],
                          const SizedBox(height: 100),
                          SizedBox(
                            height: 200,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: const [
                                FeaturesBox(
                                  title: 'Speed',
                                  description:
                                  'Generate complete UI in seconds not hours. Streamline your development.',
                                ),
                                FeaturesBox(
                                  title: 'Customization',
                                  description:
                                  'Tailor every aspect of your UI to match your brand and requirements perfectly.',
                                ),
                                FeaturesBox(
                                  title: 'Professional',
                                  description:
                                  'Get production-ready code that follows best practices and modern standards.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(height: 60,
        child: BottomAppBar(
          color: Colors.black87,
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildNavButton(context, "assets/images/home.png", const HomePage(), widget.runtimeType),
                buildNavButton(context, "assets/images/about.png", AboutPage(), widget.runtimeType),
                buildNavButton(context, "assets/images/subscrption.png", const Subscription(), widget.runtimeType),
                buildNavButton(context, "assets/images/contact.png", const ContactPage(), widget.runtimeType),
                if (userToken == null)
                  buildNavButton(context, "assets/images/login.png", const LoginPage(), widget.runtimeType),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
