-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 26, 2024 at 04:44 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dbkasir`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `FindCustomersWithPurchase` ()   BEGIN
    SELECT
        customer.idCustomer,
        customer.namaCustomer,
        SUM(log_penjualan.hargaBarang * log_penjualan.jumlah) AS totalBelanja
    FROM
        customer
    LEFT JOIN log_penjualan ON customer.idCustomer = log_penjualan.idCustomer
    GROUP BY
        customer.idCustomer,
        customer.namaCustomer
    ORDER BY
    	totalBelanja DESC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `barangbeli`
--

CREATE TABLE `barangbeli` (
  `idBarang` int(11) NOT NULL,
  `idCustomer` int(11) NOT NULL,
  `namaCustomer` varchar(20) NOT NULL,
  `namaBarang` varchar(25) NOT NULL,
  `kategori` varchar(10) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `hargaBarang` decimal(11,2) NOT NULL,
  `subtotal` decimal(11,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barangbeli`
--

INSERT INTO `barangbeli` (`idBarang`, `idCustomer`, `namaCustomer`, `namaBarang`, `kategori`, `jumlah`, `hargaBarang`, `subtotal`) VALUES
(17, 17, 'Rafa', 'Beras', 'Sembako', 10, 23000.00, 230000.00);

--
-- Triggers `barangbeli`
--
DELIMITER $$
CREATE TRIGGER `after_insert_penjualan` AFTER INSERT ON `barangbeli` FOR EACH ROW BEGIN
	DECLARE idCust INT;
    DECLARE namaCust VARCHAR(30);
    DECLARE kotaCust VARCHAR(30);
    DECLARE namaBrg VARCHAR(30);
    DECLARE jumlahBrg INT;
    DECLARE hargaBrg DECIMAL(10, 2);
    DECLARE total DECIMAL(10, 2);
    
    -- Mengambil data dari tabel barangbeli
    SET namaBrg = NEW.namaBarang;
    SET jumlahBrg = NEW.jumlah;
    SET hargaBrg = NEW.hargaBarang;

    -- Mengambil data pelanggan yang sesuai dengan ID pelanggan yang terkait dengan pembelian
    SELECT idCustomer, namaCustomer, kota INTO idCust, namaCust, kotaCust
    FROM customer
    WHERE idCustomer = NEW.idCustomer;

    -- Menghitung total pembelian
    SET total = jumlahBrg * hargaBrg;

    -- Memasukkan informasi pembelian ke dalam tabel catatan_penjualan
    INSERT INTO log_penjualan (idCustomer, namaCustomer, kota, namaBarang, jumlah, hargaBarang, total)
    VALUES (idCust, namaCust, kotaCust, namaBrg, jumlahBrg, hargaBrg, total);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `idCustomer` int(11) NOT NULL,
  `namaCustomer` varchar(20) NOT NULL,
  `noTelp` varchar(10) NOT NULL,
  `kota` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`idCustomer`, `namaCustomer`, `noTelp`, `kota`) VALUES
(13, 'Konglomerat', '0812222222', 'IKN'),
(14, 'Saia', '081XXXXXXX', 'Mewah'),
(15, 'Thomas', '081XXXXXXX', 'Mewah'),
(16, 'Orang biasa', '0812345678', 'Kudus'),
(17, 'Rafa', '081XXXXXXX', 'Lampung'),
(18, 'Orang biasa', '', 'IKN');

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `log_penjualan`
--

