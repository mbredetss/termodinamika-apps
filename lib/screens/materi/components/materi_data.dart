Map<String, dynamic> ujianAkhir() {
  return {
    'nama': 'Latihan Soal Termodinamika',
    'isiMateri': '''
# Aturan

Kuis ini bertujuan untuk menguji pengetahuan Anda tentang materi Termodinamika yang telah dipelajari sebelumnya.

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
    'namaMateri': 'Selamat Datang di Materi Thermodinamika',
    'subMateri': [
      {
        'nama': 'Pendahuluan',
        'isiMateri': '''
**Capaian Pembelajaran**

Peserta didik mampu menerapkan konsep dan prinsip termodinamika, dengan berbagai perubahannya dalam mesin kalor.

**Tujuan Pembelajaran**

1. Menerapkan teori kinetik gas untuk menganalisis berbagai sifat-sifat gas.
1. Menganalisis hukum-hukum gas (Boyle, Charles, Gay-Lussac, dan Avogadro) yang membentuk persamaan gas ideal.
1. Menganalisis berbagai proses termodinamika, seperti isobarik, isokorik, isotermal, dan adiabatik.
1. Menerapkan Hukum I Termodinamika dalam menyelesaikan permasalahan fisika dalam kehidupan sehari-hari.
1. Membedakan tiga pernyataan Hukum II Termodinamika (Kelvin–Planck, Clausius, dan entropi).
1. Menjelaskan cara kerja dan efisiensi mesin kalor serta pompa kalor.
''',
        'isDone': false,
      },
    ],
    'isDoneMateri': false,
  },
  {
    'namaMateri': 'Gas Ideal',
    'subMateri': [
      {
        'nama': 'Pengertian Gas',
        'isiMateri': '''
**Pengertian Gas**
Gas merupakan zat yang memiliki sifat mampu menempati seluruh ruang yang tersedia dan mudah mengembang. Susunan molekul gas dapat dilihat pada *Gambar 1*, di mana molekul-molekulnya tersebar bebas dan berjauhan satu sama lain.

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.001.png)

   **Gambar 1. Struktur molekul gas**

   Selain itu, sifat gas juga dapat diamati dari kemampuan gas untuk mengembang. *Tabel 1* berikut memperlihatkan koefisien muai volume beberapa materi.

   **Tabel 1. Koefisien Muai Volume Beberapa Materi**

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.002.png)

Dari informasi tersebut, dapat disimpulkan bahwa gas memiliki keistimewaan karena dapat menempati ruang dengan cepat dan memuai dengan cepat. Kedua sifat ini menjadi dasar bagi teori kinetik gas.

**Teori Kinetik Gas**

Teori kinetik gas menjelaskan sifat-sifat gas melalui model mikroskopik partikel-partikelnya. Asumsi-asumsi dasar teori kinetik gas adalah sebagai berikut:

1. Molekul-molekul gas bergerak secara acak (random motion).
1. Gaya tarik menarik antar molekul diabaikan, karena jarak antar molekul jauh lebih besar daripada ukuran molekulnya.
1. Jumlah molekul gas sangat besar, sehingga secara statistik gerakannya dapat dihitung.
1. Volume total semua molekul sangat kecil dibandingkan volume wadah gas, sehingga dapat diabaikan.
1. Tumbukan antar molekul dan dengan dinding wadah bersifat elastis sempurna, artinya tidak ada energi kinetik yang hilang.

Berdasarkan teori kinetik gas, tekanan gas disebabkan oleh tumbukan molekul-molekul gas dengan dinding wadah, sedangkan suhu gas menggambarkan energi kinetik rata-rata molekul-molekul gas tersebut.
''',
        'isDone': false,
      },
      {
        'nama': 'Hukum-Hukum tentang Gas',
        'isiMateri': '''
**Hukum-Hukum tentang Gas**
Perilaku gas pada kondisi tertentu dapat dijelaskan melalui beberapa hukum gas yang ditemukan secara eksperimen.

1. **Hukum Boyle**

   Robert Boyle (1627–1691), seorang fisikawan Irlandia, mempelajari hubungan antara tekanan (p) dan volume (V) gas. Skema percobaan Boyle diperlihatkan pada *Gambar 2*.

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.003.png)

   **Gambar 2. Eksperimen Hukum Boyle**

   Dalam percobaan tersebut, diperhatikan bahwa ketika suhu dan jumlah mol tetap, hasil kali antara tekanan dan volume gas selalu konstan. Secara matematis dapat ditulis sebagai:

   pV=konstan

   pada suhu dan jumlah mol tetap.
   Untuk dua keadaan gas berbeda:

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.004.png)

   **Keterangan:**

- p1= Tekanan mula-mula
- p2= Tekanan akhir
- V1= Volume mula-mula
- V2= Volume akhir
  (satuan dapat berupa atm, cmHg, N/m², atau Pa)
