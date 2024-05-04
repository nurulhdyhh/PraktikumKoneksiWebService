import 'dart:convert'; // Mengimpor pustaka 'dart:convert' untuk mengonversi data JSON.
import 'package:flutter/material.dart'; // Mengimpor pustaka 'flutter/material' untuk mengakses komponen UI Flutter.
import 'package:http/http.dart'
    as http; // Mengimpor pustaka 'http' dari package 'http' dengan alias 'http'.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor pustaka 'flutter_bloc' untuk menggunakan Flutter Bloc.

void main() {
  runApp(MyApp()); // Memulai aplikasi Flutter dengan menjalankan MyApp().
}

class University {
  final String name; // Variabel untuk menyimpan nama universitas.
  final List<String>
      website; // Variabel untuk menyimpan daftar situs web universitas.

  University(
      {required this.name,
      required this.website}); // Konstruktor untuk kelas University.

  factory University.fromJson(Map<String, dynamic> json) {
    // Metode factory untuk membuat objek University dari JSON.
    return University(
      name: json['name'], // Mendapatkan nama universitas dari JSON.
      website: List<String>.from(json[
          'web_pages']), // Mendapatkan daftar situs web universitas dari JSON.
    );
  }
}

abstract class DataEvent {} // Kelas abstrak untuk event data.

class SelectCountryEvent extends DataEvent {
  // Kelas untuk event pemilihan negara.
  final String country; // Variabel untuk menyimpan negara yang dipilih.
  SelectCountryEvent(this.country); // Konstruktor untuk event pemilihan negara.
}

class FetchUniversitiesEvent extends DataEvent {
  // Kelas untuk event pengambilan data universitas.
  final String country; // Variabel untuk menyimpan negara yang dipilih.
  FetchUniversitiesEvent(
      this.country); // Konstruktor untuk event pengambilan data universitas.
}

class UniversityState {
  // Kelas untuk menyimpan status aplikasi terkait universitas.
  final List<University>
      universities; // Variabel untuk menyimpan daftar universitas.
  final bool isLoading; // Variabel untuk menunjukkan status pemuatan.
  final String error; // Variabel untuk menyimpan pesan kesalahan.
  final String selectedCountry; // Variabel untuk menyimpan negara yang dipilih.

  UniversityState({
    this.universities = const [], // Menginisialisasi daftar universitas kosong.
    this.isLoading = false, // Menginisialisasi status pemuatan menjadi false.
    this.error = '', // Menginisialisasi pesan kesalahan menjadi string kosong.
    this.selectedCountry =
        'Indonesia', // Menginisialisasi negara yang dipilih menjadi Indonesia.
  });

  UniversityState copyWith({
    List<University>?
        universities, // Parameter opsional untuk menyimpan daftar universitas.
    bool? isLoading, // Parameter opsional untuk menyimpan status pemuatan.
    String? error, // Parameter opsional untuk menyimpan pesan kesalahan.
    String?
        selectedCountry, // Parameter opsional untuk menyimpan negara yang dipilih.
  }) {
    return UniversityState(
      universities: universities ??
          this.universities, // Menyimpan daftar universitas baru atau tetap menggunakan yang lama.
      isLoading: isLoading ??
          this.isLoading, // Menyimpan status pemuatan baru atau tetap menggunakan yang lama.
      error: error ??
          this.error, // Menyimpan pesan kesalahan baru atau tetap menggunakan yang lama.
      selectedCountry: selectedCountry ??
          this.selectedCountry, // Menyimpan negara yang dipilih baru atau tetap menggunakan yang lama.
    );
  }
}

