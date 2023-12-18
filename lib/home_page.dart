import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String abbr = 'c';
  List<String> abbrs = List<String>.filled(5, '');
  List<String> dates = List<String>.filled(5, '');
  Position? position;
  String sehir = 'Ankara';
  int sicaklik = 0;
  List<int> temps = List<int>.filled(5, 0);

  var woeid;

  @override
  void initState() {
    super.initState();
    getDataFromAPI();
  }

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Hata"),
            content: const Text("Konum bilgisi alınamadı."),
            actions: [
              TextButton(
                child: const Text("Tamam"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getLocationTemperature() async {
    final response = await http.get(
      Uri.parse(
        'https://www.metaweather.com/api/location/$woeid/',
      ),
    );
    final temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      sicaklik =
          temperatureDataParsed['consolidated_weather'][0]['the_temp'].round();
      abbr = temperatureDataParsed['consolidated_weather'][0]
          ['weather_state_abbr'];
      for (int i = 0; i < temps.length; i++) {
        temps[i] = temperatureDataParsed['consolidated_weather'][i + 1]
                ['the_temp']
            .round();
        abbrs[i] = temperatureDataParsed['consolidated_weather'][i + 1]
            ['weather_state_abbr'];
        dates[i] = temperatureDataParsed['consolidated_weather'][i + 1]
            ['applicable_date'];
      }
    });
  }

  Future<void> getLocationData() async {
    final locationData = await http.get(Uri.parse(
        'https://www.metaweather.com/api/location/search/?query=$sehir'));
    final locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
  }

  Future<void> getLocationDataLatLong() async {
    final locationData = await http.get(
      Uri.parse(
        'https://www.metaweather.com/api/location/search/?lattlong=${position?.latitude},${position?.longitude}',
      ),
    );
    final locationDataParsed = jsonDecode(
      utf8.decode(locationData.bodyBytes),
    );
    woeid = locationDataParsed[0]['woeid'];
    sehir = locationDataParsed[0]['title'];
  }

  Future<void> getDataFromAPI() async {
    await getDevicePosition();
    await getLocationDataLatLong();
    await getLocationTemperature();
  }

  SizedBox buildDailyWeatherCards(BuildContext context) {
    List<Widget> cards = List<Widget>.generate(5, (index) {
      return DailyWeather(
        image: abbrs[index],
        temp: temps[index].toString(),
        date: dates[index],
      );
    });

    return SizedBox(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/$abbr.jpg'),
        ),
      ),
      child: sicaklik == 0
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          'https://www.metaweather.com/static/img/weather/png/$abbr.png'),
                    ),
                    Text(
                      '$sicaklik° C',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 70,
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 5,
                            offset: Offset(-3, 3),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          sehir,
                          style: const TextStyle(
                            fontSize: 30,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 5,
                                offset: Offset(-3, 3),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            sehir = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchPage(),
                              ),
                            );
                            setState(() {
                              sehir = sehir;
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 120,
                    ),
                    buildDailyWeatherCards(context),
                  ],
                ),
              ),
            ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şehir Arama'),
      ),
      body: const Center(),
    );
  }
}

class DailyWeather extends StatelessWidget {
  const DailyWeather({
    super.key,
    required this.image,
    required this.temp,
    required this.date,
  });

  final String date;
  final String image;
  final String temp;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Image.network(
            'https://www.metaweather.com/static/img/weather/png/$image.png',
            width: 40,
            height: 40,
          ),
          Text(
            '$temp°C',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