1. **Hukum Charles**

   Jacques Alexandre César Charles (1746–1823), seorang ilmuwan asal Prancis, mempelajari hubungan antara volume gas (V) dan suhu (T) pada tekanan tetap. Eksperimen Charles diperlihatkan pada *Gambar 3*.

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.005.png)

   **Gambar 3. Eksperimen Hukum Charles**

   Charles menemukan bahwa pada tekanan dan jumlah mol konstan, volume gas berbanding lurus dengan suhu mutlaknya. Secara matematis dinyatakan:

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.006.png)

   Untuk dua keadaan gas berbeda:

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.007.png)

1. **Hukum Gay-Lussac**

   Joseph Louis Gay-Lussac (1778–1850), seorang fisikawan Prancis, mempelajari hubungan antara tekanan (p) dan suhu (T) dari gas pada volume tetap. Eksperimen Gay-Lussac diperlihatkan pada *Gambar 4*.

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.008.png)

   **Gambar 4. Eksperimen Hukum Gay-Lussac**

   Hasilnya menunjukkan bahwa jika volume gas dijaga konstan, maka tekanan gas meningkat seiring meningkatnya suhu. Secara matematis:

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.009.png)

   Untuk dua keadaan gas:

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.010.png)

1. **Hukum Avogadro**

   Amedeo Avogadro (1776–1856), ilmuwan Italia, mempelajari hubungan antara volume gas (V) dan jumlah mol gas (n) pada suhu dan tekanan tertentu. Eksperimennya digambarkan dalam *Gambar 5*.

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.011.png)

   **Gambar 5. Eksperimen Hukum Avogadro**

   Avogadro menemukan bahwa pada suhu dan tekanan yang sama, gas dengan volume sama mengandung jumlah molekul yang sama. Secara matematis dituliskan:

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.012.png)

   atau

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.013.png)
''',
        'isDone': false,
      },
      {
        'nama': 'Gas Nyata dan Gas Ideal',
        'isiMateri': '''
**Gas Nyata dan Gas Ideal**

   Model gas ideal dikembangkan untuk menyederhanakan analisis perilaku gas nyata. Dalam kehidupan sehari-hari, gas yang kita jumpai disebut gas nyata, sedangkan gas ideal merupakan model teoretis yang mengikuti hukum-hukum gas secara sempurna.

   Perhatikan hubungan umum antara p, V, T, dan n pada gas nyata yang dijelaskan oleh persamaan Van der Waals:

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.014.png)

   di mana:

- a menunjukkan pengaruh gaya tarik-menarik antar molekul,
- b menunjukkan pengaruh volume molekul gas itu sendiri.

**Persamaan Gas Ideal**

Dengan menggabungkan keempat hukum gas (Boyle, Charles, Gay-Lussac, dan Avogadro), diperoleh persamaan gas ideal:

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.015.png)

Keterangan:

- p= Tekanan mutlak gas (Pa)
- V= Volume gas (m³)
- n= Jumlah mol gas
- T= Suhu mutlak (K)
- R= Tetapan gas umum (8,314472 J/mol·K)

Gas nyata akan bersifat seperti gas ideal pada tekanan rendah dan suhu tinggi, di mana gaya antar molekul menjadi sangat kecil.

Persamaan tersebut juga dapat ditulis dalam bentuk yang melibatkan jumlah partikel gas:

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.016.png)

dengan:

- N= jumlah partikel gas
- NA= bilangan Avogadro
- k= konstanta Boltzmann,
  di mana k=R/NA.
''',
        'isDone': false,
      },
    ],
    'isDoneMateri': false,
  },
  {
    'namaMateri': 'Konsep Dasar Termodinamika',
    'subMateri': [
      {
        'nama': 'Pengertian Termodinamika',
        'isiMateri': '''
- **Pengertian Termodinamika**

     Termodinamika berasal dari dua kata, yaitu *thermos* (panas) dan *dynamis* (gaya atau gerak). Secara umum, termodinamika merupakan cabang ilmu fisika yang mempelajari tentang hubungan antara kalor (panas), kerja (usaha), dan energi.

     Dalam kehidupan sehari-hari, konsep termodinamika dapat ditemukan di berbagai peristiwa, seperti proses pembakaran mesin mobil, kinerja kulkas, kompresor udara, hingga proses metabolisme pada makhluk hidup. Semua contoh tersebut melibatkan perubahan energi panas menjadi bentuk energi lain.

     Secara khusus, termodinamika meneliti bagaimana energi berpindah dalam suatu sistem, dan bagaimana perubahan tersebut memengaruhi suhu, tekanan, dan volume suatu zat.''',
        'isDone': false,
      },
      {
        'nama': 'Sistem dan Lingkungan',
        'isiMateri': '''
   - **Sistem dan Lingkungan**

     Dalam termodinamika, sistem adalah bagian dari alam semesta yang menjadi fokus kajian, sedangkan lingkungan adalah segala sesuatu di luar sistem yang berinteraksi dengannya.

     Sistem dibedakan menjadi tiga jenis utama:

