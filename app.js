const express = require('express');
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const session = require('express-session');
const ejs = require('ejs');
const mysql = require('mysql');
const app = express();
const Report = require( 'fluentReports' ).Report;

app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));
app.use(session({ secret: 'secret-key', resave: true, saveUninitialized: true }));
app.use(passport.initialize());
app.use(passport.session());
app.set('view engine', 'ejs');

const connection = mysql.createConnection({
  host: '127.0.0.1',
  user: 'root',
  password: '',
  database: 'dbkasir'
});

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL:', err);
    return;
  }
  console.log('Connected to MySQL');
});

const users = [
  { id: 1, username: 'user', password: 'user' },
  { id: 2, username: 'user2', password: 'password2' },
];

app.get('/public/floating.js', (req, res) => {
  res.sendFile(__dirname + '/public/floating.js', { 
    headers: {
      'Content-Type': 'application/javascript' // Atur tipe MIME menjadi JavaScript
    }
  });
});

passport.use(new LocalStrategy(
  (username, password, done) => {
    const user = users.find(u => u.username === username && u.password === password);
    return user ? done(null, user) : done(null, false, { message: 'Incorrect username or password' });
  }
));

passport.serializeUser((user, done) => done(null, user.id));

passport.deserializeUser((id, done) => {
  const user = users.find(u => u.id === id);
  done(null, user);
});

app.get('/', (req, res) => res.send('<h1>Welcome to the Login Page</h1>'));

app.get('/login', (req, res) => res.render('login'));

app.post('/login', passport.authenticate('local', { successRedirect: '/stock', failureRedirect: '/login' }));


app.get('/boot', (req, res) => res.render('boot',  { user: req.user} ));



//============================ Halaman Shop ===============================//
// app.get('/shop', (req, res) => {
//   if (req.isAuthenticated()) {
//     connection.query('SELECT * FROM barangbeli', (error, results) => {
//     // Menghitung total harga barang
//     let totalHarga = 0;
//     barangbeli.forEach(jumlah => {
//       totalHarga += jumlah.hargaBarang;
//     });
//     console.log("Harga Total :"+totalHarga);
//       res.render('shop', { user: req.user, barangbeli: results });
//     });
//   } else {
//     res.redirect('/login');
//   }
//   // Menghitung total harga barang
// });


app.get('/shop', (req, res) => {
  if (req.isAuthenticated()) {
    connection.query('SELECT * FROM barangbeli',  (error, results) => {
      if (error) {
        console.error('Error fetching barangbeli:', error);
        res.status(500).send('Internal Server Error');
        return;
      }
      
      // Menghitung total harga barang
      let totalHarga = 0;
      results.forEach(jumlah => {
        // Menggunakan parseFloat untuk mengonversi string ke float
        let subtotalBarang = parseFloat(jumlah.hargaBarang) * parseFloat(jumlah.jumlah);
        totalHarga += subtotalBarang;
      });
      console.log("Harga Total :" + totalHarga);

      // Mengambil data customer
      connection.query('SELECT * FROM view_pelanggan', (error, customerResults) => {
        if (error) {
          console.error('Error fetching customers:', error);
          res.status(500).send('Internal Server Error');
          return;
        }
        
        res.render('shop', { user: req.user, barangbeli: results, totalHarga: totalHarga, view_pelanggan: customerResults });
      });
    });
  } else {
    res.redirect('/login');
  }
});



app.get('/log', (req, res) => {
  connection.query('SELECT * FROM log_penjualan', (error, results) => {

  res.render('log.ejs', { user: req.user, log_penjualan: results });
  });
});



// ===================================PEMBAYARAN
app.post('/pembayaran', (req, res) => {
  const { totalHarga, namaCustomer, noTelp, kotaCustomer }  = req.body;
  connection.query(
    'INSERT INTO pembayaran ( total_harga, namaCustomer, noTelp, kota) VALUES (?, ?, ?, ?)',
    [totalHarga, namaCustomer, noTelp, kotaCustomer ],
    (error, results) =>{
      if (error) {
      console.error('Error fetching customers:', error);
      res.status(500).send('Internal Server Error');
      return;
    }
      res.redirect('shop');
    }
  )
});

app.get('/bayar', (req, res) => {
  connection.query('SELECT * FROM view_pelanggan', (error, results) => {
    if (error) {
      console.error('Error fetching customers:', error);
      res.status(500).send('Internal Server Error');
      return;
    }

    connection.query('SELECT * FROM total_subtotal', (error, total) => {
      if (error) {
        console.error('Error fetching total_subtotal:', error);
        res.status(500).send('Internal Server Error');
        return;
      }

      // Render halaman setelah kedua query selesai dieksekusi
      res.render('bayar.ejs', { user: req.user, view_pelanggan: results, total_subtotal: total });
    });
  });
});

