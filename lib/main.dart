import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = 'b4041c85ef83564c943be469ebba368e'; 
  late String city;
  late WeatherData weatherData;
  late bool isLoading = false;

  @override
  void initState() {
    super.initState();
    city = 'Brahmapur';
    fetchData();
  }
  
  Future<void> fetchData() async {
  setState(() {
    isLoading = true;
  });

  try {
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        weatherData = WeatherData.fromJson(data);
      });
    } else if (response.statusCode == 404) {
      setState(() {
        weatherData = WeatherData.cityNotFound();
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  city = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search City',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : fetchData,
              child: Text('Get Weather'),
            ),

            SizedBox(height: 20),
            weatherData != null
              ? weatherData.cityNotFound
                ? Text('City not found. Please enter a valid city name.')
                : Column(
                    children: [
                      Text('City: ${weatherData.name}'),
                      Text('Temperature: ${weatherData.main.temp.toStringAsFixed(2)}°C'),
                      Text('Description: ${weatherData.weather[0].description.capitalize()}'),
                      Text('Humidity: ${weatherData.main.humidity}%'),
                    ],
                  )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class WeatherData {
  final String name;
  final Main main;
  final List<Weather> weather;
  final bool cityNotFound;

  WeatherData({
    required this.name,
    required this.main,
    required this.weather,
    this.cityNotFound = false,
  });

  WeatherData.cityNotFound()
      : name = '',
        main = Main(temp: 0, humidity: 0),
        weather = [],
        cityNotFound = true;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    if (json['cod'] == '404') {
      return WeatherData.cityNotFound();
    }

    return WeatherData(
      name: json['name'],
      main: Main.fromJson(json['main']),
      weather: (json['weather'] as List<dynamic>).map((item) => Weather.fromJson(item)).toList(),
    );
  }
}

class Main {
  final double temp;
  final int humidity;

  Main({
    required this.temp,
    required this.humidity,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: json['temp'],
      humidity: json['humidity'],
    );
  }
}

class Weather {
  final String description;

  Weather({
    required this.description,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['description'],
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    }
}