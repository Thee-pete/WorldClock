import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class Location {
  final String city;
  final String timezone;

  Location(this.city, this.timezone);
}

class _MyAppState extends State<MyApp> {
  List<Location> locations = [];
  Location? selectedLocation;
  String time = '';

  Future<void> getLocations() async {
    var url = Uri.parse('http://worldtimeapi.org/api/timezone');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<Location> tempList = [];
      for (var location in data) {
        String timezone = location.toString();
        String city = timezone.substring(timezone.lastIndexOf('/') + 1);
        tempList.add(Location(city, timezone));
      }
      setState(() {
        locations = tempList;
        selectedLocation = tempList[0];
      });
      updateTime(selectedLocation!.timezone);
    }
  }

  Future<void> updateTime(String timezone) async {
    var url = Uri.parse('http://worldtimeapi.org/api/timezone/$timezone');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String fullDatetime = data['datetime'];
      // DateTime datetime = DateTime.parse(fullDatetime);
      // String formattedTime = '${datetime.hour}:${datetime.minute}:${datetime.second}';
      setState(() {
        time = fullDatetime;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLocations();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('World Clock'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Selected Location: ${selectedLocation?.city ?? ""}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Time: $time',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              DropdownButton<Location>(
                value: selectedLocation,
                onChanged: (newValue) {
                  setState(() {
                    selectedLocation = newValue;
                    updateTime(selectedLocation!.timezone);
                  });
                },
                items: locations.map<DropdownMenuItem<Location>>((Location value) {
                  return DropdownMenuItem<Location>(
                    value: value,
                    child: Text(value.city),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
