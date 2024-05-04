import 'package:flutter/material.dart'; // Mengimpor paket material untuk komponen UI Flutter.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor paket flutter_bloc untuk manajemen state.
import 'package:http/http.dart'
    as http; // Mengimpor paket http untuk membuat permintaan HTTP.
import 'dart:convert'; // Mengimpor dart:convert untuk enkoding dan dekoding JSON.

class University {
  // Kelas yang mewakili sebuah Universitas.
  String name; // Nama universitas.
  List<String> webPages; // Daftar halaman web yang terkait dengan universitas.

  University({required this.name, required this.webPages}); // Konstruktor.

  factory University.fromJson(Map<String, dynamic> json) {
    // Konstruktor fabrik untuk membuat objek University dari JSON.
    return University(
      name: json['name'], // Menetapkan nama dari JSON.
      webPages: List<String>.from(
          json['web_pages']), // Menetapkan halaman web dari JSON.
    );
  }
}

class UniversityCubit extends Cubit<List<University>> {
  // Cubit untuk mengelola daftar universitas.
  UniversityCubit() : super([]); // Menginisialisasi dengan daftar kosong.

  void fetchData(String country) async {
    // Metode untuk mengambil data dari API berdasarkan negara.
    final url =
        "http://universities.hipolabs.com/search?country=$country"; // URL untuk mengambil data berdasarkan negara.
    final response =
        await http.get(Uri.parse(url)); // Melakukan permintaan HTTP GET.
    if (response.statusCode == 200) {
      // Jika permintaan berhasil.
      List<dynamic> data =
          jsonDecode(response.body); // Mendekodekan data JSON respons.
      List<University> universities = data
          .map((json) => University.fromJson(json))
          .toList(); // Memetakan data JSON ke daftar objek University.
      emit(universities); // Mengirimkan daftar universitas.
    } else {
      // Jika permintaan tidak berhasil.
      throw Exception(
          'Gagal load data'); // Melontarkan pengecualian dengan pesan kesalahan.
    }
  }
}

void main() => runApp(const MyApp()); // Titik masuk aplikasi.

class MyApp extends StatelessWidget {
  // Widget aplikasi utama.
  const MyApp({Key? key}) : super(key: key); // Konstruktor.

  @override
  Widget build(BuildContext context) {
    // Metode build untuk membangun UI.
    return MaterialApp(
      // Widget aplikasi Material.
      home: BlocProvider(
        // Penyedia untuk UniversityCubit.
        create: (_) => UniversityCubit(), // Membuat instance UniversityCubit.
        child: const HalamanUtama(), // Widget UI utama.
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  // Widget UI utama.
  const HalamanUtama({Key? key}) : super(key: key); // Konstruktor.
  @override
  Widget build(BuildContext context) {
    // Metode build untuk membangun UI.
    return Scaffold(
      // Widget Scaffold untuk struktur layout dasar.
      appBar: AppBar(
        // Widget app bar.
        title: const Text('Daftar Universitas'), // Judul app bar.
      ),
      body: Column(
        // Widget Column untuk menyusun anak secara vertikal.
        children: [
          NegaraDropdown(), // Widget dropdown untuk memilih negara.
          Expanded(
            // Widget Expanded untuk mengisi ruang tersisa.
            child: BlocBuilder<UniversityCubit, List<University>>(
              // BlocBuilder untuk membangun UI berdasarkan status UniversityCubit.
              builder: (context, universities) {
                return ListView.builder(
                  // ListView builder untuk menampilkan daftar universitas.
                  itemCount: universities.length, // Jumlah item dalam daftar.
                  itemBuilder: (context, index) {
                    // Metode itemBuilder untuk membangun setiap item.
                    University university = universities[
                        index]; // Mendapatkan universitas pada indeks tertentu.
                    return ListTile(
                      // Widget ListTile untuk menampilkan item daftar.
                      title: Text(university.name), // Judul universitas.
                      subtitle: Column(
                        // Widget Column di dalam subtitle untuk menyusun halaman web secara vertikal.
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: university.webPages
                            .map((webPage) => Text(webPage))
                            .toList(), // Menyusun halaman web.
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NegaraDropdown extends StatefulWidget {
  // Widget dropdown negara.
  @override
  _NegaraDropdownState createState() =>
      _NegaraDropdownState(); // Metode untuk membuat state.
}

class _NegaraDropdownState extends State<NegaraDropdown> {
  // State dari widget dropdown negara.
  late String _selectedCountry; // Variabel untuk menyimpan negara yang dipilih.
  final List<String> _countries = [
    // Daftar negara yang tersedia.
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
  ];

  @override
  void initState() {
    // Metode initState untuk inisialisasi.
    super.initState();
    _selectedCountry = _countries
        .first; // Mengatur negara yang dipilih menjadi negara pertama dalam daftar.
    context.read<UniversityCubit>().fetchData(
        _selectedCountry); // Mengambil data universitas untuk negara pertama.
  }

  @override
  Widget build(BuildContext context) {
    // Metode build untuk membangun UI.
    return DropdownButton<String>(
      // Widget DropdownButton untuk memilih negara.
      value: _selectedCountry, // Nilai negara yang dipilih.
      onChanged: (String? newValue) {
        // Metode onChanged untuk menangani perubahan nilai dropdown.
        if (newValue != null) {
          // Memastikan nilai baru tidak null.
          setState(() {
            _selectedCountry =
                newValue; // Mengatur negara yang dipilih menjadi nilai baru.
          });
          context.read<UniversityCubit>().fetchData(
              newValue); // Mengambil data universitas untuk negara baru.
        }
      },
      items: _countries.map<DropdownMenuItem<String>>((String value) {
        // Item dropdown untuk setiap negara.
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value), // Menampilkan nama negara.
        );
      }).toList(),
    );
  }
}
