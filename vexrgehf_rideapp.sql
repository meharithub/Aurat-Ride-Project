-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 30, 2025 at 09:57 AM
-- Server version: 11.4.8-MariaDB-cll-lve-log
-- PHP Version: 8.3.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vexrgehf_rideapp`
--

-- --------------------------------------------------------

--
-- Table structure for table `contact_messages`
--

CREATE TABLE `contact_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(150) DEFAULT NULL,
  `email` varchar(191) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `driver_locations`
--

CREATE TABLE `driver_locations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `driver_id` bigint(20) UNSIGNED NOT NULL,
  `lat` decimal(10,7) NOT NULL,
  `lng` decimal(10,7) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` text NOT NULL,
  `exception` text NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(11) NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otps`
--

CREATE TABLE `otps` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `recipient` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `otps`
--

INSERT INTO `otps` (`id`, `user_id`, `recipient`, `type`, `code`, `expires_at`, `is_used`, `created_at`, `updated_at`) VALUES
(1, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '554179', '2025-09-25 16:16:09', 0, '2025-09-25 16:11:09', '2025-09-25 16:11:09'),
(2, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '991315', '2025-09-25 16:31:19', 0, '2025-09-25 16:26:19', '2025-09-25 16:26:19'),
(3, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '527429', '2025-09-25 16:37:26', 1, '2025-09-25 16:32:26', '2025-09-25 16:33:38'),
(4, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '181218', '2025-09-25 16:55:25', 1, '2025-09-25 16:50:25', '2025-09-25 16:51:03'),
(5, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '915703', '2025-09-25 18:53:42', 0, '2025-09-25 18:48:42', '2025-09-25 18:48:42'),
(6, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '619160', '2025-09-25 18:56:10', 0, '2025-09-25 18:51:10', '2025-09-25 18:51:10'),
(7, NULL, 'basimgun123@gmail.com', 'email', '750375', '2025-09-25 20:31:19', 0, '2025-09-25 20:26:19', '2025-09-25 20:26:19'),
(8, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '228011', '2025-09-25 20:40:48', 1, '2025-09-25 20:35:48', '2025-09-25 20:36:06'),
(9, NULL, 'syedalii2005october@gmail.com', 'email', '222525', '2025-09-26 04:52:13', 0, '2025-09-26 04:47:13', '2025-09-26 04:47:13'),
(10, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '864328', '2025-09-26 15:48:40', 0, '2025-09-26 15:43:40', '2025-09-26 15:43:40'),
(11, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '295944', '2025-09-26 16:00:29', 0, '2025-09-26 15:55:29', '2025-09-26 15:55:29'),
(12, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '170401', '2025-09-26 16:02:02', 1, '2025-09-26 15:57:02', '2025-09-26 15:57:16'),
(13, NULL, 'clawspireclash@gmail.com', 'email', '656690', '2025-09-26 16:19:07', 1, '2025-09-26 16:14:07', '2025-09-26 16:15:21'),
(14, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '584467', '2025-09-27 17:23:02', 1, '2025-09-27 17:18:02', '2025-09-27 17:18:31'),
(15, NULL, 'syedtahooraliprogrammer@gmail.com', 'email', '682167', '2025-09-28 14:09:53', 1, '2025-09-28 14:04:53', '2025-09-28 14:05:20'),
(16, NULL, '03001234567', 'phone', '663182', '2025-09-30 11:31:46', 0, '2025-09-30 11:26:46', '2025-09-30 11:26:46');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 21, 'auth_token', '2fee7e9d20f9df5f344512ebb934054815a58eb54da08473608d09fb984bf9fb', '[\"*\"]', NULL, NULL, '2025-09-25 17:02:37', '2025-09-25 17:02:37'),
(2, 'App\\Models\\User', 23, 'auth_token', '73770948addc9ac0be35451f61ce3b4bca49c27573d60f8581e031a386ce52e0', '[\"*\"]', NULL, NULL, '2025-09-25 18:53:13', '2025-09-25 18:53:13'),
(3, 'App\\Models\\User', 25, 'auth_token', '32d332d05219f2fe8234144c5989013131a3902885320aaff625fc9cc23d87a0', '[\"*\"]', NULL, NULL, '2025-09-25 20:36:21', '2025-09-25 20:36:21'),
(4, 'App\\Models\\User', 29, 'auth_token', 'eb7885821211d35cba4a8c954d6eb0fa248f3e30beb890e0b97e768e89757eac', '[\"*\"]', NULL, NULL, '2025-09-26 16:02:04', '2025-09-26 16:02:04'),
(5, 'App\\Models\\User', 30, 'auth_token', 'c9304fe36a96927394818bc583bf40230fee3bbead5d492a5519fe43f767f7fa', '[\"*\"]', NULL, NULL, '2025-09-26 16:15:36', '2025-09-26 16:15:36'),
(6, 'App\\Models\\User', 31, 'auth_token', '4cafcadb830707404eca2060a4ac8acbeb9b81170d4e27987e76268888f1e334', '[\"*\"]', '2025-09-27 18:16:56', NULL, '2025-09-27 17:18:41', '2025-09-27 18:16:56'),
(7, 'App\\Models\\User', 32, 'auth_token', 'fd912daf832888994cf1d1df41ce4305bb7222388482c74add2505bc69de2387', '[\"*\"]', '2025-09-28 14:10:26', NULL, '2025-09-28 14:08:58', '2025-09-28 14:10:26'),
(8, 'App\\Models\\User', 32, 'auth_token', '6971a9c2fa5ef299ace73ece12483d3cf53ca3827fc0eaae14c8a02a5bb8a539', '[\"*\"]', '2025-09-29 21:09:43', NULL, '2025-09-28 15:55:29', '2025-09-29 21:09:43'),
(9, 'App\\Models\\User', 32, 'auth_token', 'd7935084098f073a390837804ca9c3aace80631b21aaa6262ad79e485693fc21', '[\"*\"]', NULL, NULL, '2025-09-29 09:41:38', '2025-09-29 09:41:38'),
(10, 'App\\Models\\User', 32, 'auth_token', '19d1ccd3e190a7a9eb87c6eb783054eb2a9eea1b14efe4d1606a3d1719411217', '[\"*\"]', '2025-09-29 21:38:28', NULL, '2025-09-29 21:10:56', '2025-09-29 21:38:28'),
(11, 'App\\Models\\User', 32, 'auth_token', '6b95b249ad5f5e62bee7f04ffc861eac8984c7402c58939d3043c926a1498d99', '[\"*\"]', NULL, NULL, '2025-09-30 04:58:37', '2025-09-30 04:58:37'),
(12, 'App\\Models\\User', 33, 'auth_token', '66b9baaed0325058e66e31b2524a686779759574d7319e7103e39e443684f5a8', '[\"*\"]', NULL, NULL, '2025-09-30 06:57:12', '2025-09-30 06:57:12'),
(13, 'App\\Models\\User', 33, 'auth_token', '690b810edee704fb781a62602b65edea05ff88d398fea8c0492f25571c99a4a2', '[\"*\"]', NULL, NULL, '2025-09-30 10:58:10', '2025-09-30 10:58:10'),
(14, 'App\\Models\\User', 33, 'auth_token', 'eba19d714e3450a5f924989907a67e07364dbdfd66443f511ad01210746cecc3', '[\"*\"]', NULL, NULL, '2025-09-30 11:12:30', '2025-09-30 11:12:30'),
(15, 'App\\Models\\User', 33, 'auth_token', 'f9aa651242a2e08d858350ad5e420951abdebec07af31d0df1dd4f88ab1092b7', '[\"*\"]', NULL, NULL, '2025-09-30 11:17:59', '2025-09-30 11:17:59'),
(16, 'App\\Models\\User', 35, 'auth_token', 'c21ee58db07d8090f596074214f1686f4787cc9fccb213408b7ed80a88c89ad1', '[\"*\"]', NULL, NULL, '2025-09-30 11:18:16', '2025-09-30 11:18:16'),
(17, 'App\\Models\\User', 35, 'auth_token', '131947ee250a3b2fa72d53625e1441667ef4e8f4832cee61c2cae32774f82242', '[\"*\"]', NULL, NULL, '2025-09-30 11:18:40', '2025-09-30 11:18:40'),
(18, 'App\\Models\\User', 35, 'auth_token', 'c980428cfd189c828687ddeb0f927ad5ff44e6f44f068c7552cbfa7a6fbefc39', '[\"*\"]', NULL, NULL, '2025-09-30 11:21:12', '2025-09-30 11:21:12'),
(19, 'App\\Models\\User', 35, 'auth_token', '9ff2df7f8266f8a985ed46348f960e024b757e0ffb199b63686c06280d0fad15', '[\"*\"]', NULL, NULL, '2025-09-30 11:22:54', '2025-09-30 11:22:54'),
(20, 'App\\Models\\User', 35, 'auth_token', 'f32bd0996121182ed3f2dfbe111d39dbd3694806312055440538b8d33f558e9e', '[\"*\"]', '2025-09-30 11:27:02', NULL, '2025-09-30 11:26:44', '2025-09-30 11:27:02');

-- --------------------------------------------------------

--
-- Table structure for table `ratings`
--

CREATE TABLE `ratings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ride_id` bigint(20) UNSIGNED NOT NULL,
  `rider_id` bigint(20) UNSIGNED NOT NULL,
  `driver_id` bigint(20) UNSIGNED NOT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `comment` varchar(1024) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rides`
