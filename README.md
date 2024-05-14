## Tentang Aplikasi
Aplikasi ini adalah sebuah platform berbasis web yang menyediakan endpoint untuk Website Sistem Informasi Objek Wisata Curug Pletuk. Dikembangkan oleh Tangguh Widodo.

## Framework 
-   Ruby on Rails => Framework Ruby

## Database
-   PostgreSQL => Database System

## Tools
-   VS Code => Code Editor
-   Puma => Simulasi Web Server

## Other Library
-   Bcrypt => Menyediakan fungsionalitas untuk hashing password dan memverifikasi password menggunakan algoritma BCrypt.
-   JSON Web Token => Memberikan keamanan data pada authorization token.

## Direktori Utama "app/"
-   Folder app: Folder ini berisi kode utama aplikasi, termasuk MVC (Model, View, Controller), helper, mailer, jobs, dan assets.
-   Folder bin: Folder ini berisi skrip yang dapat dieksekusi untuk mengelola dan menjalankan aplikasi, termasuk rails script yang digunakan untuk berbagai perintah Rails.
-   Folder config: Folder ini berisi semua file konfigurasi untuk aplikasi, seperti konfigurasi database (database.yml), konfigurasi lingkungan (environment.rb), dan rute (routes.rb).
-   Folder db: Folder ini berisi schema database, migrasi, dan seeders.
-   Folder lib: Folder ini berisi modul dan kode lain yang tidak masuk ke dalam kategori model, view, atau controller.
-   Folder log: Folder ini berisi file log aplikasi, termasuk log untuk lingkungan development, test, dan production.
-   Folder public: Direktori publik yang dapat diakses langsung dari web server. File-file di sini dapat diakses oleh pengguna.
-   Folder storage: Berisi file yang dihasilkan oleh aplikasi, seperti file log, cache, dan file-file yang diunggah.
-   Folder test: Folder ini berisi tes untuk aplikasi, termasuk tes unit, tes fungsional, dan tes integrasi. Struktur tes mengikuti struktur yang mirip dengan direktori app.
-   Folder tmp: Folder ini digunakan untuk menyimpan file sementara yang diperlukan oleh aplikasi selama eksekusi, seperti cache atau file proses sementara.
-   Folder vendor: Folder ini berisi gem pihak ketiga yang tidak didistribusikan melalui Rubygems.org, serta aset pihak ketiga.

## Direktori Tambahan

-   File .gitattributes: File yang menentukan atribut untuk jalur proyek dalam Git.
-   File .ruby-version: File ini berisi versi Ruby yang digunakan oleh proyek. Tools seperti rbenv atau RVM membaca file ini untuk mengatur versi Ruby yang tepat saat mengerjakan proyek.
-   File config-ru: File ini berisi konfigurasi untuk Rack, yang merupakan antarmuka antara server web dan aplikasi Ruby. File ini digunakan untuk memulai aplikasi Rails dan mendefinisikan bagaimana permintaan web harus ditangani.
-   File Dockerfile: File ini berisi instruksi untuk Docker untuk membangun gambar (image) Docker dari aplikasi. Ini mendefinisikan lingkungan yang diperlukan untuk menjalankan aplikasi, termasuk sistem operasi, versi Ruby, dependensi, dan konfigurasi lainnya.
-   File Gemfile: File ini mendefinisikan semua gem (pustaka Ruby) yang diperlukan oleh aplikasi. Ini termasuk gem untuk Rails sendiri, serta gem lain untuk berbagai fungsionalitas tambahan yang dibutuhkan oleh aplikasi.
-   File Gemfile.lock: File ini dibuat oleh Bundler, dan mencatat versi pasti dari setiap gem yang diinstal. Ini memastikan bahwa semua orang yang mengerjakan proyek menggunakan versi yang sama dari setiap gem, yang membantu mencegah masalah yang disebabkan oleh perubahan versi gem.
-   File Rakefile: File ini berisi definisi tugas-tugas Rake, yang merupakan alat build automation dalam Ruby. Tugas-tugas ini bisa digunakan untuk berbagai tujuan, seperti migrasi basis data, pengujian, atau tugas-tugas otomatisasi lainnya yang diperlukan oleh aplikasi.
-   File README.md: File ini berisi penjelasan tentang proyek.

## Endpoint Aplikasi
### Register/Sign up
-   POST Create User: /auth/signup
-   POST Resend Token Verification: /auth/resend
-   GET Token Verification: /verification-account/?token_verification=(token verification)
-   POST Reset Password: /forgot_password
-   PATCH Reset Password: /update_password/(token reset password)
-   GET Check Token Reset Password: /check_reset_token?reset_password_token=(token reset password)
### Session
-   POST Login: /auth/login
-   DELETE Logout: /auth/logout
-   GET Current User: /me
-   GET All Users: /users
-   GET User by ID: /users/:id_user
### Profile
-   PUT Update Profile: /users/update_profile
-   PUT Update Profile (Password Only): /users/update_password
-   PUT Remove Avatar: /users/remove_avatar
-   DELETE Delete User: /users/destroy
### Order
-   GET All Orders: /orders
-   GET Order by ID Order: /orders/:id_order
-   GET Order by ID User: /check_user_order
-   POST Create Order: /orders
-   POST Checked Payment by Admin: /orders/:id_order/check_order 
### Product
-   GET All Products: /products
-   GET Product by ID Product: /products/:id_product
-   POST Create Product: /products
-   PUT Edit Product: /products/update/:id_product
-   PUT Remove Product Image: /products/delete_image/:id_product
-   DELETE Delete Product: /products/destroy/:id_product
### Notification
-   GET All Notification by User: /notifications