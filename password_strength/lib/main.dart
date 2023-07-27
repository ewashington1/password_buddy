import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'data_screen.dart';

void main() {
  runApp(PasswordStrengthChecker());
}

class PasswordStrengthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Buddy',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        backgroundColor: Colors.grey[200],
        fontFamily: 'Open Sans',
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.purple,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: PasswordStrengthCheckerHome(title: 'Password Buddy'),
    );
  }
}

class PasswordStrengthCheckerHome extends StatefulWidget {
  PasswordStrengthCheckerHome({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _PasswordStrengthCheckerHomeState createState() => _PasswordStrengthCheckerHomeState();
}

class _PasswordStrengthCheckerHomeState extends State<PasswordStrengthCheckerHome> {
  final storage = FlutterSecureStorage();
  String _password = '';
  String _strength = '';
  String _masterPassword = '';
  String _enteredMasterPassword = '';  // Declare the new variable here
  String _email = '';
  String _website = '';
  List<Map<String, String>> _data = [];

  @override
  void initState() {
    super.initState();
    _checkMasterPassword();
  }

  Future<void> _checkMasterPassword() async {
    String? masterPassword = await storage.read(key: 'masterPassword');
    if (masterPassword == null) {
      _promptForMasterPassword();
    } else {
      _masterPassword = masterPassword;
    }
  }

  void _promptForMasterPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Set Master Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      _masterPassword = value;
                      _checkStrength(value);
                      setState(() {});
                    },
                    obscureText: true,
                  ),
                  Text(
                    'Password Strength: $_strength',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    storage.write(key: 'masterPassword', value: _masterPassword);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _storeData() async {
    Map<String, String> entry = {
      'email': _email,
      'password': _password,
      'website': _website,
    };
    _data.add(entry);
    await storage.write(key: 'data', value: jsonEncode(_data));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data stored successfully!')),
    );
  }

  Future<void> _editData(int index, Map<String, String> newEntry) async {
    _data[index] = newEntry;
    await storage.write(key: 'data', value: jsonEncode(_data));
  }


  Future<void> _retrieveData() async {
    String? masterPassword = await storage.read(key: 'masterPassword');
    print('Master password: $masterPassword');
    if (masterPassword == _enteredMasterPassword) {  // Use the different variable here
      String? dataString = await storage.read(key: 'data');
      print('Data string: $dataString');
      if (dataString != null) {
        List<dynamic> dataList = jsonDecode(dataString);
        _data = dataList.map((item) => Map<String, String>.from(item)).toList();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DataScreen(data: _data, onDelete: _deleteData, onEdit: _editData)),
        );


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data to retrieve!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect master password!')),
      );
    }
  }

  Future<void> _deleteData(int index) async {
    _data.removeAt(index);
    await storage.write(key: 'data', value: jsonEncode(_data));
  }


  void _checkStrength(String password) {
    setState(() {
      _password = password;

      int strength = 0;
      if (_password.length > 8) strength++;
      if (_password.length > 12) strength++;
      if (_password.contains(RegExp(r'[a-z]')) && _password.contains(RegExp(r'[A-Z]'))) strength++;
      if (_password.contains(RegExp(r'[0-9]'))) strength++;
      if (_password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

      switch (strength) {
        case 0:
        case 1:
          _strength = 'Very Weak';
          break;
        case 2:
          _strength = 'Weak';
          break;
        case 3:
          _strength = 'Medium';
          break;
        case 4:
          _strength = 'Strong';
          break;
        case 5:
          _strength = 'Very Strong';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Buddy'),
        leading: Icon(Icons.lock),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  onChanged: (text) {
                    setState(() {
                      _website = text;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter the website',
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  onChanged: (text) {
                    setState(() {
                      _email = text;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                  ),
                ),
                SizedBox(height: 8.0),
                SizedBox(height: 8.0),
                TextField(
                  onChanged: (text) {
                    _checkStrength(text);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8.0),
                Text(
                  'Password Strength: $_strength',
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _storeData,
                  child: Text('Store Data'),
                ),
                SizedBox(height: 8.0),
                TextField(
                  onChanged: (text) {
                    setState(() {
                      _enteredMasterPassword = text;  // Use the different variable here
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your master password',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _retrieveData,
                  child: Text('Retrieve Data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