class UniversityBloc extends Bloc<DataEvent, UniversityState> {
  // Kelas untuk mengelola logika aplikasi terkait universitas.
  UniversityBloc() : super(UniversityState()) {
    // Konstruktor untuk UniversityBloc, menginisialisasi state awal.
    on<SelectCountryEvent>((event, emit) {
      // Event handler untuk memilih negara.
      emit(state.copyWith(
          selectedCountry: event.country)); // Memperbarui negara yang dipilih.
      add(FetchUniversitiesEvent(
          event.country)); // Memicu event untuk mengambil data universitas.
    });

    on<FetchUniversitiesEvent>((event, emit) async {
      // Event handler untuk mengambil data universitas.
      emit(state.copyWith(
          isLoading: true)); // Memperbarui status pemuatan menjadi true.
      try {
        final response = await http.get(Uri.parse(
            'http://universities.hipolabs.com/search?country=${event.country}')); // Mengirim permintaan HTTP untuk mengambil data universitas berdasarkan negara.
        if (response.statusCode == 200) {
          List jsonResponse =
              json.decode(response.body); // Mendekode data JSON yang diterima.
          List<University> universities = jsonResponse
              .map((univ) => University.fromJson(univ))
              .toList(); // Mengonversi data JSON menjadi objek University.
          emit(state.copyWith(
            universities: universities, // Memperbarui daftar universitas.
            isLoading: false, // Memperbarui status pemuatan menjadi false.
            error: '', // Menghapus pesan kesalahan.
          ));
        } else {
          emit(state.copyWith(
            error:
                'Failed to load universities', // Menampilkan pesan kesalahan.
            isLoading: false, // Memperbarui status pemuatan menjadi false.
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          error: 'Failed to load universities', // Menampilkan pesan kesalahan.
          isLoading: false, // Memperbarui status pemuatan menjadi false.
        ));
      }
    });
  }
}

class MyApp extends StatelessWidget {
  // Kelas untuk membangun aplikasi Flutter.
  @override
  Widget build(BuildContext context) {
    // Metode untuk membangun antarmuka aplikasi.
    return BlocProvider(
      create: (_) =>
          UniversityBloc(), // Membungkus aplikasi dengan UniversityBloc.
      child: MaterialApp(
        title: 'Universitas di ASEAN', // Menetapkan judul aplikasi.
        theme: ThemeData(
          primarySwatch: Colors.blue, // Menetapkan tema warna utama.
        ),
        home: UniversityList(), // Menetapkan halaman utama aplikasi.
      ),
    );
  }
}

class UniversityList extends StatelessWidget {
  // Kelas untuk menampilkan daftar universitas.
  final List<String> countries = [
    // Variabel untuk menyimpan daftar negara-negara.
    'Indonesia',
    'Singapore',
    'Malaysia',
    'Thailand',
    'Philippines',
    'Vietnam',
    'Brunei',
    'Myanmar',
    'Laos',
    'Kamboja'
  ];

  @override
  Widget build(BuildContext context) {
    // Metode untuk membangun antarmuka daftar universitas.
    return Scaffold(
      // Menggunakan scaffold sebagai kerangka utama aplikasi.
      appBar: AppBar(
        title: Text('Universitas di ASEAN'), // Menetapkan judul appbar.
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              // Membuat dropdown untuk memilih negara.
              value: context
                  .watch<UniversityBloc>()
                  .state
                  .selectedCountry, // Menetapkan nilai dropdown berdasarkan negara yang dipilih.
              onChanged: (newCountry) {
                // Mengubah negara yang dipilih saat dropdown berubah.
                context.read<UniversityBloc>().add(SelectCountryEvent(
                    newCountry!)); // Memicu event pemilihan negara.
              },
              items: countries.map((String country) {
                // Membuat item dropdown untuk setiap negara.
                return DropdownMenuItem<String>(
                  value: country, // Menetapkan nilai item dropdown.
                  child: Text(country), // Menampilkan teks negara.
                );
              }).toList(),
            ),
          ),
          Expanded(
            // Widget Expanded untuk membuat daftar dapat digulir.
            child: BlocBuilder<UniversityBloc, UniversityState>(
              // Membuat builder untuk merender UI berdasarkan status aplikasi.
              builder: (context, state) {
                // Metode builder untuk merender UI berdasarkan status aplikasi.
                if (state.isLoading) {
                  // Jika sedang memuat, tampilkan indikator loading.
                  return Center(child: CircularProgressIndicator());
                } else if (state.error.isNotEmpty) {
                  // Jika ada kesalahan, tampilkan pesan kesalahan.
                  return Center(child: Text('Error: ${state.error}'));
                } else {
                  // Jika tidak ada kesalahan atau sedang memuat, tampilkan daftar universitas.
                  return ListView.builder(
                    // Membuat daftar universitas dengan ListView.builder.
                    padding: EdgeInsets.all(4.0), // Mengatur jarak antara Card.
                    itemCount: state.universities
                        .length, // Menetapkan jumlah item dalam daftar.
                    itemBuilder: (context, index) {
                      // Membangun setiap item dalam daftar.
                      University university = state.universities[
                          index]; // Mendapatkan universitas pada indeks tertentu.
                      return Card(
                        // Membuat kartu untuk menampilkan informasi universitas.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              15.0), // Mengatur border radius kartu.
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical:
                                4.0), // Mengatur jarak vertikal antara kartu.
                        child: ListTile(
                          // Membuat ListTile untuk menampilkan informasi universitas.
                          leading: const CircleAvatar(
                            // Menggunakan leading untuk menampilkan ikon universitas.
                            child: Icon(Icons
                                .business), // Menampilkan ikon bisnis sebagai pengganti ikon universitas.
                          ),
                          title: Text(university.name,
                              style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold)), // Menampilkan nama universitas.
                          subtitle: Text(
                              'Website: ${university.website.join(', ')}'), // Menampilkan situs web universitas.
                          trailing: IconButton(
                            // Menggunakan trailing untuk menampilkan ikon 'open_in_new'.
                            icon: Icon(Icons.open_in_new, color: Colors.blue),
                            onPressed: () {
                              // Implementasi membuka website universitas.
                              // dengan menggunakan URL di university.website[0]
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
