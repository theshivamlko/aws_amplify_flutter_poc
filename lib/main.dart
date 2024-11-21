import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String status = "";

  TextEditingController _nameController = TextEditingController(text: "Shivam");
  TextEditingController _emailController = TextEditingController(text: "sshivam@citridot.com");
  TextEditingController _passwordController = TextEditingController(text: "Qwerty@123");

  late CognitoUserPool userPool;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        print("SchedulerBinding init");

        setState(() {
          status = "Loading config";
        });
        final config = await loadConfig();
        print("SchedulerBinding loadConfig");
        setState(() {
          status = "Config loaded";
        });
        userPool = CognitoUserPool(config.userPoolID, config.clientID);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("Status: \n$status"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Signup"),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Enter your Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Enter your email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Enter your Password'),
              ),
              ElevatedButton(
                  onPressed: () {
                    signup();
                  },
                  child: Text("Signup")),
              Padding(padding: EdgeInsets.all(20)),
              Divider(height: 2),
              Padding(padding: EdgeInsets.all(20)),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: 'Enter your email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Enter your Password'),
              ),
              ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text("Login")),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void signup() {
    print("Name: ${_emailController.text}");
    print("Email: ${_emailController.text}");
    print("Password: ${_passwordController.text}");
    var attributes = [
      AttributeArg(name: 'name', value: _nameController.text),
    ];

    setState(() {
      status = "Doing Signup";
    });
    userPool.signUp(_emailController.text, _passwordController.text, userAttributes: attributes).then((value) {
      print("Signup success: $value");
      setState(() {
        status = "Signup success \n${value.userConfirmed}, ${value.user.username}";
      });
    }).catchError((error) {
      print("Signup error: $error");
      setState(() {
        status = "Signup error \n$error";
      });
    });
  }

  void login() {
    setState(() {
      status = "Doing Login";
    });
    var cognitoUser = CognitoUser(_emailController.text, userPool);
    var authDetails = AuthenticationDetails(username: _emailController.text, password: _passwordController.text);
    cognitoUser.authenticateUser(authDetails).then(
      (value) {
        if (value == null) {
          setState(() {
            status = "Session not found";
          });
          return;
        }
        var claims = <String, dynamic>{};
        claims.addAll(value.idToken.payload);
        claims.addAll(value.accessToken.payload);

        setState(() {
          status = "Login result \n$claims";
        });
      },
    ).catchError((error) {
      setState(() {
        status = "Signup error \n$error";
      });
    });
  }

  Future<Config> loadConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> config = json.decode(configString);

    return Config(config['UserPoolID'], config['ClientID']);
  }
}

class Config {
  String userPoolID;
  String clientID;

  Config(this.userPoolID, this.clientID);
}
