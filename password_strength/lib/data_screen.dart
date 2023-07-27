import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DataScreen extends StatefulWidget {
  final List<Map<String, String>> data;
  final Function(int) onDelete;
  final Function(int, Map<String, String>) onEdit;

  DataScreen({Key? key, required this.data, required this.onDelete, required this.onEdit}) : super(key: key);

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final storage = FlutterSecureStorage();
  String _strength = '';
  List<bool> _passwordVisibilityList = [];

  @override
  void initState() {
    super.initState();
    _passwordVisibilityList = List<bool>.filled(widget.data.length, false);
  }

  void _editEntry(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Entry'),
          content: EditEntryDialog(
            entry: widget.data[index],
            onEdit: (newEntry) {
              widget.onEdit(index, newEntry);
              setState(() {});
            },
          ),
        );
      },
    );
  }

  void _checkStrength(String password) {
    setState(() {
      int strength = 0;
      if (password.length > 8) strength++;
      if (password.length > 12) strength++;
      if (password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]'))) strength++;
      if (password.contains(RegExp(r'[0-9]'))) strength++;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

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

  void _changeMasterPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Change Master Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      storage.write(key: 'masterPassword', value: value);
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
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stored Data'),
        actions: <Widget>[
          TextButton(
            child: Text('Change Password', style: TextStyle(color: Colors.white)),
            onPressed: _changeMasterPassword,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.data[index]['website'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${widget.data[index]['email'] ?? ''}'),
                Row(
                  children: [
                    Text('Password: '),
                    _passwordVisibilityList[index]
                        ? Text('${widget.data[index]['password'] ?? ''}')
                        : Text('********'),
                    IconButton(
                      icon: Icon(_passwordVisibilityList[index]
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisibilityList[index] =
                          !_passwordVisibilityList[index];
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editEntry(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    widget.onDelete(index);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EditEntryDialog extends StatefulWidget {
  final Map<String, String> entry;
  final Function(Map<String, String>) onEdit;

  EditEntryDialog({Key? key, required this.entry, required this.onEdit}) : super(key: key);

  @override
  _EditEntryDialogState createState() => _EditEntryDialogState();
}

class _EditEntryDialogState extends State<EditEntryDialog> {
  TextEditingController websiteController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String _strength = '';

  @override
  void initState() {
    super.initState();
    websiteController.text = widget.entry['website'] ?? '';
    emailController.text = widget.entry['email'] ?? '';
    passwordController.text = widget.entry['password'] ?? '';
    _checkStrength(passwordController.text);
  }

  void _checkStrength(String password) {
    setState(() {
      int strength = 0;
      if (password.length > 8) strength++;
      if (password.length > 12) strength++;
      if (password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]'))) strength++;
      if (password.contains(RegExp(r'[0-9]'))) strength++;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

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
    return Column(
      children: <Widget>[
        TextField(
          controller: websiteController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Website',
          ),
        ),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Email',
          ),
        ),
        TextField(
          controller: passwordController,
          onChanged: (text) {
            _checkStrength(text);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Password',
          ),
          obscureText: true,
        ),
        Text(
          'Password Strength: $_strength',
          style: TextStyle(fontSize: 14.0),
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onEdit({'website': websiteController.text, 'email': emailController.text, 'password': passwordController.text});
          },
        ),
      ],
    );
  }
}