// app.js atau tempat Anda mendefinisikan route

app.get('/nota', (req, res) => {

    // Lakukan query untuk mengambil data dari view
    connection.query('SELECT * FROM nota', (err, rows) => {
      if (err) { 

      // Proses data transaksi di sini
      console.log('Data transaksi:', rows);
    }
    
      connection.query('SELECT * FROM total_subtotal', (error, total) => {
      if (error) {
        console.error('Error fetching total_subtotal:', error);
        res.status(500).send('Internal Server Error');
        return;
      }

        connection.query('SELECT * FROM view_pelanggan', (error, cust) => {
        if (error) {
          console.error('Error fetching total_subtotal:', error);
          res.status(500).send('Internal Server Error');
          return;
      }
      // Render file nota.ejs dengan meneruskan data transaksi
      res.render('nota.ejs', { user: req.user, nota: rows, total_subtotal: total, view_pelanggan: cust });
      });
    });
  });
});


app.get('/pelanggan', (req, res) => {
  res.render('pelanggan.ejs');
});


app.delete('/deletePelanggan/:id', (req, res) => {
  const customerId = req.params.id;
  console.log(`Menghapus pelanggan dengan ID: ${customerId}`);
  // Di sini Anda tidak perlu menghapus data dari database
  // Cukup tanggapi permintaan dengan status yang sesuai
  res.sendStatus(200);
});

// app.post('/deletePelanggan/:id', (req, res) => {
//   // Ketik code untuk menghapus data di database
//   connection.query(
//     'DELETE FROM customer WHERE idCustomer = ?',
//     [req.params.id],
//     (error, results) => {
//       if (error) {
//           console.error('Error fetching total_subtotal:', error);
//           res.status(500).send('Internal Server Error');
//           return;
//       res.redirect('/shop');
//     }
// });
// });


app.post('/createInfoCustomer', (req, res) => {
  const { namaCustomer, noTelp, kotaCustomer }  = req.body;
  connection.query(
    'INSERT INTO customer (namaCustomer, noTelp, kota) VALUES (?, ?, ?)',
    [namaCustomer, noTelp, kotaCustomer ],
    (error, results) => {
      res.redirect('shop');
    }
  );
});


app.get('/new', (req, res) => {

  connection.query('SELECT * FROM stock', (error, results) => {


  res.render('new.ejs', { user: req.user, stock: results });
  });
    
  });

app.get('/beli/:id', (req, res) => {
  connection.query('SELECT idCustomer, namaCustomer FROM view_pelanggan', (error, hasil, fields) => {
    if (error) {
      console.error('Error fetching customers:', error);
      res.status(500).send('Internal Server Error');
      return;
    }

    // Lakukan pemrosesan data atau tampilkan data
    hasil.forEach(row => {
      console.log('Id:', row.idCustomer, '| Nama:', row.namaCustomer);
    });

    connection.query(
      'SELECT * FROM stock WHERE idBarang = ?',
      [req.params.id],
      (error, results) => {
        if (error) {
          console.error('Error fetching stock:', error);
          res.status(500).send('Internal Server Error');
          return;
        }
        res.render('beli.ejs', { stok: results[0] , hasil: hasil});
      }
    );
  });
});


app.post('/delete/:id', (req, res) => {
  // Ketik code untuk menghapus data di database
  connection.query(
    'DELETE FROM barangbeli WHERE idBarang = ?',
    [req.params.id],
    (error, results) => {
      res.redirect('/shop');
    }
  
    )
});

app.get('/edit/:id', (req, res) => {
  connection.query(
    'SELECT * FROM barangbeli WHERE idBarang = ?',
    [req.params.id],
    (error, results) =>{
      res.render('edit.ejs', {jumlah: results[0]});
    }
  )
});