1. Sistem Terbuka, yaitu sistem yang dapat bertukar energi dan massa dengan lingkungan.

   Contohnya: panci terbuka berisi air yang mendidih, karena uap air keluar dan panas berpindah ke udara.

1. Sistem Tertutup, yaitu sistem yang hanya dapat bertukar energi tetapi tidak massa dengan lingkungan.

   Contohnya: balon udara, karena kalor bisa berpindah, tetapi gas di dalamnya tidak keluar.

1. Sistem Terisolasi, yaitu sistem yang tidak dapat bertukar energi maupun massa dengan lingkungan.

   Contohnya: termos berisi air panas yang tertutup rapat, karena panas dan massa tidak berpindah.

''',
        'isDone': false,
      },
      {
        'nama': 'Besaran-Besaran Termodinamika',
        'isiMateri': '''
   - **Besaran-Besaran Termodinamika**

     Untuk memahami konsep termodinamika, diperlukan beberapa besaran penting, yaitu:

1. **Energi Dalam (U)**

   Energi dalam adalah jumlah seluruh energi mikroskopik (energi kinetik dan potensial) dari molekul-molekul penyusun zat. Energi dalam dapat berubah karena adanya kalor (Q) yang diterima atau dilepaskan sistem dan kerja (W) yang dilakukan oleh atau terhadap sistem.

1. **Kalor (Q)**

   Kalor adalah bentuk energi yang berpindah akibat perbedaan suhu antara dua benda. Kalor mengalir dari benda bersuhu tinggi ke benda bersuhu rendah hingga tercapai keseimbangan termal.

1. **Kerja (W)**

   Kerja adalah energi yang dipindahkan ketika gaya bekerja pada suatu sistem sehingga terjadi perubahan volume. Pada sistem gas, kerja didefinisikan sebagai:

   W=pΔV
   dengan:

   1. W= kerja yang dilakukan (Joule)
   1. p= tekanan (Pascal)
   1. ΔV= perubahan volume (m³)
1. **Suhu (T)**

   Suhu merupakan ukuran derajat panas suatu benda yang berhubungan langsung dengan energi kinetik rata-rata partikel-partikel penyusun benda tersebut. Suhu diukur dalam satuan Kelvin (K).
''',
        'isDone': false,
      },
      {
        'nama': 'Hukum Pertama Termodinamika',
        'isiMateri': '''
Hukum pertama termodinamika merupakan pernyataan formal dari hukum kekekalan energi, yang menyatakan bahwa energi tidak dapat diciptakan maupun dimusnahkan, melainkan dapat berubah bentuk dari satu bentuk energi ke bentuk lainnya.

Secara matematis, hukum ini dirumuskan sebagai:

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.017.png)

Keterangan:

- Q= kalor yang diterima sistem (positif jika sistem menerima kalor, negatif jika melepaskan)
- ΔU= perubahan energi dalam sistem
- W= kerja yang dilakukan oleh sistem

Artinya, kalor yang diterima oleh sistem digunakan untuk meningkatkan energi dalam sistem dan/atau melakukan kerja terhadap lingkungan. Jika sistem melakukan kerja terhadap lingkungan, maka energi dalamnya berkurang.

**Arah Pertukaran Energi**

Dalam proses termodinamika, energi dapat berpindah ke dalam atau keluar dari sistem. Aturan tandanya sebagai berikut:

**Tabel 2. Arah perpindahan kalor**

|**Proses**|**Q (Kalor)**|**W (Kerja)**|**Keterangan**|
| :-: | :-: | :-: | :-: |
|Sistem menerima kalor|+|-|Energi masuk ke sistem|
|Sistem melepaskan kalor|-|+|Energi keluar dari sistem|
|Sistem melakukan kerja|-|+|Energi keluar dari sistem|
|Lingkungan melakukan kerja pada sistem|+|-|Energi masuk ke sistem|

Tabel di atas menunjukkan bahwa tanda positif atau negatif pada Q dan W bergantung pada arah perpindahan energi.
''',
        'isDone': false,
      },
      {
        'nama': 'Proses-Proses Termodinamika',
        'isiMateri': '''
  Hukum pertama termodinamika dapat diterapkan dalam berbagai proses perubahan keadaan gas, yaitu:

  - **Proses Isobarik (Tekanan Tetap)**

    Pada proses ini, tekanan sistem tetap sementara volume dan suhu berubah. Persamaan keadaannya adalah:

    ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.006.png)

    Kerja yang dilakukan gas dalam proses isobarik:

    ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.018.png)

  - **Proses Isokhorik (Volume Tetap)**

    Volume sistem tetap, sehingga tidak ada kerja (W = 0). Semua energi panas yang diterima digunakan untuk mengubah energi dalam sistem:

    Q=ΔU
    Persamaan keadaannya:

    ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.009.png)

  - **Proses Isotermal (Suhu Tetap)**

    Suhu sistem konstan, sehingga tidak terjadi perubahan energi dalam (ΔU=0).
    Persamaan keadaannya:

    ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.019.png)

    Kerja yang dilakukan:

    ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.020.png)

    dan karena ΔU=0, maka Q=W.

  - **Proses Adiabatik (Tanpa Pertukaran Kalor)**

    Dalam proses ini, tidak ada kalor yang keluar atau masuk ke sistem (Q=0).
    Hubungan antara tekanan dan volume:

    ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.021.png)

    dengan ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.022.png), yaitu perbandingan kapasitas panas pada tekanan dan volume tetap.
