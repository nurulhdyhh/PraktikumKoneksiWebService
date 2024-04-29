import 'dart:convert';

void main(List<String> arguments) {
  String jsonTranskrip = '''
  {
    "nama": "Nurul Hidayatul Hasanah",
    "nim": "22082010013",
    "transkrip": [
      {
        "mata_kuliah": "Pemograman Mobile",
        "nilai": 3.75,
        "sks": 3
      },
      {
        "mata_kuliah": "Pemrograman Desktop",
        "nilai": 4,
        "sks": 4
      },
      {
        "mata_kuliah": "Pemograman Mobile",
        "nilai": 4,
        "sks": 3
      }
    ]
  }
  ''';

  Map<String, dynamic> transkripMahasiswa = jsonDecode(jsonTranskrip);
  List<dynamic> transkrip = transkripMahasiswa['transkrip'];

  num totalSKS = 0; // Mengubah tipe variabel totalSKS menjadi 'num'
  num totalNilai = 0;

  for (var mataKuliah in transkrip) {
    totalSKS += mataKuliah['sks'];
    totalNilai += mataKuliah['nilai'] * mataKuliah['sks'];
  }

  // Menghitung IPK dan membulatkannya jika memiliki dua digit desimal atau lebih
  double ipk = totalNilai / totalSKS;
  String formattedIPK =
      (ipk % 1 == 0) ? ipk.toStringAsFixed(0) : ipk.toStringAsFixed(2);

  // Menampilkan informasi IPK, jumlah SKS, nama, dan NIM
  print('Nama: ${transkripMahasiswa['nama']}');
  print('NPM: ${transkripMahasiswa['nim']}');
  print('Jumlah SKS: $totalSKS');
  print('IPK: $formattedIPK');
}