app.post('/update/:id', (req, res) => {
  // Ambil hargaBarang dari database berdasarkan idBarang
  connection.query(
    'SELECT hargaBarang FROM barangbeli WHERE idBarang = ?',
    [req.params.id],
    (error, results) => {
      if (error) {
        console.log("Error:", error);
        res.status(500).send("Terjadi kesalahan saat mengambil data harga barang.");
        return;
      }
      // Dapatkan hargaBarang dari hasil query
      const hargaBarang = results[0].hargaBarang;

      // Hitung subtotal
      const subtotal = hargaBarang * req.body.jumlah;

      // Lakukan update data barangbeli dengan subtotal baru
      connection.query(
        'UPDATE barangbeli SET jumlah = ?, subtotal = ? WHERE idBarang = ?',
        [req.body.jumlah, subtotal, req.params.id],
        (error, results) => {
          if (error) {
            console.log("Error:", error);
            res.status(500).send("Terjadi kesalahan saat memperbarui data.");
          } else {
            res.redirect('/shop');
          }
        }
      );
    }
  );
});




  app.post('/tambahBelanja/:id', (req, res) => {
  const { idBarang, idCustomer, namaCustomer, namaBarang, kategori, hargaBarang, jumlah}  = req.body;
  const subtotal = hargaBarang * jumlah; // Hitung subtotal

  connection.query(
  'INSERT INTO barangbeli (idBarang, idCustomer, namaCustomer, namaBarang, kategori, hargaBarang, jumlah, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
  [idBarang, idCustomer, namaCustomer, namaBarang, kategori, hargaBarang, jumlah, subtotal],
  (error, results) =>{ 
      if (error) {
        // Tangani kesalahan jika ada
        console.log("Error:", error);
        res.status(500).send("Maaf anda menambahkan 2 barang yang sama ke dalam keranjang!.");
      } else {
        // Redirect ke halaman '/stock' setelah berhasil memperbarui data
        res.redirect('/shop');
      }
    }
  );
  });

  app.get('/loyal', (req, res) => {
  connection.query('CALL FindCustomersWithPurchase()', (error, results, fields) => {
    if (error) {
    console.error('Error calling stored procedure:', error);
    return;
  }
  console.log('Hasil stored procedure:', results);

  res.render('loyal.ejs', { user: req.user, data: results[0] });
  });
});






//======================= Halaman Stock ===========================//
app.get('/stock', (req, res) => {
  connection.query('SELECT * FROM stock', (error, results) => {

  res.render('stock.ejs', { user: req.user, stock: results });
  });
});

app.get('/newstock', (req, res) => {
  res.render('newstock.ejs');
});

app.post('/createstock', (req, res) => {
  const { itemName, itemCategory, itemPrice, itemStock }  = req.body;
  connection.query(
    'INSERT INTO stock (namaBarang, kategori, hargaBarang, stock) VALUES (?, ?, ?, ?)',
    [itemName, itemCategory, itemPrice, itemStock ],
    (error, results) => {
      res.redirect('stock');
    }
  );
});

app.post('/deletestock/:id', (req, res) => {
  // Ketik code untuk menghapus data di database
  connection.query(
    'DELETE FROM stock WHERE idBarang = ?',
    [req.params.id],
    (error, results) => {
      res.redirect('/stock');
    }
    
    )
});

app.get('/editstock/:id', (req, res) => {
  connection.query(
    'SELECT * FROM stock WHERE idBarang = ?',
    [req.params.id],
    (error, results) =>{
      res.render('editstock.ejs', {stok: results[0]});
    }
  )
});

app.post('/updatestock/:id', (req, res) => {
  connection.query(
    'UPDATE stock SET namaBarang = ?, stock = ?, kategori = ?, hargaBarang = ? WHERE idBarang = ?',
    [req.body.namaBarang, req.body.stock, req.body.kategori, req.body.hargaBarang, req.params.id],
    (error, results) =>{ 
      if (error) {
        // Tangani kesalahan jika ada
        console.log("Error:", error);
        res.status(500).send("Terjadi kesalahan saat memperbarui data.");
      } else {
        // Redirect ke halaman '/stock' setelah berhasil memperbarui data
        res.redirect('/stock');
      }
    }
  );
  });




// app.post('/tambahBelanja/:id', (req, res) => {
//   const { idBarang, namaBarang, kategori, hargaBarang, jumlah}  = req.body;
//   connection.query(
//   'INSERT INTO barangbeli (idBarang, namaBarang, kategori, hargaBarang, jumlah) VALUES (?, ?, ?, ?, ?)',
//   [idBarang, namaBarang, kategori, hargaBarang, jumlah],
//   (error, results) =>{ 
//       if (error) {
//         // Tangani kesalahan jika ada
//         console.log("Error:", error);
//         res.status(500).send("Terjadi kesalahan saat memperbarui data.");
//       } else {
//         // Redirect ke halaman '/stock' setelah berhasil memperbarui data
//         res.redirect('/shop');
//       }
//     }
//   );
//   });







app.get('/logout', (req, res) => {
  req.logout();
  res.redirect('/');
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Server is running on port ${PORT}`));