''',
        'isDone': false,
      },
    ],
    'isDoneMateri': false,
  },
  {
    'namaMateri': 'Hukum II Termodinamika',
    'subMateri': [
      {
        'nama': 'Bunyi Hukum II Termodinamika',
        'isiMateri': '''
**Bunyi Hukum II Termodinamika**
      Ada beberapa pernyataan atau formulasi berbeda mengenai Hukum II Termodinamika, namun semuanya memiliki makna yang sama.

1. **Pernyataan Kelvin-Planck**

   Tidak mungkin membuat mesin yang bekerja secara siklis dan hanya menghasilkan kerja dengan menyerap panas dari satu sumber saja.Artinya, sebagian panas yang diserap oleh mesin selalu dibuang ke tandon suhu rendah.

1. **Pernyataan Clausius**

   Tidak mungkin suatu sistem secara spontan memindahkan panas dari benda bersuhu rendah ke benda bersuhu tinggi tanpa bantuan kerja eksternal.

Dua pernyataan tersebut saling melengkapi:

- Kelvin-Planck menjelaskan batas efisiensi mesin panas,
- Clausius menjelaskan arah alami perpindahan panas.
''',
        'isDone': false,
      },
      {
        'nama': 'Aplikasi Hukum II Termodinamika',
        'isiMateri': '''
**Aplikasi Hukum II Termodinamika**

Hukum kedua termodinamika banyak diterapkan dalam sistem mesin seperti:

- Mesin Kalor (Heat Engine), yang mengubah energi panas menjadi kerja.
- Mesin Pendingin (Refrigerator), yang memindahkan panas dari benda dingin ke benda panas dengan bantuan kerja eksternal.
- Mesin Carnot, yaitu mesin ideal yang efisiensinya paling tinggi secara teoritis.
1. **Mesin Kalor (Heat Engine)**

   Mesin kalor adalah sistem yang berfungsi untuk mengubah energi panas menjadi energi mekanik (kerja). Mesin ini bekerja berdasarkan prinsip bahwa sebagian panas dari sumber suhu tinggi diubah menjadi kerja, sementara sebagian lainnya dibuang ke tandon suhu rendah.

   Proses dalam satu siklus mesin kalor dapat digambarkan sebagai berikut:

- Panas masuk (Qp) diterima dari tandon panas bersuhu tinggi.
- Sebagian energi panas diubah menjadi kerja (W) oleh sistem.
- Sisa panas (Qd) dibuang ke tandon suhu rendah.

Secara matematis, kerja yang dihasilkan mesin adalah:

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.023.png)

Efisiensi mesin kalor (η) didefinisikan sebagai:

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.024.png)

Keterangan:

- η= efisiensi mesin
- W= kerja yang dilakukan
- Qp= kalor yang masuk
- Qd= kalor yang keluar

Efisiensi maksimum mesin panas terjadi bila Qd=0, namun hal ini tidak mungkin karena bertentangan dengan hukum kedua termodinamika. Oleh sebab itu, tidak ada mesin panas yang memiliki efisiensi 100%.

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.025.png)

**Gambar 6.** Skema pompa kalor dan siklus pompa kalor

**Gambar 6. Skema mesin kalor** menggambarkan aliran energi pada mesin ini, di mana sebagian kalor masuk diubah menjadi kerja, dan sebagian lagi dibuang ke lingkungan.

1. **Mesin Pendingin (Refrigerator)**

   Mesin pendingin bekerja berlawanan arah dengan mesin kalor. Jika mesin kalor mengubah panas menjadi kerja, maka mesin pendingin menggunakan kerja eksternal untuk memindahkan panas dari benda bersuhu rendah ke benda bersuhu tinggi.

   Prinsip kerja mesin pendingin berdasarkan hukum kedua termodinamika dapat dijelaskan sebagai berikut:

- Mesin mengambil panas (Qd) dari tandon dingin.
- Kompresor memberikan kerja (W) untuk memindahkan panas tersebut ke tandon panas.
- Total energi panas yang dibuang ke tandon panas adalah:

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.026.png)

Efisiensi mesin pendingin diukur dengan koefisien performa (COP), yang dirumuskan sebagai:

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.027.png)

Keterangan:

- Qd= kalor yang diserap dari tandon dingin
- Qp= kalor yang dibuang ke tandon panas
- W= kerja yang dilakukan oleh kompresor

