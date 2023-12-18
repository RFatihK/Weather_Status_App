import 'dart:convert';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final myController = TextEditingController();
  late String secilenSehir;

  get http => null;

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("HATA"),
          content: const Text("Geçersiz Bir Şehir Girdiniz"),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Kapat"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover, image: AssetImage('assets/search.jpg')),
      ),
      child: Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                    controller: myController,
                    decoration: const InputDecoration(
                      hintText: 'Şehir Seçiniz',
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(fontSize: 30),
                    textAlign: TextAlign.center),
              ),
              ElevatedButton(
                onPressed: () async {
                  var response = await http.get(
                      'https://www.metaweather.com/api/location/search/?query=${myController.text}');
                  jsonDecode(response.body).isEmpty
                      ? _showDialog()
                      // ignore: use_build_context_synchronously
                      : Navigator.pop(context, myController.text);
                },
                child: const Text('Şehri Seç'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