CREATE TABLE `log_penjualan` (
  `id` int(11) NOT NULL,
  `idCustomer` int(11) NOT NULL,
  `namaCustomer` varchar(30) NOT NULL,
  `kota` varchar(30) NOT NULL,
  `namaBarang` varchar(30) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `hargaBarang` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_penjualan`
--

INSERT INTO `log_penjualan` (`id`, `idCustomer`, `namaCustomer`, `kota`, `namaBarang`, `jumlah`, `hargaBarang`, `total`) VALUES
(6, 11, 'Sendiri', 'Kudus', 'Cabe', 12, 40000.00, 480000.00),
(7, 11, 'Sendiri', 'Kudus', 'Bayam', 20, 5000.00, 100000.00),
(8, 11, 'Sendiri', 'Kudus', 'Cabe', 12, 40000.00, 480000.00),
(9, 12, 'Thomas', 'Peradaban', 'Beras', 10, 23000.00, 230000.00),
(10, 12, 'Thomas', 'Peradaban', 'Gula', 5, 12000.00, 60000.00),
(11, 12, 'Thomas', 'Peradaban', 'Jamur', 2, 10000.00, 20000.00),
(12, 12, 'Thomas', 'Peradaban', 'Ayam', 1, 30000.00, 30000.00),
(13, 12, 'Thomas', 'Peradaban', 'Cabe', 1, 40000.00, 40000.00),
(14, 12, 'Thomas', 'Peradaban', 'Bayam', 2, 5000.00, 10000.00),
(15, 13, 'Konglomerat', 'IKN', 'Beras', 100, 23000.00, 2300000.00),
(16, 13, 'Konglomerat', 'IKN', 'Gula', 50, 12000.00, 600000.00),
(17, 13, 'Konglomerat', 'IKN', 'Jamur', 20, 10000.00, 200000.00),
(18, 13, 'Konglomerat', 'IKN', 'Ayam', 12, 30000.00, 360000.00),
(19, 13, 'Konglomerat', 'IKN', 'Cabe', 12, 40000.00, 480000.00),
(20, 13, 'Konglomerat', 'IKN', 'Bayam', 20, 5000.00, 100000.00),
(21, 16, 'Orang biasa', 'Kudus', 'Beras', 100, 23000.00, 2300000.00),
(22, 16, 'Orang biasa', 'Kudus', 'Gula', 50, 12000.00, 600000.00),
(23, 16, 'Orang biasa', 'Kudus', 'Jamur', 20, 10000.00, 200000.00),
(24, 16, 'Orang biasa', 'Kudus', 'Ayam', 12, 30000.00, 360000.00),
(25, 16, 'Orang biasa', 'Kudus', 'Gula', 50, 12000.00, 600000.00),
(26, 16, 'Orang biasa', 'Kudus', 'Ayam', 12, 30000.00, 360000.00),
(27, 16, 'Orang biasa', 'Kudus', 'Cabe', 12, 40000.00, 480000.00),
(28, 17, 'Rafa', 'Lampung', 'Beras', 10, 23000.00, 230000.00);

-- --------------------------------------------------------

--
-- Stand-in structure for view `nota`
-- (See below for the actual view)
--
CREATE TABLE `nota` (
`idBarang` int(11)
,`namaBarang` varchar(25)
,`jumlah` int(11)
,`hargaBarang` decimal(11,2)
,`subtotal` decimal(11,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `pembayaran`
--

CREATE TABLE `pembayaran` (
  `idPembayaran` int(11) NOT NULL,
  `total_harga` decimal(10,2) DEFAULT NULL,
  `tanggal_pembelian` timestamp NOT NULL DEFAULT current_timestamp(),
  `namaCustomer` varchar(20) DEFAULT NULL,
  `noTelp` varchar(10) NOT NULL,
  `kota` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pembayaran`
--

INSERT INTO `pembayaran` (`idPembayaran`, `total_harga`, `tanggal_pembelian`, `namaCustomer`, `noTelp`, `kota`) VALUES
(2, 823000.00, '2024-02-21 14:17:56', 'Sendiri', '081XXXXXXX', 'IKN'),
(3, 823000.00, '2024-02-21 14:23:41', 'Sendiri', '081XXXXXXX', 'IKN'),
(4, 823000.00, '2024-02-21 14:23:44', 'Sendiri', '081XXXXXXX', 'IKN'),
(5, 823000.00, '2024-02-21 14:26:02', 'Sendiri', '081XXXXXXX', 'IKN'),
(6, 643000.00, '2024-02-21 15:35:58', 'Sendiri', '081XXXXXXX', 'IKN'),
(7, 2300000.00, '2024-02-22 10:05:50', 'Sendiri', '081XXXXXXX', 'Kudus'),
(8, 2300000.00, '2024-02-22 10:06:00', 'Sendiri', '081XXXXXXX', 'Kudus'),
(9, 4040000.00, '2024-02-22 10:38:13', 'Konglomerat', '0812222222', 'IKN'),
(10, 3460000.00, '2024-02-22 13:09:39', 'Orang biasa', '0812345678', 'Kudus'),
(11, 3460000.00, '2024-02-22 13:09:42', 'Orang biasa', '0812345678', 'Kudus'),
(12, 0.00, '2024-02-22 14:33:04', 'Orang biasa', '0812345678', 'Kudus');

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

CREATE TABLE `stock` (
  `idBarang` int(11) NOT NULL,
  `namaBarang` varchar(25) NOT NULL,
  `kategori` varchar(10) NOT NULL,
  `stock` int(11) NOT NULL,
  `hargaBarang` decimal(11,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`idBarang`, `namaBarang`, `kategori`, `stock`, `hargaBarang`) VALUES
(17, 'Beras', 'Sembako', 100, 23000.00),
(18, 'Gula', 'Sembako', 50, 12000.00),
(19, 'Jamur', 'Sayur', 20, 10000.00),
(20, 'Ayam', 'Daging', 12, 30000.00),
(21, 'Cabe', 'Bumbu', 12, 40000.00),
(22, 'Bayam', 'Sayur', 20, 5000.00);

-- --------------------------------------------------------

--
-- Stand-in structure for view `total_subtotal`
-- (See below for the actual view)
--
CREATE TABLE `total_subtotal` (
`idBarang` int(11)
,`total_subtotal` decimal(33,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_pelanggan`
-- (See below for the actual view)
--
CREATE TABLE `view_pelanggan` (
`idCustomer` int(11)
,`namaCustomer` varchar(20)
,`noTelp` varchar(10)
,`kota` varchar(10)
);

-- --------------------------------------------------------

--
-- Structure for view `nota`
--
DROP TABLE IF EXISTS `nota`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `nota`  AS SELECT `barangbeli`.`idBarang` AS `idBarang`, `barangbeli`.`namaBarang` AS `namaBarang`, `barangbeli`.`jumlah` AS `jumlah`, `barangbeli`.`hargaBarang` AS `hargaBarang`, `barangbeli`.`subtotal` AS `subtotal` FROM `barangbeli` GROUP BY `barangbeli`.`idBarang` ;

-- --------------------------------------------------------

--
-- Structure for view `total_subtotal`
--
DROP TABLE IF EXISTS `total_subtotal`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `total_subtotal`  AS SELECT `barangbeli`.`idBarang` AS `idBarang`, sum(`barangbeli`.`subtotal`) AS `total_subtotal` FROM `barangbeli` ;

-- --------------------------------------------------------

--
-- Structure for view `view_pelanggan`
--
DROP TABLE IF EXISTS `view_pelanggan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_pelanggan`  AS SELECT `customer`.`idCustomer` AS `idCustomer`, `customer`.`namaCustomer` AS `namaCustomer`, `customer`.`noTelp` AS `noTelp`, `customer`.`kota` AS `kota` FROM `customer` ORDER BY `customer`.`idCustomer` DESC LIMIT 0, 1 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `barangbeli`
--
ALTER TABLE `barangbeli`
  ADD PRIMARY KEY (`idBarang`),
  ADD KEY `hargaBarang` (`hargaBarang`),
  ADD KEY `kategori` (`kategori`),
  ADD KEY `namaBarang` (`namaBarang`),
  ADD KEY `idBarang` (`idBarang`),
  ADD KEY `hargaBarang_2` (`hargaBarang`),
  ADD KEY `idCustomer` (`idCustomer`),
  ADD KEY `namaCustomer` (`namaCustomer`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`idCustomer`),
  ADD KEY `namaCustomer` (`namaCustomer`),
  ADD KEY `noTelp` (`noTelp`),
  ADD KEY `kota` (`kota`);

--
-- Indexes for table `login`
--
ALTER TABLE `login`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `log_penjualan`
--
ALTER TABLE `log_penjualan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD PRIMARY KEY (`idPembayaran`);

--
-- Indexes for table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`idBarang`),
  ADD KEY `namaBarang` (`namaBarang`),
  ADD KEY `kategori` (`kategori`),
  ADD KEY `stock` (`stock`),
  ADD KEY `hargaBarang` (`hargaBarang`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `idCustomer` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `login`
--
ALTER TABLE `login`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `log_penjualan`
--
ALTER TABLE `log_penjualan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `pembayaran`
--
ALTER TABLE `pembayaran`
  MODIFY `idPembayaran` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `stock`
--
ALTER TABLE `stock`
  MODIFY `idBarang` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `barangbeli`
--
ALTER TABLE `barangbeli`
  ADD CONSTRAINT `barangbeli_ibfk_3` FOREIGN KEY (`kategori`) REFERENCES `stock` (`kategori`),
  ADD CONSTRAINT `barangbeli_ibfk_4` FOREIGN KEY (`namaBarang`) REFERENCES `stock` (`namaBarang`),
  ADD CONSTRAINT `barangbeli_ibfk_5` FOREIGN KEY (`idBarang`) REFERENCES `stock` (`idBarang`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