Efisiensi mesin pendingin tidak mungkin tak terhingga, karena selalu diperlukan kerja eksternal untuk menjaga aliran panas dari dingin ke panas.

1. **Mesin Carnot**

   Mesin Carnot merupakan mesin panas ideal yang diperkenalkan oleh Nicolas Léonard Sadi Carnot. Mesin ini bekerja secara reversibel (dapat dibalik) antara dua tandon panas dan dingin, serta memiliki efisiensi maksimum yang secara teoritis tidak dapat dilampaui oleh mesin mana pun.

   Menurut hukum kedua termodinamika, efisiensi mesin Carnot bergantung hanya pada suhu kedua tandon, bukan pada jenis zat kerja yang digunakan.

   Efisiensi mesin Carnot dinyatakan sebagai:

   ![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.028.png)

   Keterangan:

- η= efisiensi mesin
- Tp= suhu tandon panas (K)
- Td= suhu tandon dingin (K)

Semakin besar perbedaan suhu antara tandon panas dan tandon dingin, semakin tinggi efisiensi mesin Carnot. Namun, efisiensi 100% hanya akan tercapai jika Td=0 K, yang tidak mungkin terjadi secara fisik.

![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.029.png)

**Gambar 7.** (a) Skema mesin Carnot, (b) Siklus Carnot

**Gambar 7. Mesin Carnot** menunjukkan prinsip kerja mesin ideal ini, di mana siklus Carnot terdiri dari dua proses isotermal dan dua proses adiabatik:

**Tabel 3. Proses Termodinamika Mesin Carnot**

|**Proses Termodinamika**|**Persamaan** |
| :-: | :-: |
|Isotermal ekspansi|![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.030.png)∆U=0|
|Adiabatis ekspansi|![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.031.png)Q=0|
|Isotermal kompresi|![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.030.png)∆U=0|
|Adiabatis kompresi|![](Aspose.Words.74c2c7e1-c439-44b4-8b27-66b469c5eeeb.031.png)Q=0|

**Hubungan Antara Mesin Kalor, Pendingin, dan Carnot**

Ketiga jenis mesin ini menunjukkan bagaimana energi berpindah antara panas dan kerja:

- Mesin kalor mengubah panas menjadi kerja.
- Mesin pendingin menggunakan kerja untuk memindahkan panas.
- Mesin Carnot memberikan batas efisiensi tertinggi bagi keduanya.

Oleh karena itu, Hukum II Termodinamika tidak hanya menjelaskan arah alami perpindahan energi, tetapi juga menetapkan batas fundamental bagi efisiensi setiap sistem energi di alam semesta.
''',
        'isDone': false,
      },
    ],
    'isDoneMateri': false,
  },

  // Final combined assessment at the end
  {
    'namaMateri': 'Evaluasi Akhir',
    'subMateri': [ujianAkhir()],
    'soal': [
      {
        'isiSoal':
            'Jelaskan hubungan antara suhu dan energi kinetik rata-rata partikel gas!',
        'kunciJawaban':
            'Suhu suatu gas berhubungan langsung dengan energi kinetik rata-rata partikel-partikelnya. Artinya, semakin tinggi suhu gas, semakin besar energi kinetik rata-rata partikel gas tersebut. Hal ini terjadi karena saat suhu naik, partikel-partikel gas bergerak lebih cepat. Sebaliknya, jika suhu turun, gerakan partikel melambat sehingga energi kinetiknya juga lebih kecil. Jadi, suhu adalah ukuran seberapa cepat partikel gas bergerak.',
        'soalKategori': '',
        'batasWaktuPengerjaan': 600,
      },
      {
        'isiSoal': 'Apa perbedaan utama antara Hukum Boyle dan Hukum Charles?',
        'kunciJawaban':
            'Hukum Boyle dan Hukum Charles memiliki perbedaan utama pada besaran-besaran gas yang dibandingkan serta kondisi yang dijaga tetap. Hukum Boyle membahas hubungan antara tekanan dan volume gas ketika suhu dijaga tetap. Pada hukum ini, tekanan dan volume memiliki hubungan berbanding terbalik, sehingga jika tekanan meningkat maka volume gas akan mengecil, dan jika tekanan menurun maka volume gas akan membesar. Sementara itu, Hukum Charles membahas hubungan antara volume dan suhu gas ketika tekanan dijaga tetap. Pada hukum ini, volume gas berbanding lurus dengan suhu, sehingga jika suhu meningkat volume gas ikut membesar, dan jika suhu menurun volume gas mengecil. Jadi, Hukum Boyle fokus pada tekanan–volume pada suhu konstan, sedangkan Hukum Charles fokus pada volume–suhu pada tekanan konstan.',
        'batasWaktuPengerjaan': 600,
      },
      {
        'isiSoal':
            'Gas ideal 2 mol berada pada suhu 300 K. Hitung energi kinetik rata-ratanya!',
        'kunciJawaban': r'''