--

CREATE TABLE `rides` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `rider_id` bigint(20) UNSIGNED NOT NULL,
  `driver_id` bigint(20) UNSIGNED DEFAULT NULL,
  `pickup_lat` decimal(10,7) NOT NULL,
  `pickup_lng` decimal(10,7) NOT NULL,
  `pickup_address` varchar(1024) DEFAULT NULL,
  `dropoff_lat` decimal(10,7) NOT NULL,
  `dropoff_lng` decimal(10,7) NOT NULL,
  `dropoff_address` varchar(1024) DEFAULT NULL,
  `distance_km` decimal(8,3) DEFAULT NULL,
  `estimated_fare` decimal(8,2) DEFAULT NULL,
  `final_fare` decimal(8,2) DEFAULT NULL,
  `status` enum('requested','assigned','driver_arriving','started','completed','canceled') NOT NULL DEFAULT 'requested',
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `canceled_at` timestamp NULL DEFAULT NULL,
  `canceled_by` enum('rider','driver','system') DEFAULT NULL,
  `payment_method` enum('cash') NOT NULL DEFAULT 'cash',
  `payment_status` enum('unpaid','paid') NOT NULL DEFAULT 'unpaid',
  `polyline` longtext DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` longtext DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'rider',
  `name` varchar(150) DEFAULT NULL,
  `email` varchar(191) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `cnic` varchar(50) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `is_email_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_phone_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_profile_verified` tinyint(1) NOT NULL DEFAULT 0,
  `profile_pic_url` varchar(1024) DEFAULT NULL,
  `selfie` varchar(1024) DEFAULT NULL,
  `email_verified_at` datetime DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `role`, `name`, `email`, `phone`, `password`, `cnic`, `gender`, `is_email_verified`, `is_phone_verified`, `is_profile_verified`, `profile_pic_url`, `selfie`, `email_verified_at`, `remember_token`, `created_at`, `updated_at`) VALUES
(35, 'Rider', 'Updated Test User', 'rider@example.com', '03001234581', '$2y$10$Rwy/1k7bWb6JJqSAXEo4RukZMs0pAEV2zhOOJMug8iFyKRGZ7yuJe', '12345-6789012-9', 'Female', 0, 0, 0, NULL, NULL, NULL, NULL, '2025-09-30 11:18:11', '2025-09-30 11:26:49'),
(33, 'Driver', 'Test User', 'test@example.com', '03001234567', '$2y$10$LZ4qJ4UQLnb.upO3R6cg6uBfZGrrB9G41BbI4BS993P0MOVOD67O6', '12345-6789012-3', 'Male', 0, 0, 0, NULL, NULL, NULL, NULL, '2025-09-29 21:41:57', '2025-09-29 21:41:57'),
(34, 'Driver', 'New Test User', 'newuser@example.com', '03001234580', '$2y$10$DH.B5b6OoBIS7aNjvZ4IrugFvh5meswYRGVEdOkfDvm5yzTWl7pMa', '12345-6789012-8', 'Male', 0, 0, 0, NULL, NULL, NULL, NULL, '2025-09-30 11:18:05', '2025-09-30 11:18:05'),
(32, 'Driver', 'tahoor', 'syedtahooraliprogrammer@gmail.com', '3868989898', '$2y$10$86u9H15hq7xOWWUaJbW4JOXXEgjfv.Jat7C4QKV1c/jJj44hBSxzq', '8758686565659', 'Female', 1, 0, 0, NULL, 'https://riderbackend.vexronics.com/storage/selfies/iTV3EIiYydCl57GQ66ta6OFYLaSi99NX9f22dy9A.jpg', '2025-09-28 14:05:20', NULL, '2025-09-28 14:04:52', '2025-09-28 14:05:20'),
(36, 'Rider', 'API Test User', 'apitest@example.com', '03001234590', '$2y$10$RP7KTzK4jJkfOkS8NYG1.ujEk3ChAwuuTJsr6XtGHBJ.qIZ.yXkqW', '12345-6789012-0', 'Male', 0, 0, 0, NULL, NULL, NULL, NULL, '2025-09-30 11:18:39', '2025-09-30 11:18:39'),
(37, 'Rider', 'Test User $(date +%s)', 'test$(date +%s)@example.com', '0300$(date +%s)', '$2y$10$JLMhhfbScccIzeN.wTd2KO17TqLrAGxuV1zDz77pgwDYFb8ObWiLW', '12345-6789012-$(date +%s)', 'Male', 0, 0, 0, NULL, NULL, NULL, NULL, '2025-09-30 11:21:21', '2025-09-30 11:21:21'),
(38, 'Rider', 'API Test User 1759231601', 'test1759231601@example.com', '03001759231601', '$2y$10$FZhbXz1.WJY97HfGHPdUXe1Sq2C2UODQf1rw1i53mb95XGKrwH65.', '12345-6789012-1759231601', 'Male', 0, 0, 0, NULL, NULL, NULL, NULL, '2025-09-30 11:26:42', '2025-09-30 11:26:42');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `otps`
--
ALTER TABLE `otps`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `otps`
--
ALTER TABLE `otps`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
