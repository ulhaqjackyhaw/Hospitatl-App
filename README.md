# Hospitatl-App
📦 IoT Hospital Assistance System with ESP32, Firebase, and Flutter Proyek ini merupakan hasil praktikum yang bertujuan untuk membangun sistem IoT di lingkungan rumah sakit, dengan fokus pada interaksi antara pasien dan perawat melalui sistem bantuan otomatis.
🎯 Tujuan Project
Membuat struktur database di Firebase untuk menyimpan data permintaan bantuan dari pasien.

Mengimplementasikan ESP32 untuk mengirim dan menerima data ke/dari Firebase.

Mengembangkan aplikasi Flutter untuk mengontrol sistem bantuan IoT yang digunakan oleh pasien dan perawat.

🛠️ Metodologi
Sistem ini dibangun menggunakan dua komponen utama:

Perangkat Keras (ESP32):

ESP32 digunakan untuk menghubungkan perangkat IoT (misalnya tombol bantuan) dengan internet melalui Firebase.

Perangkat akan mengirim data ketika pasien menekan tombol bantuan, dan dapat menerima respon dari aplikasi perawat.

Aplikasi Flutter:

Dibuat untuk perawat dan pasien agar bisa berkomunikasi secara efisien melalui Firebase.

Aplikasi ini menampilkan status permintaan bantuan secara real-time dan menyediakan kontrol untuk meresponnya.

Firebase Realtime Database:

Menyimpan informasi mengenai status bantuan dari pasien.

Struktur database dirancang agar setiap pasien memiliki data permintaan bantuan yang dapat diakses dan dimodifikasi oleh ESP32 maupun aplikasi Flutter.