**Diketahui:**
- $n = 2\ \text{mol}$
- $T = 300\ \text{K}$
- $R = 8{,}314\ \text{J/mol·K}$

**Ditanyakan:**
- $E_k =\ ?$

**Penyelesaian:**

Rumus energi kinetik total gas ideal:
\[
E_k = \frac{3}{2} nRT
\]

Substitusi nilai:
\[
E_k = \frac{3}{2} \times 2 \times 8{,}314 \times 300
\]

\[
E_k = 3 \times 8{,}314 \times 300
\]

\[
E_k = 24{,}942 \times 300
\]

\[
E_k = 7{,}482{,}600\ \text{J}
\]

**Jawaban:**

Energi kinetik total gas ideal tersebut adalah  
\[
E_k = 7{,}48 \times 10^6\ \text{J}
\]
''',
        'batasWaktuPengerjaan': 900,
      },
      {
        'isiSoal':
            'Analisis apa yang terjadi pada tekanan gas jika volume diperbesar menjadi tiga kali lipat pada suhu tetap!',
        'kunciJawaban':
            'Jika volume gas diperbesar menjadi tiga kali lipat sementara suhunya tetap, maka tekanan gas akan menurun menjadi sepertiga dari tekanan awal. Hal ini terjadi karena menurut Hukum Boyle, tekanan dan volume berbanding terbalik pada suhu tetap. Artinya, ketika volume diperbesar, partikel gas memiliki ruang yang lebih luas untuk bergerak sehingga frekuensi tumbukan partikel dengan dinding wadah berkurang. Akibatnya, tekanan yang diberikan gas menjadi lebih kecil. Dengan demikian, jika volume menjadi tiga kali lebih besar, tekanan gas akan turun menjadi sepertiga dari keadaan awal.',
        'soalKategori': '',
        'batasWaktuPengerjaan': 600,
      },
      {
        'isiSoal':
            'Sebuah mesin A memiliki efisiensi 40%, sedangkan B 55%. Evaluasi mana yang lebih baik dan mengapa!',
        'kunciJawaban': 'Mesin B lebih baik dibandingkan mesin A karena memiliki efisiensi yang lebih tinggi. Efisiensi menunjukkan seberapa besar bagian energi masukan yang dapat diubah menjadi kerja berguna. Mesin A hanya mengubah 40% energi masukan menjadi kerja, sedangkan mesin B mampu mengubah 55%. Artinya, mesin B menghasilkan lebih banyak kerja dengan jumlah energi yang sama, sehingga lebih hemat energi, lebih efektif, dan lebih menguntungkan untuk digunakan.',
        'soalKategori': '',
        'batasWaktuPengerjaan': 600,
      }, 
      {
        'isiSoal':
            'Sebutkan ciri utama dari proses isokhorik dalam termodinamika!',
        'kunciJawaban':
            'Ciri utama dari proses isokhorik dalam termodinamika adalah volume sistem tetap dan tidak berubah selama proses berlangsung. Karena volumenya tetap, usaha (work) yang dilakukan gas bernilai nol, sebab gas tidak mengalami perubahan ukuran. Dalam proses ini, perubahan energi dalam hanya dipengaruhi oleh perubahan suhu, bukan oleh perubahan volume.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            '7.	Mengapa energi dalam suatu sistem dapat berubah ketika sistem menerima kalor atau melakukan usaha? Jelaskan berdasarkan Hukum I Termodinamika.',
        'kunciJawaban':
            'Energi dalam suatu sistem bisa berubah karena adanya perpindahan energi, baik dalam bentuk kalor maupun usaha. Sesuai Hukum I Termodinamika, ΔU = Q − W, jika sistem menerima kalor (Q positif) atau dilakukan kerja pada sistem (W negatif), maka energi dalamnya akan bertambah. Sebaliknya, jika sistem melepaskan kalor atau melakukan kerja, energi dalamnya akan berkurang. Jadi, perubahan energi dalam selalu merupakan akibat dari perpindahan kalor dan usaha.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Sebuah gas memiliki tekanan 2 atm, volume 3 L, dan jumlah mol 0,25 mol. Berapa suhu gas tersebut?',
        'kunciJawaban':
            r'''
**Diketahui:**
- $P = 2\ \text{atm}$
- $V = 3\ \text{L}$
- $n = 0{,}25\ \text{mol}$
- $R = 0{,}0821\ \text{L·atm/mol·K}$

**Ditanyakan:**
- $T =\ ?$

**Penyelesaian:**

Rumus gas ideal:
\[
T = \frac{PV}{nR}
\]

Substitusi nilai:
\[
T = \frac{2 \times 3}{0{,}25 \times 0{,}0821}
\]

\[
T = \frac{6}{0{,}020525}
\]

\[
T = 292{,}4\ \text{K}
\]

**Jawaban:**

