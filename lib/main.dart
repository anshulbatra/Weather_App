import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/services.dart';

import 'package:klimatic/weather.dart';
import 'package:klimatic/weatherItem.dart';
import 'package:klimatic/weatherData.dart';
import 'package:klimatic/forecastData.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  bool isLoading = false;
  WeatherData weatherData;
  ForecastData forecastData;
  Location _location = new Location();
  String error;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather_Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: Text('Weather Forecast'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: weatherData != null ? Weather(weather: weatherData) : Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: isLoading ? CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: new AlwaysStoppedAnimation(Colors.white),
                      ) : IconButton(
                        icon: new Icon(Icons.refresh),
                        tooltip: 'Refresh',
                        onPressed: loadWeather,
                        color: Colors.white,
                      ),
                    ),
                  ]
                )
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200.0,
                    child: forecastData != null ? ListView.builder(
                      itemCount: forecastData.list.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => WeatherItem(weather : forecastData.list.elementAt(index))
                    ) : Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  loadWeather() async {
    setState(() {
      isLoading = true;
    });

    Map<String, double> location;

    try {
      location = await _location.getLocation(); //Second Commit - Error Removed

      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    if (location != null) {
      final lat = location['latitude'];
      final lon = location['longitude'];

    final weatherResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/weather?APPID=57e249a71ee263cf84e08bd3fa2c2c7c&lat=${lat.toString()}&lon=${lon.toString()}');
    final forecastResponse = await http.get(
        'https://api.openweathermap.org/data/2.5/forecast?APPID=57e249a71ee263cf84e08bd3fa2c2c7c&lat=${lat.toString()}&lon=${lon.toString()}');

    if (weatherResponse.statusCode == 200 &&
        forecastResponse.statusCode == 200) {
      return setState(() {
        weatherData = new WeatherData.fromJson(jsonDecode(weatherResponse.body));
        forecastData = new ForecastData.fromJson(jsonDecode(forecastResponse.body));
        isLoading = false;
      });
    }
    }

    setState(() {
      isLoading = false;
    });
  }
}

