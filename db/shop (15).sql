-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 16, 2024 at 11:06 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `shop`
--

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `A_id` int(11) NOT NULL,
  `E_id` int(11) NOT NULL,
  `A_date` date NOT NULL,
  `A_status` int(11) NOT NULL DEFAULT 0,
  `A_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `R_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`A_id`, `E_id`, `A_date`, `A_status`, `A_time`, `R_id`) VALUES
(1, 3, '2024-04-02', 1, '2024-04-02 06:52:05', 0),
(2, 5, '2024-04-09', 1, '2024-04-09 09:24:09', 0),
(3, 4, '2024-04-09', 2, '2024-04-09 09:24:09', 0),
(4, 3, '2024-04-09', 2, '2024-04-09 09:24:09', 0),
(5, 5, '2024-04-08', 1, '2024-04-09 10:16:29', 0),
(6, 4, '2024-04-08', 1, '2024-04-09 10:16:29', 0),
(7, 3, '2024-04-08', 1, '2024-04-09 10:16:29', 0),
(8, 5, '2024-04-01', 2, '2024-04-09 10:16:37', 0),
(9, 4, '2024-04-01', 1, '2024-04-09 10:16:37', 0),
(10, 3, '2024-04-01', 2, '2024-04-09 10:16:37', 0),
(11, 5, '2024-04-03', 2, '2024-04-09 10:16:46', 0),
(12, 4, '2024-04-03', 2, '2024-04-09 10:16:46', 0),
(13, 3, '2024-04-03', 1, '2024-04-09 10:16:46', 0),
(14, 5, '2024-04-07', 2, '2024-04-09 10:16:49', 0),
(15, 4, '2024-04-07', 2, '2024-04-09 10:16:49', 0),
(16, 3, '2024-04-07', 2, '2024-04-09 10:16:50', 0),
(17, 5, '2024-04-06', 2, '2024-04-09 10:16:53', 0),
(18, 4, '2024-04-06', 2, '2024-04-09 10:16:53', 0),
(19, 3, '2024-04-06', 2, '2024-04-09 10:16:53', 0),
(20, 5, '2024-04-05', 2, '2024-04-09 10:16:57', 0),
(21, 4, '2024-04-05', 1, '2024-04-09 10:16:57', 0),
(22, 3, '2024-04-05', 2, '2024-04-09 10:16:57', 0),
(23, 5, '2024-04-10', 2, '2024-04-10 15:15:05', 0),
(24, 4, '2024-04-10', 1, '2024-04-10 15:15:05', 0),
(25, 3, '2024-04-10', 2, '2024-04-10 15:15:05', 0);

-- --------------------------------------------------------

--
-- Table structure for table `bill`
--

