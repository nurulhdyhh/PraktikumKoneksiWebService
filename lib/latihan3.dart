import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class University {
  String name;
  List<String> webPages;

  University({required this.name, required this.webPages});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      webPages: List<String>.from(json['web_pages']),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  late Future<List<University>> futureUniversities;

  String url = "http://universities.hipolabs.com/search?country=Indonesia";

  Future<List<University>> fetchData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<University> universities =
          data.map((json) => University.fromJson(json)).toList();
      return universities;
    } else {
      throw Exception('Gagal load data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureUniversities = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Universitas'),
        ),
        body: Center(
          child: FutureBuilder<List<University>>(
            future: futureUniversities,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    University university = snapshot.data![index];
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(university.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: university.webPages
                                .map((webPage) => Text(webPage))
                                .toList(),
                          ),
                        ),
                        Divider(), // Tambahkan Divider di sini
                      ],
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
