import 'package:flutter/material.dart'; // Mengimpor library Flutter untuk pengembangan UI
import 'package:http/http.dart'
    as http; // Mengimpor library http untuk melakukan HTTP request
import 'dart:convert'; // Mengimpor library untuk melakukan encoding dan decoding JSON
import 'package:provider/provider.dart'; // Mengimpor library provider untuk manajemen state

void main() {
  runApp(
    MultiProvider(
      // MultiProvider memungkinkan untuk menggabungkan beberapa provider menjadi satu widget tunggal
      providers: [
        ChangeNotifierProvider<UniversityModel>(
          // Menyediakan UniversityModel kepada class turunannya
          create: (context) =>
              UniversityModel(), // Membuat sebuah instance dari UniversityModel saat diperlukan
        ),
      ],
      child: const MyApp(), // Widget utama dari aplikasi
    ),
  );
}

class University {
  // Mendefinisikan kelas University untuk merepresentasikan universitas
  String name; // Nama universitas
  List<String> webPages; // Daftar halaman web universitas

  University(
      {required this.name, required this.webPages}); // Konstruktor University

  factory University.fromJson(Map<String, dynamic> json) {
    // Metode factory untuk membuat objek University dari JSON
    return University(
      name: json['name'], // Nama universitas
      webPages: List<String>.from(json[
          'web_pages']), // Daftar halaman web yang terkait dengan universitas
    );
  }
}

class UniversityModel extends ChangeNotifier {
  // Kelas model yang menyimpan state daftar universitas dan negara yang dipilih
  List<University> universities = []; // Daftar universitas
  String selectedCountry = "Indonesia"; // Negara yang dipilih secara default

  void fetchUniversities(String country) async {
    // Mengambil data universitas berdasarkan negara yang dipilih
    final url =
        "http://universities.hipolabs.com/search?country=$country"; // Endpoint API
    final response = await http.get(Uri.parse(url)); // Permintaan HTTP GET
    if (response.statusCode == 200) {
      // Jika permintaan berhasil
      List<dynamic> data = jsonDecode(response.body); // Mendecode respon JSON
      universities = data
          .map((json) => University.fromJson(json))
          .toList(); // Memetakan data JSON ke objek University
      notifyListeners(); // Memberitahu pendengar (UI) bahwa status telah berubah
    } else {
      throw Exception(
          'Gagal memuat data'); // Melemparkan pengecualian jika pengambilan data gagal
    }
  }

  void setSelectedCountry(String country) {
    // Mengatur negara yang dipilih dan mengambil data universitas untuk negara tersebut
    selectedCountry = country;
    fetchUniversities(selectedCountry);
  }
}

class MyApp extends StatelessWidget {
  // Widget utama aplikasi
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Membangun tampilan aplikasi
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Universitas'), // Judul aplikasi
        ),
        body: Column(
          children: [
            CountryDropdown(), // Widget dropdown untuk memilih negara
            UniversityList(), // Daftar universitas
          ],
        ),
      ),
    );
  }
}

class CountryDropdown extends StatelessWidget {
  // Widget dropdown untuk memilih negara
  @override
  Widget build(BuildContext context) {
    final universityModel = Provider.of<UniversityModel>(
        context); // Mendapatkan instance UniversityModel dari Provider
    return DropdownButton<String>(
      value:
          universityModel.selectedCountry, // Nilai yang dipilih dalam dropdown
      onChanged: (String? newValue) {
        // Ketika nilai dropdown berubah
        if (newValue != null) {
          universityModel
              .setSelectedCountry(newValue); // Mengatur negara yang dipilih
        }
      },
      items: <String>[
        'Indonesia',
        'Malaysia',
        'Singapura',
        'Thailand',
        'Filipina',
        'Laos',
        'Vietnam',
        'Brunei',
        'Myanmar',
        'Kamboja'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value), // Teks opsi dalam dropdown
        );
      }).toList(),
    );
  }
}

class UniversityList extends StatelessWidget {
  // Daftar universitas
  @override
  Widget build(BuildContext context) {
    final universityModel = Provider.of<UniversityModel>(
        context); // Mendapatkan instance UniversityModel dari Provider
    return Expanded(
      child: ListView.builder(
        itemCount:
            universityModel.universities.length, // Jumlah item dalam daftar
        itemBuilder: (context, index) {
          University university = universityModel
              .universities[index]; // Universitas pada indeks tertentu
          return ListTile(
            title: Text(university.name), // Judul universitas
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: university.webPages
                  .map((webPage) => Text(webPage))
                  .toList(), // Daftar halaman web universitas
            ),
          );
        },
      ),
    );
  }
}
