Map<String, dynamic> ujianAkhir(String namaMateri) {
  return {
    'nama': 'Latihan Soal $namaMateri',
    'isiMateri': '''
# Aturan

Kuis ini bertujuan untuk menguji pengetahuan Anda tentang materi Termodinamika: $namaMateri

Terdapat 10 pertanyaan yang harus dikerjakan dalam soal latihan ini. Beberapa ketentuannya sebagai berikut:
- Syarat kelulusan : minimal harus menjawab 8 soal dengan benar
- Durasi ujian : 3-7 menit / soal

Apabila tidak memenuhi syarat kelulusan, maka Anda harus menunggu selama 15 menit untuk mengulang pengerjaan latihan soal kembali. Manfaatkan waktu tunggu tersebut untuk mempelajari kembali materi sebelumnya, ya.

Selamat Mengerjakan!
''',
    'isDone': false,
  };
}

List<Map<String, dynamic>> dataMateri = [
  {
    'namaMateri': 'Gas Ideal',
    'subMateri': [
      {
        'nama': 'Berkenalan dengan Gas Ideal',
        'isiMateri': '''
Termodinamika merupakan cabang fisika yang mempelajari hubungan antara panas, kerja, dan energi. Dalam kehidupan sehari-hari, konsep termodinamika dapat ditemukan pada berbagai peristiwa, seperti mesin mobil yang mengubah energi panas menjadi gerak, atau lemari es yang memindahkan panas dari ruang dingin ke lingkungan.

Untuk memahami proses-proses ini, kita perlu mengenal konsep gas ideal dan hukum-hukum termodinamika yang menjadi dasar perhitungannya.

**Gas Ideal** 

   Gas ideal merupakan konsep dasar dalam termodinamika yang menggambarkan perilaku gas secara teoretis. Dalam pandangan mikroskopik, gas ideal didefinisikan sebagai gas yang terdiri atas partikel-partikel kecil yang disebut molekul (Hartini, 2015). Molekul-molekul ini bergerak secara acak atau serampangan dan selalu mengikuti hukum-hukum gerak Newton.

   Jumlah molekul dalam suatu gas ideal sangat besar, namun volume setiap molekul sangat kecil sehingga dapat diabaikan dibandingkan dengan volume total gas. Selain itu, tidak ada gaya tarik-menarik yang signifikan antar molekul kecuali ketika terjadi tumbukan. Tumbukan yang terjadi antara molekul bersifat elastis sempurna, artinya tidak ada energi kinetik yang hilang selama tumbukan tersebut. Tumbukan juga terjadi dalam waktu yang sangat singkat.

   Perilaku gas ideal dalam berbagai kondisi dinyatakan dalam hukum-hukum gas (Radjawane, 2022) yang menjelaskan hubungan antara tekanan (P), volume (V), jumlah mol (n), dan suhu (T). Hukum-hukum tersebut antara lain:

1. Hukum Boyle

   Hukum Boyle menyatakan bahwa hasil kali antara tekanan dan volume gas merupakan konstanta apabila suhu dan jumlah mol gas tetap.

   Secara matematis dapat dituliskan sebagai:

   PV=konstan

   pada suhu dan jumlah mol tetap.

   Artinya, jika volume gas mengecil maka tekanannya akan meningkat, dan sebaliknya.

1. Hukum Charles

   Hukum Charles menemukan bahwa pada tekanan dan jumlah mol konstan, volume gas berbanding lurus dengan suhu mutlaknya (T).

   Secara matematis dinyatakan sebagai:

   VT=konstan

   Artinya, semakin tinggi suhu suatu gas, maka volumenya juga akan meningkat apabila tekanannya dijaga tetap.

1. Hukum Gay-Lussac

   Menurut hukum Gay-Lussac, pada volume tetap, tekanan gas akan meningkat seiring dengan meningkatnya suhu.

   Secara matematis dapat dituliskan sebagai:

   PT=konstan

   Dengan kata lain, tekanan gas berbanding lurus dengan suhu mutlaknya ketika volume tidak berubah.

1. Hukum Avogadro

   Hukum Avogadro menyatakan bahwa pada suhu dan tekanan yang sama, gas-gas dengan volume yang sama akan memiliki jumlah molekul yang sama.

   Secara matematis, hubungan ini ditulis sebagai:

   Vn=konstan

   Artinya, jika jumlah mol gas bertambah, maka volumenya juga bertambah dengan tekanan dan suhu yang tetap.

1. Persamaan Keadaan Gas Ideal

   Dari keempat hukum di atas, maka dapat dirangkum dalam satu hubungan umum yang disebut persamaan keadaan gas ideal (Hartini, 2015):

   PV=nRT

   dengan:

- P= Tekanan gas (Pa)
- V= Volume gas (m³)
- n= Jumlah mol gas
- R= Tetapan gas umum (8,31 J/mol·K)
- T= Suhu mutlak (K)

Persamaan ini menggambarkan keterkaitan antara besaran-besaran utama dalam sistem gas ideal, yang menjadi dasar dalam berbagai analisis termodinamika.
''',
        'isDone': false,
      }, 
      {
        'nama': 'Hukum I Termodinamika',
        'isiMateri': '''
Hukum pertama termodinamika merupakan dasar utama dalam memahami hubungan antara panas, kerja, dan energi. Hukum ini pada dasarnya adalah penerapan dari hukum kekekalan energi, yang menyatakan bahwa energi tidak dapat diciptakan maupun dimusnahkan, tetapi hanya dapat diubah dari satu bentuk ke bentuk lainnya (Tipler, 1998).

   Dalam konteks sistem termodinamika, hukum ini menjelaskan bahwa panas (Q) yang diberikan kepada suatu sistem akan digunakan untuk menaikkan energi dalam sistem (ΔU) dan melakukan kerja (W) oleh sistem tersebut terhadap lingkungannya. Secara matematis, hukum ini dapat dinyatakan sebagai:

   Q=ΔU+W

   atau ditulis dalam bentuk lain:

   Q+(-W)=ΔU

   Keterangan:

- Q= Kalor atau panas yang diterima sistem
- ΔU= Perubahan energi dalam sistem
- W= Kerja yang dilakukan oleh sistem

Persamaan ini menunjukkan bahwa jumlah energi panas yang masuk ke dalam sistem akan terbagi menjadi dua bagian: sebagian menjadi energi dalam (meningkatkan suhu atau energi mikroskopik partikel), dan sebagian lagi menjadi kerja yang dilakukan oleh sistem, misalnya dalam bentuk pemuaian gas.
''',
        'isDone': false,
      },
      {
        'nama': 'Proses-Proses dalam Termodinamika',
        'isiMateri': '''
Hukum pertama termodinamika dapat diterapkan dalam berbagai proses yang terjadi pada gas ideal, yaitu proses isobarik, isotermal, isokhorik, dan adiabatik. Masing-masing proses memiliki kondisi dan karakteristik tersendiri, seperti berikut ini:

- Proses Isobarik (Tekanan Tetap)

  Proses isobarik adalah proses yang berlangsung pada tekanan konstan (Radjawane, 2022). Ketika tekanan (P) tetap dan suhu gas berubah, maka volume gas juga akan berubah secara proporsional (Giancoli, 2001).

  Persamaan keadaan gas pada proses isobarik dapat dinyatakan sebagai (Palupi, 2009):

  PVT=konstan

  Dengan kondisi:

  P1=P2 dan V1≠V2

  Atau

  VT=V1T1=V2T2

  Keterangan:

- P= Tekanan
- V= Volume
- T= Suhu
- V1,V2= Volume pada keadaan awal dan akhir
- T1,T2= Suhu pada keadaan awal dan akhir

Pada diagram PV, proses isobarik digambarkan sebagai garis horizontal, karena tekanan tetap sementara volume berubah. Luasan di bawah kurva PV menunjukkan kerja (W) yang dilakukan oleh sistem.

![](Aspose.Words.f522656b-4090-4b3b-bcc1-ff7222952d16.001.png)

**Gambar 1.1** Diagram PV pada proses isobarik, di mana W adalah luasan yang diarsir

*(Sumber: Palupi, 2009)*

- Proses Isotermal (Suhu Tetap)

  Proses isotermal adalah proses perubahan keadaan gas di mana suhu sistem tetap. Karena suhu tidak berubah, maka energi dalam sistem (ΔU) = 0, sehingga seluruh kalor yang diterima sistem digunakan untuk melakukan kerja terhadap lingkungannya (Giancoli, 2001).

  Persamaan keadaan pada proses isotermal adalah:

  PV=konstanatauP1V1=P2V2

  Kerja yang dilakukan oleh gas dalam proses isotermal dapat dihitung dengan:

  W=Q=nRTln⁡V2V1

  Keterangan:

- Q= Kalor panas
- n= Jumlah mol gas
- R= Tetapan gas umum (8,31 J/mol·K)
- T= Suhu
- V1,V2= Volume awal dan akhir

Karena suhu tetap, hukum pertama termodinamika menjadi:

Q=nRTln⁡V2V1

![ref1]

**Gambar 1.2** Diagram PV pada proses isotermal, di mana W adalah luasan yang diarsir

*(Sumber: Palupi, 2009)*

- Proses Isokhorik (Volume Tetap)

  Proses isokhorik adalah proses yang berlangsung pada volume konstan, sehingga gas tidak melakukan kerja (W = 0). Pada proses ini, seluruh kalor yang masuk ke sistem digunakan untuk mengubah energi dalam sistem (ΔU) (Giancoli, 2001).

  Persamaan keadaan untuk proses isokhorik:

  V1=V2 dan P1≠P2

  Atau

  PT=konstan,P1T1=P2T2

  Karena tidak ada perubahan volume, kerja = 0 dan Q = ΔU.

  ![ref2]

  **Gambar 1.3** Diagram PV pada proses isokhorik, di mana W=0

  *(Sumber: Palupi, 2009)*

- Proses Adiabatik (Tanpa Pertukaran Kalor)

  Proses adiabatik adalah proses perubahan keadaan gas di mana tidak ada kalor yang masuk atau keluar dari sistem (Palupi, 2009). Dengan kata lain, Q = 0.

  Persamaan yang menyatakan hubungan antara tekanan dan volume dalam proses adiabatik adalah:

  PVγ=konstanatauP1V1γ=P2V2γ

  dengan γadalah perbandingan kapasitas panas (Cp/Cv).

  Untuk gas ideal, berlaku:

  P=nRTV

  (Giancoli, 2001)

  ![](Aspose.Words.f522656b-4090-4b3b-bcc1-ff7222952d16.004.png)

  **Gambar 1.4** Diagram PV proses adiabatik, di mana usaha yang dilakukan sistem ditunjukkan oleh luasan yang diarsir

  *(Sumber: Palupi, 2009)*

Dengan memahami berbagai jenis proses ini, kita dapat melihat bagaimana hukum pertama termodinamika berlaku dalam setiap kondisi. Setiap perubahan keadaan gas selalu melibatkan perpindahan energi dalam bentuk kalor dan kerja, namun jumlah total energi selalu kekal.
''',
        'isDone': false,
      },
      {
        'nama': 'Hukum II Termodinamika',
        'isiMateri': '''
Jika hukum pertama termodinamika menjelaskan tentang jumlah energi (bahwa energi kekal), maka hukum kedua termodinamika menjelaskan arah alami dari perubahan energi tersebut.

   Hukum ini berhubungan dengan bagaimana energi panas berpindah dan seberapa efisien energi panas dapat diubah menjadi kerja.

   Hukum kedua termodinamika juga menjelaskan mengapa tidak semua energi panas dapat diubah menjadi energi mekanik sepenuhnya, karena sebagian selalu “hilang” dalam bentuk energi yang tidak berguna — biasanya berupa panas yang dibuang ke lingkungan.

1. Mesin Pemanas (Mesin Kalor)

   Hukum kedua termodinamika untuk mesin panas menyatakan bahwa tidak mungkin membuat mesin panas yang bekerja secara siklis tanpa menghasilkan efek lain selain menyerap panas dari tandon panas dan melakukan sejumlah kerja yang ekuivalen (Palupi, 2009).

   Dengan kata lain, setiap mesin yang bekerja berdasarkan siklus panas selalu membuang sebagian panas ke lingkungan (tandon dingin) dan tidak bisa 100% efisien.

   Mesin kalor adalah alat yang berfungsi mengubah energi panas menjadi energi mekanik. Salah satu contoh nyata adalah mesin mobil, di mana energi panas hasil pembakaran bahan bakar diubah menjadi energi gerak kendaraan (Tipler, 1998).

   Dalam satu siklus mesin kalor:

- Panas yang masuk ke sistem:

  Qmasuk=Q1+Q2

- Panas yang keluar dari sistem:

  Qkeluar=Q3+Q4

- Kerja yang dilakukan oleh mesin:

  W=Qmasuk-Qkeluar

![](Aspose.Words.f522656b-4090-4b3b-bcc1-ff7222952d16.005.png)

**Gambar 1.5** Alur kerja mesin pemanas

*(Sumber: Palupi, 2009)*

![](Aspose.Words.f522656b-4090-4b3b-bcc1-ff7222952d16.006.png)

**Gambar 1.6** Siklus mesin pemanas yang bekerja sesuai hukum termodinamika kedua

*(Sumber: Palupi, 2009)*

Efisiensi (η) mesin panas didefinisikan sebagai perbandingan antara kerja yang dihasilkan oleh mesin terhadap kalor yang diserap dari tandon panas (Giancoli, 2001):

η=WQp=Qp-QdQp=1-QdQp

Keterangan:

- η= efisiensi mesin
- W= kerja yang dilakukan mesin
- Qp= kalor yang masuk (dari tandon panas)
- Qd= kalor yang keluar (ke tandon dingin)

Efisiensi 100% hanya dapat dicapai jika Qd=0, artinya tidak ada panas yang dibuang ke tandon dingin. Namun, hal ini tidak mungkin terjadi menurut hukum kedua termodinamika (Giancoli, 2001). Oleh karena itu, setiap mesin kalor selalu memiliki efisiensi di bawah 100%.

1. Mesin Pendingin (Refrigerator)

   Mesin pendingin bekerja berdasarkan prinsip yang berlawanan dengan mesin kalor. Jika mesin kalor mengubah panas menjadi kerja, maka mesin pendingin menggunakan kerja untuk memindahkan panas dari tempat yang bersuhu rendah ke tempat yang bersuhu tinggi.

   Menurut hukum kedua termodinamika, sebuah mesin pendingin tidak dapat bekerja secara siklis tanpa menghasilkan efek lain di luar penyerapan panas dari benda dingin ke benda panas (Palupi, 2009).

   Mesin pendingin (refrigerator) beroperasi dengan mengambil kalor dari tandon dingin, kemudian kompresor memberikan kerja mekanik untuk memindahkan kalor tersebut ke tandon panas (lingkungan).

   Menurut Clausius, perumusan hukum kedua untuk mesin pendingin menyatakan bahwa panas tidak dapat berpindah dari benda dingin ke benda panas tanpa adanya kerja eksternal.

   Efisiensi atau koefisien performa (COP) mesin pendingin didefinisikan sebagai perbandingan antara kalor yang diserap dari tandon dingin terhadap kerja total yang dilakukan sistem (Tipler, 1998):

   η=QdW=QdQp-Qd

   atau dapat ditulis juga sebagai:

   η=1-QpQp

   Keterangan:

- η= efisiensi mesin pendingin
- W= kerja yang dilakukan kompresor
- Qp= kalor yang masuk
- Qd= kalor yang keluar

Dengan kata lain, semakin besar kalor yang dapat dipindahkan dengan kerja yang lebih kecil, semakin baik performa mesin pendingin tersebut.

1. Mesin Carnot

   Mesin Carnot merupakan model teoretis dari mesin panas ideal yang bekerja secara reversibel (dapat dibalik) di antara dua tandon panas dan dingin. Mesin ini diperkenalkan oleh Nicolas Léonard Sadi Carnot dan menjadi standar efisiensi maksimum yang dapat dicapai oleh mesin apa pun.

   Hukum kedua termodinamika menyatakan bahwa tidak ada mesin yang bekerja antara dua tandon panas yang dapat lebih efisien daripada mesin Carnot yang reversibel (Palupi, 2009).

   Secara matematis, efisiensi mesin Carnot dinyatakan sebagai:

   η=1-TdTp

   Keterangan:

- η= efisiensi mesin
- Tp= suhu tandon panas (dalam Kelvin)
- Td= suhu tandon dingin (dalam Kelvin)

Dari persamaan ini, terlihat bahwa efisiensi mesin Carnot bergantung hanya pada suhu kedua tandon. Semakin besar perbedaan suhu antara tandon panas dan dingin, maka efisiensi mesin semakin tinggi.

![](Aspose.Words.f522656b-4090-4b3b-bcc1-ff7222952d16.007.png)

**Gambar 1.7** Skema mesin Carnot yang bekerja sesuai hukum kedua termodinamika

*(Sumber: Palupi, 2009)*

Efisiensi maksimum mesin panas dicapai oleh mesin Carnot, dan tidak ada mesin nyata yang dapat melampaui efisiensi ini. Jika ada mesin yang lebih efisien dari mesin Carnot, maka hal itu akan melanggar hukum kedua termodinamika (Giancoli, 2001).

[ref1]: Aspose.Words.f522656b-4090-4b3b-bcc1-ff7222952d16.002.png
[ref2]: Aspose.Words.f522656b-4090-4b3b-bcc1-ff7222952d16.003.png
''',
        'isDone': false,
      },
      ujianAkhir('Gas Ideal')
    ],
    'soal': [
      {
        'isiSoal': 'Jelaskan apa yang dimaksud dengan hukum pertama termodinamika, dan berikan contoh penerapannya dalam kehidupan sehari-hari!',
        'kunciJawaban': '“Hukum pertama termodinamika menyatakan bahwa energi tidak dapat diciptakan maupun dimusnahkan, tetapi dapat diubah dari satu bentuk ke bentuk lainnya”. Artinya kalor yang masuk ke sistem dapat menaikkan energi dalam sistem atau digunakan untuk melakukan usaha.', 
        'soalKategori': '', 
        'batasWaktuPengerjaan': 500,  
      },
      {
        'isiSoal': 'Sebongkah tembaga bermassa 200 gram dipanaskan dari suhu 25°C hingga 125°C. Jika kalor jenis tembaga c = 0,39 J/g°C, hitunglah kalor yang diperlukan!',
        'kunciJawaban': '''
Diketahui: m = 200 g, 
c = 0,39 J/g°C
ΔT = 100°C
Ditanyakan : Q = …?
Penyelesaian : 
Q = m × c × ΔT
Q = 200 × 0,39 × 100 
Q = 7800 J
Jadi, kalor yang diperlukan untuk memanaskan tembaga tersebut adalah Q = 7,8 × 10³ Joule.
''',
        'batasWaktuPengerjaan': 300, 
      }, 
      {
        'isiSoal': 'Air bermassa 200 gram bersuhu 25°C dicampur dengan air panas 100 gram bersuhu 80°C dalam wadah kalorimeter yang diabaikan kalor jenisnya. Hitunglah suhu akhir campuran! (Diketahui kalor jenis air c = 4,2 J/g°C).',
        'kunciJawaban': '''
Diketahui : m1 = 100 g
m2 = 200 g
T1 = 80°C
T2 = 25°C
Ditanyakan : Tf = …?
Penyelesaian :
Qpanas = Qdingin
m1c (T1 - Tf) = m2c (Tf - T2)
karena kalir jenis air sama, maka c dapat di hilangkan sehingga :
m1 (T1 - Tf) = m2 (Tf - T2)
100 (80 - Tf) = 200 (Tf - 25)
8000 – 100 Tf = 200 Tf – 5000 
13000 = 300 Tf 
Tf = 13000/300
Tf = 43,3°C
Jadi, suhu akhir campuran air adalah Tf = 43,3°C.
''',
        'soalKategori': '', 
        'batasWaktuPengerjaan': 300, 
      }, 
    ],
    'isDoneMateri': false, 
  },

  {
    'namaMateri': 'Apa itu ChatGPT',
    'subMateri': [
      {
        'nama': 'Pengertian ChatGPT',
        'isiMateri': '''
ChatGPT adalah model bahasa berbasis kecerdasan buatan yang dikembangkan oleh OpenAI. 
Model ini dilatih menggunakan jutaan teks dari internet untuk memahami dan menghasilkan bahasa manusia secara alami. 
ChatGPT dapat menjawab pertanyaan, membantu menulis teks, membuat kode program, serta melakukan percakapan seperti manusia.

Secara teknis, ChatGPT dibangun di atas arsitektur *Transformer* dan menggunakan model besar seperti GPT-3.5 atau GPT-4, 
yang masing-masing memiliki miliaran parameter yang memungkinkan pemahaman konteks secara mendalam.
''',
        'isDone': false,
      },
      {
        'nama': 'Cara Kerja ChatGPT',
        'isiMateri': '''
ChatGPT bekerja dengan memprediksi kata berikutnya dalam sebuah kalimat berdasarkan konteks sebelumnya. 
Model ini tidak “mengerti” seperti manusia, tetapi menggunakan pola statistik dari data pelatihannya 
untuk menghasilkan respons yang relevan dan masuk akal.

Prosesnya melibatkan langkah-langkah:
1. Pengguna memberikan *prompt* (input teks).
2. Model menganalisis konteks dan memprediksi respons terbaik.
3. Sistem menghasilkan teks baru secara berurutan hingga selesai.

ChatGPT juga menggunakan teknik *reinforcement learning from human feedback* (RLHF) 
agar jawabannya lebih sesuai dengan harapan manusia.
''',
        'isDone': false,
      },
      {
        'nama': 'Manfaat ChatGPT',
        'isiMateri': '''
ChatGPT memiliki banyak manfaat di berbagai bidang, seperti:
- **Pendidikan:** membantu belajar konsep baru, menjawab pertanyaan, dan menjelaskan teori.
- **Pemrograman:** membantu menulis, menjelaskan, atau memperbaiki kode.
- **Bisnis:** mendukung layanan pelanggan dan pembuatan konten otomatis.
- **Produktivitas pribadi:** membantu menulis email, ringkasan, atau ide kreatif.

Meskipun bermanfaat, pengguna tetap perlu memverifikasi informasi karena ChatGPT tidak selalu akurat 100%.
''',
        'isDone': false,
      },
      ujianAkhir('Apa itu Chat GPT')
    ],
    'soal': [
      {
        'isiSoal': 'Jelaskan secara singkat apa itu ChatGPT dan bagaimana cara kerjanya.',
        'kunciJawaban': '''
ChatGPT adalah model bahasa buatan yang dikembangkan oleh OpenAI untuk menghasilkan teks alami. 
Model ini bekerja dengan memprediksi kata berikutnya berdasarkan konteks input, 
menggunakan pola yang dipelajari dari data besar. 
Teknologi ini memungkinkan ChatGPT menjawab pertanyaan dan berdialog seperti manusia.
''',
        'soalKategori': '', 
        'batasWaktuPengerjaan': 300, // 5 menit
      },
    ],
    'isDoneMateri': false, 
  },
];