Suhu gas tersebut adalah sekitar  
\[
T \approx 292\ \text{K}
\]
''',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 900
      }, 
      {
        'isiSoal':
            'Perhatikan grafik PV (isotermal). Analisis mengapa kurva berbentuk hiperbola!',
        'kunciJawaban':
            'Pada proses isotermal suhu gas tetap, sehingga berdasarkan persamaan gas ideal PV=nRT, karena T, n, dan R konstan, maka hasil kali P⋅Vjuga konstan. Artinya, ketika volume membesar, tekanan harus mengecil secara berbanding terbalik, dan sebaliknya. Hubungan berbanding terbalik inilah yang secara matematis membentuk kurva hiperbola pada grafik P–V.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Evaluasi apakah mungkin membuat proses adiabatik yang berlangsung sangat lambat. Jelaskan alasanmu!',
        'kunciJawaban':
            'Proses adiabatik tidak mungkin berlangsung sangat lambat. Alasannya, proses adiabatik adalah proses yang tidak melibatkan pertukaran panas (Q = 0) antara sistem dan lingkungannya. Untuk mencegah panas masuk atau keluar, proses ini harus berlangsung sangat cepat, atau sistem harus mempunyai isolasi termal yang sangat baik. Jika proses berjalan sangat lambat, maka akan ada cukup waktu bagi panas untuk mengalir dari atau ke lingkungan, sehingga proses tersebut tidak lagi adiabatik melainkan mendekati isotermal. Oleh karena itu, proses adiabatik tidak dapat dilakukan secara lambat tanpa kehilangan sifat adiabatik, kecuali dalam kasus ideal dengan isolasi sempurna.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Mengapa tidak mungkin membuat mesin kalor yang memiliki efisiensi 100%?',
        'kunciJawaban':
            'Mesin kalor tidak mungkin memiliki efisiensi 100% karena menurut Hukum II Termodinamika, tidak semua kalor yang diterima mesin bisa diubah menjadi usaha. Sebagian kalor pasti harus dibuang ke lingkungan. Bahkan mesin paling ideal sekalipun, yaitu mesin Carnot, efisiensinya tetap kurang dari 100%. Jadi, secara hukum fisika, selalu ada energi yang terbuang, itulah sebabnya efisiensi sempurna tidak mungkin tercapai.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Hitung kerja pada proses isotermal ketika volume berubah dari 2 L menjadi 6 L pada tekanan 1 atm!',
        'kunciJawaban':
            r'''
**Diketahui:**
- $P = 1\ \text{atm}$
- $V_1 = 2\ \text{L}$
- $V_2 = 6\ \text{L}$

**Ditanyakan:**
- $W =\ ?$

**Penyelesaian:**

Perubahan volume:
\[
\Delta V = V_2 - V_1
\]

\[
\Delta V = 6 - 2
\]

\[
\Delta V = 4\ \text{L}
\]

Rumus kerja pada tekanan tetap:
\[
W = P \Delta V
\]

\[
W = 1 \times 4
\]

\[
W = 4\ \text{L·atm}
\]

Konversi ke joule:
\[
1\ \text{L·atm} = 101{,}3\ \text{J}
\]

\[
W = 4 \times 101{,}3 = 405{,}2\ \text{J}
\]

**Jawaban:**

Kerja yang dilakukan gas adalah  
\[
W = 4\ \text{L·atm} \approx 405\ \text{J}
\]
''',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 900
      }, 
      {
        'isiSoal':
            'Analisis perbedaan energi dalam pada proses isobarik dibandingkan isokhorik ketika diberikan kalor yang sama!',
        'kunciJawaban':
            'Jika dua proses isobarik dan isokhorik diberi kalor yang sama, maka perubahan energi dalamnya tidak sama. Pada proses isokhorik, gas tidak melakukan usaha karena volumenya tetap, sehingga seluruh kalor yang masuk digunakan untuk menaikkan energi dalam. Tetapi pada proses isobarik, gas memuai dan melakukan usaha, sehingga sebagian kalor berubah menjadi kerja, dan sisanya saja yang menaikkan energi dalam. Jadi, kenaikan energi dalam pada proses isokhorik lebih besar daripada pada proses isobarik untuk kalor yang sama.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Sebuah motor panas dirancang bekerja tanpa adanya gesekan sama sekali dan tanpa kehilangan energi ke lingkungan. Analisis apakah rancangan tersebut memungkinkan diterapkan dalam sistem nyata!',
        'kunciJawaban':
            'Secara teori kita bisa membayangkan mesin tanpa gesekan dan tanpa kehilangan energi, tetapi dalam sistem nyata hal itu tidak mungkin diwujudkan. Menurut Hukum II Termodinamika, selalu ada energi yang terbuang ke lingkungan, misalnya dalam bentuk panas akibat gesekan, hambatan udara, atau getaran. Jadi, motor panas yang benar-benar tanpa kehilangan energi hanya bisa ada di model ideal, bukan di dunia nyata. Karena itu, rancangan tersebut tidak layak diterapkan secara realistis.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Gas menerima kalor 500 J dan melakukan usaha 200 J. Berapa perubahan energi dalamnya?',
        'kunciJawaban':
            r'''
