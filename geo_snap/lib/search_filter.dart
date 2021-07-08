import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

class SearchFilter extends StatefulWidget {
  final Function updateKeyword;
  SearchFilter(this.updateKeyword);
  @override
  State<StatefulWidget> createState() {
    return _SearchFilter(updateKeyword);
  }
}

class _SearchFilter extends State<SearchFilter> {
  static final List<String> filterOptions = <String>[
    "Bakery",
    "Bar",
    "Cafe",
    "Restaurant",
    "Supermarket"
  ];

  static const String _KEY_SELECTED_POSITION = "position";
  static const String _KEY_SELECTED_VALUE = "value";
  int _selectedPosition = 0;
  final Function updateKeyword;
  _SearchFilter(this.updateKeyword);
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            },
          ),
          title: Text('Place preferences'),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              selected: _selectedPosition == 0,
              leading: Icon(Icons.cake),
              title: Text(filterOptions[0]),
              onTap: () {
                _saveKeywordPreference(0);
              },
              trailing: _getIcon(0),
            ),
            ListTile(
              selected: _selectedPosition == 1,
              leading: Icon(Icons.local_bar),
              title: Text(filterOptions[1]),
              onTap: () {
                _saveKeywordPreference(1);
              },
              trailing: _getIcon(1),
            ),
            ListTile(
              selected: _selectedPosition == 2,
              leading: Icon(Icons.local_cafe),
              title: Text(filterOptions[2]),
              onTap: () {
                _saveKeywordPreference(2);
              },
              trailing: _getIcon(2),
            ),
            ListTile(
              selected: _selectedPosition == 3,
              leading: Icon(Icons.local_dining),
              title: Text(filterOptions[3]),
              onTap: () {
                _saveKeywordPreference(3);
              },
              trailing: _getIcon(3),
            ),
            ListTile(
              selected: _selectedPosition == 4,
              leading: Icon(Icons.local_grocery_store),
              title: Text(filterOptions[4]),
              onTap: () {
                _saveKeywordPreference(4);
              },
              trailing: _getIcon(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIcon(int value) {
    return Builder(
      builder: (BuildContext context) {
        if (value == _selectedPosition) {
          return Icon(Icons.check);
        } else {
          return SizedBox(
            width: 50,
          );
        }
      },
    );
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPosition = prefs.getInt(_KEY_SELECTED_POSITION) ?? 0;
    });
  }

  void _saveKeywordPreference(int position) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPosition = position;
      prefs.setString(_KEY_SELECTED_VALUE, filterOptions[position]);
      prefs.setInt(_KEY_SELECTED_POSITION, position);
      updateKeyword(filterOptions[position]);
    });
  }
}