CREATE TABLE `bill` (
  `B_id` bigint(20) NOT NULL,
  `P_id` int(5) NOT NULL,
  `B_qty` int(11) NOT NULL,
  `B_rate` double NOT NULL,
  `B_tax` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bill`
--

INSERT INTO `bill` (`B_id`, `P_id`, `B_qty`, `B_rate`, `B_tax`) VALUES
(14, 13, 1, 204, 18),
(14, 1, 3, 200, 18),
(15, 1, 5, 200, 18),
(15, 13, 2, 204, 18),
(16, 13, 7, 204, 18),
(16, 13, 5, 204, 18);

-- --------------------------------------------------------

--
-- Table structure for table `billdetails`
--

CREATE TABLE `billdetails` (
  `B_id` int(11) NOT NULL,
  `B_by` int(11) NOT NULL,
  `B_date` datetime NOT NULL DEFAULT current_timestamp(),
  `B_status` int(11) NOT NULL DEFAULT 0,
  `B_refno` int(11) NOT NULL,
  `B_delivery` int(11) NOT NULL DEFAULT 0,
  `B_discount` double NOT NULL,
  `B_totalbillamt` double NOT NULL,
  `B_payMode` varchar(15) NOT NULL,
  `B_totalcgst` double NOT NULL,
  `B_totalsgst` double NOT NULL,
  `B_totaligst` double NOT NULL,
  `B_payedamt` double NOT NULL,
  `B_dueamt` double NOT NULL,
  `B_consigneenedded` int(1) NOT NULL,
  `B_consigneeaddress` varchar(500) DEFAULT NULL,
  `B_taxabletotalamt` double NOT NULL,
  `B_billeraddress` varchar(600) NOT NULL,
  `B_statecode` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `billdetails`
--

INSERT INTO `billdetails` (`B_id`, `B_by`, `B_date`, `B_status`, `B_refno`, `B_delivery`, `B_discount`, `B_totalbillamt`, `B_payMode`, `B_totalcgst`, `B_totalsgst`, `B_totaligst`, `B_payedamt`, `B_dueamt`, `B_consigneenedded`, `B_consigneeaddress`, `B_taxabletotalamt`, `B_billeraddress`, `B_statecode`) VALUES
(14, 2, '2024-04-15 22:02:19', 2, 19, 0, 0, 804, '1', 72.36, 72.36, 0, 100, 704, 2, '', 659.28, 'hahah@mail.com#32#birla#9615785569##32BFNPT6605K1Z3#kollam\nkerala\n', 32),
(15, 2, '2024-04-15 22:02:33', 2, 18, 0, 0, 1408, '1', 0, 0, 253.44, 0, 1408, 2, '', 1154.56, 'alex@gmail.com#28#tata#9656485578##32BFNPT6605K1Z1#Rajakkad\nidukki 685566', 28),
(16, 2, '2024-04-15 22:05:02', 1, 20, 0, 0, 2448, '3', 0, 0, 440.64, 0, 2448, 2, '', 2007.36, 'alex@gmail.com#28#tata#9656485578##32BFNPT6605K1Z1#Rajakkad\nidukki 685566', 28);

-- --------------------------------------------------------

--
-- Table structure for table `collection`
--

CREATE TABLE `collection` (
  `C_id` int(11) NOT NULL,
  `S_id` int(11) NOT NULL,
  `E_id` int(11) NOT NULL,
  `C_amt` double NOT NULL,
  `C_remarks` varchar(200) NOT NULL,
  `C_date` datetime NOT NULL DEFAULT current_timestamp(),
  `C_method` varchar(5) DEFAULT NULL,
  `C_status` int(1) NOT NULL DEFAULT 0,
  `C_approveby` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `damageentrydeatils`
--

CREATE TABLE `damageentrydeatils` (
  `Damageid` int(11) NOT NULL,
  `Emp_id` int(11) NOT NULL,
  `time` datetime NOT NULL DEFAULT current_timestamp(),
  `totalamt` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `damageitemdetails`
--

CREATE TABLE `damageitemdetails` (
  `Damageid` int(11) NOT NULL,
  `P_id` int(11) NOT NULL,
  `Rate` double NOT NULL,
  `Qty` int(11) NOT NULL,
  `Comment` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `device_mgmt`
--

CREATE TABLE `device_mgmt` (
  `dev_id` int(11) NOT NULL,
  `dev_num` varchar(200) NOT NULL,
  `dev_status` int(1) NOT NULL,
  `dev_time` datetime NOT NULL DEFAULT current_timestamp(),
  `dev_code` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `E_id` int(11) NOT NULL,
  `E_name` varchar(100) NOT NULL,
  `E_phn` bigint(10) NOT NULL,
  `E_email` varchar(100) NOT NULL,
  `E_address` varchar(255) NOT NULL,
  `E_pwd` varchar(50) NOT NULL,
  `E_status` int(1) NOT NULL,
  `E_type` varchar(20) NOT NULL,
  `E_designation` varchar(50) NOT NULL,
  `E_joining` datetime NOT NULL DEFAULT current_timestamp(),
  `E_accno` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`E_id`, `E_name`, `E_phn`, `E_email`, `E_address`, `E_pwd`, `E_status`, `E_type`, `E_designation`, `E_joining`, `E_accno`) VALUES
(1, 'Erics', 0, 'Admin@mail.com', '', '1234', 0, 'superadmin', '', '2024-03-25 10:03:51', NULL),
(2, 'Akhil', 9656485578, 'Akhil@mail.com', 'dfg', '1234', 0, 'superadmin', 'Sales Staff', '2024-03-25 10:03:51', NULL),
(3, 'DON', 9656485578, 'abc@mail.com', 'dgh', '1234', 1, '2', 'HR', '2024-03-25 21:45:46', NULL),
(4, 'shibukuttan New', 9696969696, 'akhilshajirkd@gmail.com', '568568', 'SHI9696', 0, '2', 'Sales Executive', '2024-04-09 11:31:46', NULL),
(5, 'New', 9497750026, 'alex@dg.fcgh', 'fgh', 'NEW0026', 0, '1', 'Sales Executive', '2024-04-09 11:32:23', 61);

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `X_id` int(11) NOT NULL,
  `X_type` varchar(30) NOT NULL,
  `X_date` datetime NOT NULL DEFAULT current_timestamp(),
  `X_Eid` int(11) NOT NULL,
  `X_amt` double NOT NULL,
  `X_remarks` varchar(300) NOT NULL,
  `X_status` int(11) NOT NULL DEFAULT 0,
  `x_approveby` int(11) DEFAULT NULL,
  `X_file` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`X_id`, `X_type`, `X_date`, `X_Eid`, `X_amt`, `X_remarks`, `X_status`, `x_approveby`, `X_file`) VALUES
(1, 'Miscellaneous', '2024-04-09 11:33:27', 5, 100, 'dfdf', 1, 2, NULL),
(2, 'Travel', '2024-04-09 11:42:10', 5, 56, 'jj', 1, 2, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `group`
--

CREATE TABLE `group` (
  `g_id` int(11) NOT NULL,
  `g_name` varchar(100) NOT NULL,
  `g_type` varchar(15) NOT NULL,
  `g_under` int(3) NOT NULL,
  `G_delete` varchar(5) NOT NULL DEFAULT 'YES'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `group`
--

INSERT INTO `group` (`g_id`, `g_name`, `g_type`, `g_under`, `G_delete`) VALUES
(1, 'BRANCH / DIVISIONS', 'ASSET', 0, 'NO'),
(2, 'CAPITAL ACCOUNT', 'ASSET', 0, 'NO'),
(3, 'CURRENT ASSETS', 'ASSET', 0, 'NO'),
(4, 'CURRENT LIABILITIES', 'LIBALITY', 0, 'NO'),
(5, 'DIRECT EXPENSES', 'EXPENCE', 0, 'NO'),
(6, 'DIRECT INCOMES', 'INCOME', 0, 'NO'),
(7, 'FIXED ASSETS', 'ASSET', 0, 'NO'),
(8, 'INDIRECT INCOMES', 'INCOME', 0, 'NO'),
(9, 'INVESTMENTS', 'ASSET', 0, 'NO'),
(10, 'LOANS (LIABILITY)', 'LIBALITY', 0, 'NO'),
(11, 'MISC. EXPENSES (ASSET)', 'ASSET', 0, 'NO'),
(12, 'PURCHASE ACCOUNTS', 'ASSET', 0, 'NO'),
(13, 'SALES ACCOUNTS', 'INCOME', 0, 'NO'),
(14, 'SUSPENSE A/C', 'ASSET', 0, 'NO'),
(15, 'BANK ACCOUNTS', 'ASSET', 3, 'NO'),
(16, 'BANK OD A/C', 'LIBALITY', 10, 'NO'),
(17, 'CASH-IN-HAND', 'ASSET', 3, 'NO'),
(18, 'DEPOSITS (ASSET)', 'ASSET', 3, 'NO'),
(19, 'DUTIES & TAXES', 'LIBALITY', 4, 'NO'),
(20, 'LOANS & ADVANCES (ASSET)', 'ASSET', 3, 'NO'),
(21, 'PROVISIONS', 'LIBALITY', 4, 'NO'),
(22, 'RESERVES & SURPLUS', 'ASSET', 2, 'NO'),
(23, 'SECURED LOANS', 'LIBALITY', 10, 'NO'),
(24, 'STOCK-IN-HAND', 'ASSET', 3, 'NO'),
(25, 'SUNDRY CREDITORS', 'LIBALITY', 4, 'NO'),
(26, 'SUNDRY DEBTORS', 'ASSET', 3, 'NO'),
(27, 'UNSECURED LOANS', 'LIBALITY', 10, 'NO'),
(32, 'ACCOUNTS RECEIVABLE', 'ASSET', 3, 'YES'),
(35, 'INDIRECT EXPENSES', 'EXPENCE', 0, 'NO');

-- --------------------------------------------------------

--
-- Table structure for table `ledger`
--

CREATE TABLE `ledger` (
  `l_id` int(11) NOT NULL,
  `l_name` varchar(100) NOT NULL,
  `l_group` int(5) NOT NULL,
  `l_fund` varchar(3) NOT NULL,
  `l_bal` double NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ledger`
--

INSERT INTO `ledger` (`l_id`, `l_name`, `l_group`, `l_fund`, `l_bal`) VALUES
(1, 'CASH', 17, 'YES', 22573.260000000002),
(2, 'UBI', 15, 'YES', 12755),
(3, 'SBI', 15, 'YES', 2392),
(4, 'SALES REVENUE', 6, 'NO', -38528.759999999995),
(5, 'INTREST RECEIVED', 8, 'NO', 0),
(6, 'SALARY', 5, 'NO', 100),
(7, 'RENT PAID', 5, 'NO', 500),
(8, 'ACCOUNTS RECEIVABLE', 32, 'NO', 0),
(50, 'PURCHASE RETURN', 12, 'NO', 0),
(51, 'PURCHASE', 12, 'NO', 0),
(55, 'SALE RETURN', 13, 'NO', 0),
(56, 'OPERATING EXPENSES', 5, 'NO', 100),
(60, 'SC/1_dfdfg', 25, 'NO', 0),
(61, 'EMP_5_New', 35, 'NO', 108.5),
(62, 'AR/4_tata', 32, 'NO', 0),
(63, 'AR/5_birla', 32, 'NO', 0);

-- --------------------------------------------------------

--
-- Table structure for table `location`
--

CREATE TABLE `location` (
  `L_id` int(11) NOT NULL,
  `A_id` int(11) NOT NULL,
  `L_lat` decimal(9,6) NOT NULL,
  `L_long` decimal(9,6) NOT NULL,
  `L_time` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order`
--

CREATE TABLE `order` (
  `O_id` bigint(50) NOT NULL,
  `P_id` int(5) NOT NULL,
  `O_qty` int(5) NOT NULL,
  `O_amt` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order`
--

INSERT INTO `order` (`O_id`, `P_id`, `O_qty`, `O_amt`) VALUES
(1, 13, 23, 204),
(2, 1, 12, 200),
(3, 13, 12, 204),
(3, 1, 4, 200),
(3, 1, 1, 200),
(4, 1, 1, 5200),
(4, 13, 10, 24),
(5, 13, 10, 203.39),
(5, 1, 1, 4406.78),
(6, 1, 1, 4406.78),
(6, 13, 10, 20.39),
(9, 1, 10, 200),
(10, 1, 1, 200),
(10, 13, 2, 204),
(11, 1, 1, 200),
(11, 13, 2, 204),
(12, 1, 1, 200),
(12, 13, 2, 204),
(13, 1, 1, 200),
(14, 1, 1, 200),
(15, 13, 1, 204),
(15, 1, 2, 200),
(16, 1, 1, 200),
(16, 13, 2, 204),
(17, 1, 1, 200),
(17, 13, 3, 204),
(18, 1, 5, 200),
(18, 13, 2, 204),
(19, 13, 1, 204),
(19, 1, 3, 200),
(20, 13, 44, 204),
(20, 13, 5, 204),
(21, 1, 23, 200);

-- --------------------------------------------------------

--
-- Table structure for table `orderdetails`
--

CREATE TABLE `orderdetails` (
  `O_id` int(11) NOT NULL,
  `E_id` int(11) NOT NULL,
  `S_id` int(11) NOT NULL,
  `O_date` datetime NOT NULL DEFAULT current_timestamp(),
  `O_cstatus` int(11) NOT NULL DEFAULT 0,
  `O_dstatus` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orderdetails`
--

INSERT INTO `orderdetails` (`O_id`, `E_id`, `S_id`, `O_date`, `O_cstatus`, `O_dstatus`) VALUES
(1, 2, 1, '2024-04-11 09:45:57', 2, 0),
(2, 2, 1, '2024-04-11 10:27:51', 2, 0),
(3, 2, 4, '2024-04-11 12:41:24', 1, 0),
(4, 2, 5, '2024-04-12 10:49:00', 1, 0),
(5, 2, 4, '2024-04-12 11:38:43', 2, 0),
(6, 2, 5, '2024-04-12 11:40:26', 2, 0),
(7, 2, 1, '2024-04-12 18:38:32', 0, 0),
(8, 2, 5, '2024-04-12 18:38:48', 0, 0),
(9, 2, 5, '2024-04-13 11:30:42', 2, 0),
(10, 2, 4, '2024-04-13 11:50:27', 2, 0),
(11, 2, 4, '2024-04-13 12:22:54', 2, 0),
(12, 2, 4, '2024-04-13 12:34:48', 2, 0),
(13, 2, 4, '2024-04-13 12:36:55', 2, 0),
(14, 2, 4, '2024-04-13 12:39:40', 2, 0),
(15, 2, 4, '2024-04-13 12:41:46', 2, 0),
(16, 2, 4, '2024-04-13 14:38:42', 2, 0),
(17, 2, 5, '2024-04-15 21:22:46', 2, 0),
(18, 2, 4, '2024-04-15 22:01:48', 2, 0),
(19, 2, 5, '2024-04-15 22:02:08', 2, 0),
(20, 2, 4, '2024-04-15 22:04:45', 1, 0),
(21, 2, 4, '2024-04-15 22:06:03', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `P_id` int(5) NOT NULL,
  `P_name` varchar(199) DEFAULT NULL,
  `P_qty` int(11) NOT NULL,
  `P_status` int(1) NOT NULL,
  `P_img` varchar(100) NOT NULL,
  `P_minqty` int(11) NOT NULL,
  `P_minprice` double NOT NULL,
  `P_maxprice` double NOT NULL,
  `T_id` int(11) NOT NULL DEFAULT 0,
  `P_byprice` double NOT NULL,
  `P_hsn` int(6) NOT NULL,
  `P_unit` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`P_id`, `P_name`, `P_qty`, `P_status`, `P_img`, `P_minqty`, `P_minprice`, `P_maxprice`, `T_id`, `P_byprice`, `P_hsn`, `P_unit`) VALUES
(1, 'TV', 12, 0, '1712204964283_.png', 20, 150, 200, 4, 120, 111111, 'NOS'),
(13, 'Xiaomi 125 cm (50 inches) X 4K Dolby Vision Series Smart Google TV L50M8-A2IN (Black)', 2, 0, '1712205002941_.png', 20, 4, 204, 4, 29000, 123456, 'NOS'),
(14, 'ghmh ghmjfg', 77, 0, 'default.webp', 20, 100, 204, 5, 29000, 123456, 'MTR'),
(15, 'sfs', 77, 0, 'default.png', 20, 4, 150, 4, 29000, 123456, 'MTR');

-- --------------------------------------------------------

--
-- Table structure for table `purchasebildetails`
--

CREATE TABLE `purchasebildetails` (
  `Pur_bill_id` int(11) NOT NULL,
  `Pur_bill_invoicenumber` int(11) NOT NULL,
  `Pur_bill_cgst` double NOT NULL,
  `Pur_bill_sgst` double NOT NULL,
  `Pur_id` int(11) NOT NULL,
  `Pur_bill_entrytime` datetime NOT NULL DEFAULT current_timestamp(),
  `Pur_bill_billby` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchasebillitems`
--

CREATE TABLE `purchasebillitems` (
  `Pur_bill_id` int(11) NOT NULL,
  `purchasebillitems_pid` int(11) NOT NULL,
  `purchasebillitems_buyprice` double NOT NULL,
  `qty` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchasedetails`
--

CREATE TABLE `purchasedetails` (
  `Pur_id` int(11) NOT NULL,
  `Sup_id` int(11) NOT NULL,
  `Pur_by` int(11) NOT NULL,
  `Pur_due` date NOT NULL,
  `Pur_paymode` varchar(15) NOT NULL,
  `Pur_created` datetime NOT NULL DEFAULT current_timestamp(),
  `Pur_status` int(1) NOT NULL DEFAULT 0,
  `Pur_deleteststus` int(1) NOT NULL DEFAULT 0,
  `Pur_advance` double DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchaseitems`
--

CREATE TABLE `purchaseitems` (
  `Pur_id` int(11) NOT NULL,
  `P_id` int(11) NOT NULL,
  `Pur_qty` int(11) NOT NULL,
  `Pur_recqty` int(5) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchasereturn`
--

CREATE TABLE `purchasereturn` (
  `Pur_returnid` int(11) NOT NULL,
  `Pur_returnbillno` varchar(20) NOT NULL,
  `Sup_id` int(11) DEFAULT NULL,
  `Pur_returntotalamt` double NOT NULL,
  `Pur_returnpaymode` varchar(15) NOT NULL,
  `Emp_id` int(11) NOT NULL,
  `Pur_returntime` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchasereturnitems`
--

CREATE TABLE `purchasereturnitems` (
  `Pur_returnid` int(11) NOT NULL,
  `Pur_returnpid` int(11) NOT NULL,
  `Pur_returnqty` int(11) NOT NULL,
  `Pur_returncomment` varchar(100) NOT NULL,
  `Pur_returnprice` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `route`
--

CREATE TABLE `route` (
  `R_id` int(11) NOT NULL,
  `R_name` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `route`
--

INSERT INTO `route` (`R_id`, `R_name`) VALUES
(1, 'cherupuram, mukkudil, manjakuzhi, rajakumary, pooppara	');

-- --------------------------------------------------------

--
-- Table structure for table `salesreturn`
--

CREATE TABLE `salesreturn` (
  `Sr_id` int(11) NOT NULL,
  `Sr_pid` int(11) NOT NULL,
  `Sr_qty` int(11) NOT NULL,
  `Sr_rate` double NOT NULL,
  `Sr_tax` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `salesreturndetails`
--

CREATE TABLE `salesreturndetails` (
  `Srd_id` int(11) NOT NULL,
  `Srd_billid` int(11) NOT NULL,
  `Srd_sid` int(11) NOT NULL,
  `Srd_date` datetime NOT NULL DEFAULT current_timestamp(),
  `Srd_eid` int(11) NOT NULL,
  `Srd_paymode` varchar(10) DEFAULT NULL,
  `Srd_Total` double DEFAULT NULL,
  `Srd_status` int(2) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `state`
--

CREATE TABLE `state` (
  `St_id` int(11) NOT NULL,
  `St_code` int(2) DEFAULT NULL,
  `St_name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `state`
--

INSERT INTO `state` (`St_id`, `St_code`, `St_name`) VALUES
(1, 1, 'Jammu & Kashmir'),
(2, 2, 'Himachal Pradesh'),
(3, 3, 'Punjab'),
(4, 4, 'Chandigarh'),
(5, 5, 'Uttarakhand'),
(6, 6, 'Haryana'),
(7, 7, 'Delhi'),
(8, 8, 'Rajasthan'),
(9, 9, 'Uttar Pradesh'),
(10, 10, 'Bihar'),
(11, 11, 'Sikkim'),
(12, 12, 'Arunachal Pradesh'),
(13, 13, 'Nagaland'),
(14, 14, 'Manipur'),
(15, 15, 'Mizoram'),
(16, 16, 'Tripura'),
(17, 17, 'Meghalaya'),
(18, 18, 'Assam'),
(19, 19, 'West Bengal'),
(20, 20, 'Jharkhand'),
(21, 21, 'Orissa'),
(22, 22, 'Chhattisgarh'),
(23, 23, 'Madhya Pradesh'),
(24, 24, 'Gujarat'),
(25, 25, 'Daman & Diu'),
(26, 26, 'Dadra & Nagar Haveli'),
(27, 27, 'Maharashtra'),
(28, 28, 'Andhra Pradesh (Old)'),
(29, 29, 'Karnataka'),
(30, 30, 'Goa'),
(31, 31, 'Lakshadweep'),
(32, 32, 'Kerala'),
(33, 33, 'Tamil Nadu'),
(34, 34, 'Puducherry'),
(35, 35, 'Andaman & Nicobar Islands'),
(36, 36, 'Telangana'),
(37, 37, 'Andhra Pradesh (New)');

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

CREATE TABLE `stock` (
  `stock_id` int(11) NOT NULL,
  `stock_date` datetime NOT NULL DEFAULT current_timestamp(),
  `stock_P_id` int(11) NOT NULL,
  `stock_qty` int(11) NOT NULL,
  `stock_minprice` double NOT NULL,
  `stock_maxprice` double NOT NULL,
  `Stock_remarks` varchar(20) NOT NULL,
  `stock_balance` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`stock_id`, `stock_date`, `stock_P_id`, `stock_qty`, `stock_minprice`, `stock_maxprice`, `Stock_remarks`, `stock_balance`) VALUES
(1, '2024-04-04 09:12:12', 1, 55, 150, 200, 'UPDATE', 55),
(2, '2024-04-04 09:13:17', 1, 55, 150, 200, 'UPDATE', 55),
(3, '2024-04-04 09:17:48', 1, 55, 150, 200, 'UPDATE', 55),
(4, '2024-04-04 09:19:31', 1, 55, 150, 200, 'UPDATE', 55),
(5, '2024-04-04 09:20:05', 1, 55, 150, 200, 'UPDATE', 55),
(6, '2024-04-04 09:21:09', 1, 55, 150, 200, 'UPDATE', 55),
(7, '2024-04-04 09:23:31', 1, 55, 150, 200, 'UPDATE', 55),
(8, '2024-04-04 09:24:31', 1, 55, 150, 200, 'UPDATE', 55),
(9, '2024-04-04 09:24:31', 1, 55, 150, 200, 'UPDATE', 55),
(10, '2024-04-04 09:25:51', 1, 55, 150, 200, 'UPDATE', 55),
(11, '2024-04-04 09:35:59', 1, 55, 150, 200, 'UPDATE', 55),
(12, '2024-04-04 09:35:59', 1, 55, 150, 200, 'UPDATE', 55),
(13, '2024-04-04 09:35:59', 1, 55, 150, 200, 'UPDATE', 55),
(14, '2024-04-04 09:35:59', 1, 55, 150, 200, 'UPDATE', 55),
(15, '2024-04-04 09:35:59', 1, 55, 150, 200, 'UPDATE', 55),
(16, '2024-04-04 09:47:15', 1, 55, 150, 200, 'UPDATE', 55),
(17, '2024-04-04 09:50:40', 1, 55, 150, 200, 'UPDATE', 55),
(18, '2024-04-04 09:50:51', 1, 55, 150, 200, 'UPDATE', 55),
(19, '2024-04-04 09:56:51', 1, 55, 150, 200, 'UPDATE', 55),
(20, '2024-04-04 09:56:58', 1, 55, 150, 200, 'UPDATE', 55),
(21, '2024-04-04 09:57:29', 1, 55, 150, 200, 'UPDATE', 55),
(22, '2024-04-04 09:59:16', 1, 55, 150, 200, 'UPDATE', 55),
(23, '2024-04-04 09:59:24', 1, 55, 150, 200, 'UPDATE', 55),
(24, '2024-04-04 10:00:03', 13, 35, 4, 204, 'NEW ADD', 35),
(25, '2024-04-11 09:46:12', 13, -23, 4, 204, 'SALE', 12),
(26, '2024-04-12 20:36:41', 13, -10, 4, 204, 'SALE', 2),
(27, '2024-04-12 20:36:41', 1, -1, 150, 200, 'SALE', 54),
(28, '2024-04-12 20:38:16', 13, -2, 4, 204, 'SALE', 0),
(29, '2024-04-12 20:38:16', 1, -4, 150, 200, 'SALE', 50),
(30, '2024-04-12 20:38:16', 1, -1, 150, 200, 'SALE', 53),
(31, '2024-04-12 20:40:06', 13, -2, 4, 204, 'SALE', -2),
(32, '2024-04-12 20:40:06', 1, -4, 150, 200, 'SALE', 49),
(33, '2024-04-12 20:40:06', 1, -1, 150, 200, 'SALE', 52),
(34, '2024-04-12 20:42:25', 13, -2, 4, 204, 'SALE', -4),
(35, '2024-04-12 20:42:25', 1, -4, 150, 200, 'SALE', 48),
(36, '2024-04-12 20:42:25', 1, -1, 150, 200, 'SALE', 51),
(37, '2024-04-12 20:44:08', 13, -2, 4, 204, 'SALE', -6),
(38, '2024-04-12 20:44:08', 1, -4, 150, 200, 'SALE', 47),
(39, '2024-04-12 20:44:08', 1, -1, 150, 200, 'SALE', 50),
(40, '2024-04-12 21:13:08', 1, -1, 150, 200, 'SALE', 49),
(41, '2024-04-12 21:13:34', 1, -12, 150, 200, 'SALE', 37),
(42, '2024-04-13 11:31:24', 1, -10, 150, 200, 'SALE', 27),
(43, '2024-04-13 12:19:32', 1, -1, 150, 200, 'SALE', 26),
(44, '2024-04-13 12:19:32', 13, -2, 4, 204, 'SALE', 18),
(45, '2024-04-13 12:28:21', 1, -1, 150, 200, 'SALE', 25),
(46, '2024-04-13 12:28:21', 13, -2, 4, 204, 'SALE', 16),
(47, '2024-04-13 12:41:02', 1, -1, 150, 200, 'SALE', 24),
(48, '2024-04-13 12:42:16', 13, -1, 4, 204, 'SALE', 15),
(49, '2024-04-13 12:42:16', 1, -2, 150, 200, 'SALE', 22),
(50, '2024-04-13 14:38:51', 1, -1, 150, 200, 'SALE', 21),
(51, '2024-04-13 14:38:51', 13, -2, 4, 204, 'SALE', 13),
(52, '2024-04-15 21:27:11', 1, -1, 150, 200, 'SALE', 20),
(53, '2024-04-15 21:27:11', 13, -3, 4, 204, 'SALE', 10),
(54, '2024-04-15 22:02:19', 13, -1, 4, 204, 'SALE', 9),
(55, '2024-04-15 22:02:19', 1, -3, 150, 200, 'SALE', 17),
(56, '2024-04-15 22:02:33', 1, -5, 150, 200, 'SALE', 12),
(57, '2024-04-15 22:02:33', 13, -2, 4, 204, 'SALE', 7),
(58, '2024-04-15 22:05:02', 13, -7, 4, 204, 'SALE', 0),
(59, '2024-04-15 22:05:02', 13, -5, 4, 204, 'SALE', 2),
(60, '2024-04-16 13:07:29', 14, 77, 100, 204, 'NEW ADD', 77),
(61, '2024-04-16 13:16:43', 15, 77, 4, 150, 'NEW ADD', 77),
(62, '2024-04-16 13:19:37', 15, 77, 4, 150, 'UPDATE', 77);

-- --------------------------------------------------------

--
-- Table structure for table `store`
--

CREATE TABLE `store` (
  `S_id` int(5) NOT NULL,
  `S_name` varchar(100) NOT NULL,
  `S_address` varchar(100) NOT NULL,
  `S_phn` bigint(10) NOT NULL,
  `S_status` int(1) NOT NULL,
  `S_email` varchar(100) NOT NULL,
  `St_code` int(11) NOT NULL,
  `S_gst` varchar(16) NOT NULL,
  `S_accno` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `store`
--

INSERT INTO `store` (`S_id`, `S_name`, `S_address`, `S_phn`, `S_status`, `S_email`, `St_code`, `S_gst`, `S_accno`) VALUES
(1, '--OPEN ORDER--', '', 0, 5, '', 32, '', 0),
(4, 'tata', 'Rajakkad\r\nidukki 685566', 9656485578, 0, 'alex@gmail.com', 28, '32BFNPT6605K1Z1', 62),
(5, 'birla', 'kollam\r\nkerala\r\n', 9615785569, 0, 'hahah@mail.com', 32, '32BFNPT6605K1Z3', 63);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `Sup_id` int(11) NOT NULL,
  `Sup_accno` int(11) DEFAULT NULL,
  `Sup_name` varchar(150) NOT NULL,
  `Sup_gst` varchar(20) NOT NULL,
  `Sup_email` varchar(100) NOT NULL,
  `Sup_phone` bigint(10) NOT NULL,
  `Sup_address` varchar(300) NOT NULL,
  `Sup_statecode` int(2) NOT NULL,
  `Sup_pin` int(7) NOT NULL,
  `Sup_createdon` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`Sup_id`, `Sup_accno`, `Sup_name`, `Sup_gst`, `Sup_email`, `Sup_phone`, `Sup_address`, `Sup_statecode`, `Sup_pin`, `Sup_createdon`) VALUES
(1, 60, 'dfdfg', '09AAACH7409R1ZZ', 'dfg@mail.dfyhg', 9656485578, 'dfgd', 32, 685566, '2024-04-02 11:39:01');

-- --------------------------------------------------------

--
-- Table structure for table `tax`
--

CREATE TABLE `tax` (
  `T_id` int(11) NOT NULL,
  `T_name` varchar(11) NOT NULL,
  `T_perc` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tax`
--

INSERT INTO `tax` (`T_id`, `T_name`, `T_perc`) VALUES
(1, 'GST', 0),
(2, 'GST', 5),
(3, 'GST', 12),
(4, 'GST', 18),
(5, 'GST', 28);

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `Transactiontableid` int(11) NOT NULL,
  `T_id` varchar(30) NOT NULL,
  `T_date` date NOT NULL,
  `T_drid` int(11) NOT NULL,
  `T_crid` int(11) NOT NULL,
  `T_amount` double NOT NULL,
  `T_remarks` varchar(100) NOT NULL,
  `T_cheque` varchar(15) NOT NULL,
  `T_vtype` varchar(30) NOT NULL,
  `T_refno` int(10) NOT NULL,
  `T_empid` int(5) NOT NULL,
  `T_time` datetime NOT NULL DEFAULT current_timestamp(),
  `T_vchno` int(11) NOT NULL,
  `T_BankDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`Transactiontableid`, `T_id`, `T_date`, `T_drid`, `T_crid`, `T_amount`, `T_remarks`, `T_cheque`, `T_vtype`, `T_refno`, `T_empid`, `T_time`, `T_vchno`, `T_BankDate`) VALUES
(1, '1712205254939', '2024-04-04', 6, 1, 100, '0', '0', 'PAYMENT', 0, 1, '2024-04-04 10:04:14', 1, NULL),
(2, '1712642663976', '2024-04-09', 56, 1, 100, 'Allowance Paid', 'NIL', 'PAYMENT', 0, 2, '2024-04-09 11:34:23', 2, NULL),
(3, '1712643601078', '2024-04-09', 61, 3, 56, 'Allowance Paid', 'NIL', 'PAYMENT', 0, 2, '2024-04-09 11:50:01', 3, NULL),
(4, '1712645736058', '2024-04-09', 1, 4, 500, '0', '0', 'RECEIPT', 0, 2, '2024-04-09 12:25:36', 1, NULL),
(5, '1712646252914', '2024-04-09', 7, 1, 500, '', 'NaN', 'PAYMENT', 0, 2, '2024-04-09 12:34:12', 4, NULL),
(6, '1712649255918', '2024-04-09', 61, 1, 12.5, 'food ', '123', 'PAYMENT', 0, 2, '2024-04-09 13:24:15', 5, NULL),
(7, '1712650222108', '2024-04-09', 61, 1, 50, '0', '0', 'PAYMENT', 0, 2, '2024-04-09 13:40:22', 6, NULL),
(8, '1712650341092', '2024-04-27', 1, 61, 10, '0', '0', 'RECEIPT', 0, 2, '2024-04-09 13:42:21', 2, NULL),
(9, '1712808972362', '2024-04-11', 2, 4, 5255, 'Sys Entry Csh sale', '0', 'RECEIPT', 1, 2, '2024-04-11 09:46:12', 3, NULL),
(10, '1712934401153', '2024-04-12', 2, 4, 7500, 'Sys Entry Csh sale', '0', 'RECEIPT', 0, 2, '2024-04-12 20:36:41', 4, NULL),
(11, '1712934496787', '2024-04-12', 1, 4, 1561.44, 'Sys Entry Csh sale', '0', 'RECEIPT', 0, 2, '2024-04-12 20:38:16', 5, NULL),
(12, '1712934606812', '2024-04-12', 1, 4, 1561.44, 'Sys Entry Csh sale', '0', 'RECEIPT', 0, 2, '2024-04-12 20:40:06', 6, NULL),
(13, '1712934745764', '2024-04-12', 1, 4, 1561.44, 'Sys Entry Csh sale', '0', 'RECEIPT', 0, 2, '2024-04-12 20:42:25', 7, NULL),
(14, '1712934848802', '2024-04-12', 1, 4, 1561.44, 'Sys Entry Csh sale', '0', 'RECEIPT', 2, 2, '2024-04-12 20:44:08', 8, NULL),
(15, '1712936588702', '2024-04-12', 1, 4, 5936, 'Sys Entry Csh sale', '0', 'RECEIPT', 3, 2, '2024-04-12 21:13:08', 9, NULL),
(16, '1712936614149', '2024-04-12', 1, 4, 2832, 'Sys Entry Csh sale', '0', 'RECEIPT', 4, 2, '2024-04-12 21:13:34', 10, NULL),
(17, '1712988084874', '2024-04-13', 1, 4, 2360, 'Sys Entry Csh sale', '0', 'RECEIPT', 5, 2, '2024-04-13 11:31:24', 11, NULL),
(18, '1712990972470', '2024-04-13', 1, 4, 608, 'Sys Entry Csh sale', '0', 'RECEIPT', 0, 2, '2024-04-13 12:19:32', 12, NULL),
(19, '1712991501238', '2024-04-13', 1, 4, 608, 'Sys Entry Csh sale', '0', 'RECEIPT', 6, 2, '2024-04-13 12:28:21', 13, NULL),
(20, '1712992262566', '2024-04-13', 1, 4, 200, 'Sys Entry Csh sale', '0', 'RECEIPT', 9, 2, '2024-04-13 12:41:02', 14, NULL),
(21, '1712992336864', '2024-04-13', 1, 4, 604, 'Sys Entry Csh sale', '0', 'RECEIPT', 10, 2, '2024-04-13 12:42:16', 15, NULL),
(22, '1712999331991', '2024-04-13', 1, 4, 608, 'Sys Entry Csh sale', '0', 'RECEIPT', 11, 2, '2024-04-13 14:38:51', 16, NULL),
(23, '1713196631174', '2024-04-15', 1, 4, 712, 'Sys Entry Csh sale', '0', 'RECEIPT', 13, 2, '2024-04-15 21:27:11', 17, NULL),
(24, '1713198739927', '2024-04-15', 1, 4, 704, 'Sys Entry Csh sale', '0', 'RECEIPT', 14, 2, '2024-04-15 22:02:19', 18, NULL),
(25, '1713198753845', '2024-04-15', 1, 4, 1408, 'Sys Entry Csh sale', '0', 'RECEIPT', 15, 2, '2024-04-15 22:02:33', 19, NULL),
(26, '1713198902292', '2024-04-15', 3, 4, 2448, 'Sys Entry Csh sale', '0', 'RECEIPT', 16, 2, '2024-04-15 22:05:02', 20, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `unitsofitem`
--

CREATE TABLE `unitsofitem` (
  `uid` int(11) NOT NULL,
  `Quantity` varchar(30) NOT NULL,
  `UnitQuantityCode` varchar(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `unitsofitem`
--

INSERT INTO `unitsofitem` (`uid`, `Quantity`, `UnitQuantityCode`) VALUES
(1, 'Pieces', 'PCS'),
(2, 'Meters', 'MTR'),
(3, 'Numbers', 'NOS'),
(4, 'Units', 'UNT'),
(5, 'Kilo Grams', 'KGS'),
(6, 'Square Meters', 'SQM'),
(7, 'Cartons', 'CTN'),
(8, 'Packs', 'PAC'),
(9, 'Bottles', 'BTL'),
(10, 'Box', 'BOX'),
(11, 'Dozen', 'DOZ'),
(12, 'Cans', 'CAN'),
(13, 'Bundles', 'BDL'),
(14, 'Rolls', 'ROL'),
(15, 'Pairs', 'PRS'),
(19, 'Grams', 'GMS'),
(20, 'Square Feet', 'SQF'),
(24, 'Ten Gross', 'TGM'),
(27, 'Cubic Meter', 'CBM'),
(32, 'Kilo Liter', 'KLR'),
(33, 'Milliliter', 'MLT'),
(34, 'Gross Yards', 'GYD'),
(35, 'Square Yards', 'SQY'),
(36, 'Buckles', 'BKL'),
(37, 'Cubic Centimeter', 'CCM'),
(38, 'Bag', 'BAG'),
(39, 'Miles', 'MIL'),
(40, 'Inches', 'INH');

-- --------------------------------------------------------

--
-- Table structure for table `voucherserialnumbers`
--

CREATE TABLE `voucherserialnumbers` (
  `V_id` int(11) NOT NULL,
  `V_name` varchar(20) NOT NULL,
  `V_SerialNumber` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `voucherserialnumbers`
--

INSERT INTO `voucherserialnumbers` (`V_id`, `V_name`, `V_SerialNumber`) VALUES
(1, 'CONTRA', 0),
(2, 'PAYMENT', 6),
(3, 'RECEIPT', 20),
(4, 'JOURNAL', 0),
(5, 'SALES', 0),
(6, 'PURCHASE', 0),
(7, 'SALES RETURN', 0),
(8, 'PURCHASE RETURN', 0),
(9, 'RECEIPT NOTE', 0),
(10, 'DELIVERY NOTE', 0),
(11, 'STOCK JOURNAL', 0),
(12, 'PHYSICAL STOCK', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`A_id`);

--
-- Indexes for table `billdetails`
--
ALTER TABLE `billdetails`
  ADD PRIMARY KEY (`B_id`);

--
-- Indexes for table `collection`
--
ALTER TABLE `collection`
  ADD PRIMARY KEY (`C_id`);

--
-- Indexes for table `damageentrydeatils`
--
ALTER TABLE `damageentrydeatils`
  ADD PRIMARY KEY (`Damageid`);

--
-- Indexes for table `device_mgmt`
--
ALTER TABLE `device_mgmt`
  ADD PRIMARY KEY (`dev_id`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`E_id`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`X_id`);

--
-- Indexes for table `group`
--
ALTER TABLE `group`
  ADD PRIMARY KEY (`g_id`);

--
-- Indexes for table `ledger`
--
ALTER TABLE `ledger`
  ADD PRIMARY KEY (`l_id`);

--
-- Indexes for table `location`
--
ALTER TABLE `location`
  ADD PRIMARY KEY (`L_id`);

--
-- Indexes for table `orderdetails`
--
ALTER TABLE `orderdetails`
  ADD PRIMARY KEY (`O_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`P_id`);

--
-- Indexes for table `purchasebildetails`
--
ALTER TABLE `purchasebildetails`
  ADD PRIMARY KEY (`Pur_bill_id`);

--
-- Indexes for table `purchasedetails`
--
ALTER TABLE `purchasedetails`
  ADD PRIMARY KEY (`Pur_id`);

--
-- Indexes for table `purchasereturn`
--
ALTER TABLE `purchasereturn`
  ADD PRIMARY KEY (`Pur_returnid`);

--
-- Indexes for table `route`
--
ALTER TABLE `route`
  ADD PRIMARY KEY (`R_id`);

--
-- Indexes for table `salesreturndetails`
--
ALTER TABLE `salesreturndetails`
  ADD PRIMARY KEY (`Srd_id`);

--
-- Indexes for table `state`
--
ALTER TABLE `state`
  ADD PRIMARY KEY (`St_id`);

--
-- Indexes for table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`stock_id`);

--
-- Indexes for table `store`
--
ALTER TABLE `store`
  ADD PRIMARY KEY (`S_id`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`Sup_id`);

--
-- Indexes for table `tax`
--
ALTER TABLE `tax`
  ADD PRIMARY KEY (`T_id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`Transactiontableid`);

--
-- Indexes for table `unitsofitem`
--
ALTER TABLE `unitsofitem`
  ADD PRIMARY KEY (`uid`);

--
-- Indexes for table `voucherserialnumbers`
--
ALTER TABLE `voucherserialnumbers`
  ADD PRIMARY KEY (`V_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `A_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `billdetails`
--
ALTER TABLE `billdetails`
  MODIFY `B_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `collection`
--
ALTER TABLE `collection`
  MODIFY `C_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `damageentrydeatils`
--
ALTER TABLE `damageentrydeatils`
  MODIFY `Damageid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `device_mgmt`
--
ALTER TABLE `device_mgmt`
  MODIFY `dev_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `E_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `X_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `group`
--
ALTER TABLE `group`
  MODIFY `g_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `ledger`
--
ALTER TABLE `ledger`
  MODIFY `l_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `location`
--
ALTER TABLE `location`
  MODIFY `L_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orderdetails`
--
ALTER TABLE `orderdetails`
  MODIFY `O_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `P_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `purchasebildetails`
--
ALTER TABLE `purchasebildetails`
  MODIFY `Pur_bill_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchasedetails`
--
ALTER TABLE `purchasedetails`
  MODIFY `Pur_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchasereturn`
--
ALTER TABLE `purchasereturn`
  MODIFY `Pur_returnid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `route`
--
ALTER TABLE `route`
  MODIFY `R_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `salesreturndetails`
--
ALTER TABLE `salesreturndetails`
  MODIFY `Srd_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `state`
--
ALTER TABLE `state`
  MODIFY `St_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `stock`
--
ALTER TABLE `stock`
  MODIFY `stock_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT for table `store`
--
ALTER TABLE `store`
  MODIFY `S_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `Sup_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tax`
--
ALTER TABLE `tax`
  MODIFY `T_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `Transactiontableid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `unitsofitem`
--
ALTER TABLE `unitsofitem`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `voucherserialnumbers`
--
ALTER TABLE `voucherserialnumbers`
  MODIFY `V_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