**Diketahui:**
- $Q = 500\ \text{J}$
- $W = 200\ \text{J}$

**Ditanyakan:**
- $\Delta U =\ ?$

**Penyelesaian:**

Hukum I Termodinamika:
\[
\Delta U = Q - W
\]

Substitusi nilai:
\[
\Delta U = 500 - 200
\]

\[
\Delta U = 300\ \text{J}
\]

**Jawaban:**

Perubahan energi dalam gas adalah  
\[
\Delta U = 300\ \text{J}
\]
''',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 900
      }, 
      {
        'isiSoal':
            '16.	Sebuah mesin kalor menerima 800 J kalor dan membuang 300 J. Hitung efisiensinya!',
        'kunciJawaban':
            r'''
**Diketahui:**
- $Q_{\text{in}} = 800\ \text{J}$
- $Q_{\text{out}} = 300\ \text{J}$

**Ditanyakan:**
- $e =\ ?$

**Penyelesaian:**

Kerja yang dihasilkan mesin kalor:
\[
W = Q_{\text{in}} - Q_{\text{out}}
\]

\[
W = 800 - 300
\]

\[
W = 500\ \text{J}
\]

Efisiensi mesin kalor:
\[
e = \frac{W}{Q_{\text{in}}}
\]

\[
e = \frac{500}{800}
\]

\[
e = 0{,}625
\]

\[
e = 62{,}5\%
\]

**Jawaban:**

Efisiensi mesin kalor tersebut adalah  
\[
e = 0{,}625 \text{ atau } 62{,}5\%
\]
''',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 900
      }, 
      {
        'isiSoal':
            'Suatu sistem memiliki ΔU = 0. Analisis jenis proses apa yang terjadi dan bagaimana hubungan Q serta W!',
        'kunciJawaban':
            'Jika suatu sistem memiliki ΔU = 0, artinya energi dalamnya tidak berubah. Untuk gas ideal, kondisi ini biasanya menunjukkan proses isotermal, yaitu suhu tetap. Berdasarkan Hukum I Termodinamika (ΔU = Q − W), jika ΔU = 0, maka berlaku Q = W, artinya kalor yang masuk ke sistem seluruhnya digunakan untuk melakukan usaha. Selain itu, ΔU = 0 juga bisa terjadi pada satu siklus penuh, karena sistem kembali ke keadaan awal.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Analisis mengapa mesin Carnot dianggap mesin dengan efisiensi maksimum!',
        'kunciJawaban':
            r'Mesin Carnot dianggap memiliki efisiensi maksimum karena mesin ini bekerja secara ideal dan reversibel, artinya tidak ada gesekan dan tidak ada kehilangan energi akibat proses yang tidak sempurna. Efisiensinya hanya ditentukan oleh suhu tandon panas dan tandon dingin, dengan rumus $\eta_{\text{Carnot}} = 1 - \frac{T_c}{T_h}$ Menurut Hukum II Termodinamika, tidak ada mesin nyata yang bisa melampaui efisiensi Carnot. Jadi, mesin Carnot menjadi batas atas efisiensi tertinggi semua mesin kalor.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Sebuah kompresor gas bekerja dengan cara menekan gas sehingga suhunya meningkat, meskipun tidak ada pemanas yang digunakan. Evaluasi peristiwa ini dan kembangkan solusi penjelasannya berdasarkan Hukum I Termodinamika!',
        'kunciJawaban':
            'Walaupun tidak ada pemanas, suhu gas tetap naik karena pada kompresor lingkungan melakukan kerja pada gas. Berdasarkan Hukum I Termodinamika (ΔU = Q − W), jika Q ≈ 0 dan gas ditekan (W bernilai negatif), maka ΔU menjadi positif, artinya energi dalam bertambah. Kenaikan energi dalam inilah yang menyebabkan suhu gas meningkat.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      }, 
      {
        'isiSoal':
            'Sebuah perusahaan mengklaim telah menciptakan mesin dengan efisiensi 100% (tidak ada kalor yang terbuang). Evaluasilah klaim tersebut berdasarkan Hukum II Termodinamika!',
        'kunciJawaban':
            'Klaim bahwa ada mesin dengan efisiensi 100% itu tidak mungkin benar. Menurut Hukum II Termodinamika, tidak ada mesin panas yang bisa mengubah seluruh kalor menjadi usaha. Pasti selalu ada panas yang terbuang ke lingkungan. Bahkan mesin paling ideal sekalipun, yaitu mesin Carnot, efisiensinya tetap kurang dari 100%. Jadi, secara ilmiah klaim tersebut tidak dapat diterima karena melanggar hukum fisika.',
	'soalKategori': '', 
        'batasWaktuPengerjaan': 600
      },
    ],
    'isDoneMateri': false,
  },
];
