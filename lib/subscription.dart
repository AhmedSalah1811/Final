import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'about.dart';
import 'build_nav_button.dart';
import 'contact.dart';
import 'home_page.dart';
import 'login.dart';
import 'profile.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  _SubscriptionState createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  String? userToken;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    _checkUserToken();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
      ..loadRequest(Uri.parse("http://192.168.230.129:5173/"));
  }

  Future<void> _checkUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('user_token');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.black87,
        title: const Text(
          'Pricing',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
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
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: WebViewWidget(controller: webViewController),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    PriceDetails(
                      title: 'Starter',
                      price: '29',
                      duration: '/month',
                      features: [
                        'Up to 5 projects',
                        'Basic Components',
                        'Email Support',
                        'Tools',
                      ],
                    ),
                    PriceDetails(
                      title: 'Pro',
                      price: '59',
                      duration: '/month',
                      features: [
                        'Up to 10 projects',
                        'Advanced Components',
                        'Priority Support',
                        'Collaboration Tools',
                      ],
                    ),
                    PriceDetails(
                      title: 'Enterprise',
                      price: '99',
                      duration: '/month',
                      features: [
                        'Unlimited projects',
                        'All Components',
                        'Dedicated Support',
                        'Custom Solutions',
                      ],
                    ),
                  ],
                ),
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

class PriceDetails extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final List<String> features;

  const PriceDetails({
    Key? key,
    required this.title,
    required this.price,
    required this.duration,
    required this.features,
  }) : super(key: key);

  void sendSubscription(BuildContext context) async {
    final url = Uri.parse("https://ui-evolution.onrender.com/home/subscribe");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"plan": title, "price": price, "duration": duration}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Subscription Successful: $title")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subscription Failed, Try Again")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      height: 300,
      width: double.infinity,
      decoration:BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                price,
                style: const TextStyle(color: Colors.black, fontSize: 22),
              ),
              Text(
                duration,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map(
                (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '* $feature',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 280,
            child: ElevatedButton(
              onPressed: () => sendSubscription(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}