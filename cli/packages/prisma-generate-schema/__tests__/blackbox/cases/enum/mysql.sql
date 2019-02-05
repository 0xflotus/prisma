-- MySQL dump 10.17  Distrib 10.3.12-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: schema-generator@enum
-- ------------------------------------------------------
-- Server version	5.7.23

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `A`
--

DROP TABLE IF EXISTS `A`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `A` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `fieldA` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fieldB` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `updatedAt` datetime(3) NOT NULL,
  `createdAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `AWithId`
--

DROP TABLE IF EXISTS `AWithId`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `AWithId` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `fieldA` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fieldB` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `updatedAt` datetime(3) NOT NULL,
  `createdAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `AWithId_fieldC`
--

DROP TABLE IF EXISTS `AWithId_fieldC`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `AWithId_fieldC` (
  `nodeId` char(25) CHARACTER SET utf8 NOT NULL,
  `position` int(4) NOT NULL,
  `value` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`nodeId`,`position`),
  KEY `value` (`value`),
  CONSTRAINT `AWithId_fieldC_ibfk_1` FOREIGN KEY (`nodeId`) REFERENCES `AWithId` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `A_fieldC`
--

DROP TABLE IF EXISTS `A_fieldC`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `A_fieldC` (
  `nodeId` char(25) CHARACTER SET utf8 NOT NULL,
  `position` int(4) NOT NULL,
  `value` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`nodeId`,`position`),
  KEY `value` (`value`),
  CONSTRAINT `A_fieldC_ibfk_1` FOREIGN KEY (`nodeId`) REFERENCES `A` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `B`
--

DROP TABLE IF EXISTS `B`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `B` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `field` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `updatedAt` datetime(3) NOT NULL,
  `createdAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `C`
--

DROP TABLE IF EXISTS `C`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `C` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `updatedAt` datetime(3) NOT NULL,
  `createdAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `C_field`
--

DROP TABLE IF EXISTS `C_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `C_field` (
  `nodeId` char(25) CHARACTER SET utf8 NOT NULL,
  `position` int(4) NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`nodeId`,`position`),
  KEY `value` (`value`),
  CONSTRAINT `C_field_ibfk_1` FOREIGN KEY (`nodeId`) REFERENCES `C` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `D`
--

DROP TABLE IF EXISTS `D`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `D` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `updatedAt` datetime(3) NOT NULL,
  `createdAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `D_field`
--

DROP TABLE IF EXISTS `D_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `D_field` (
  `nodeId` char(25) CHARACTER SET utf8 NOT NULL,
  `position` int(4) NOT NULL,
  `value` datetime(3) NOT NULL,
  PRIMARY KEY (`nodeId`,`position`),
  KEY `value` (`value`),
  CONSTRAINT `D_field_ibfk_1` FOREIGN KEY (`nodeId`) REFERENCES `D` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `E`
--

DROP TABLE IF EXISTS `E`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `E` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `field` mediumtext COLLATE utf8mb4_unicode_ci,
  `updatedAt` datetime(3) NOT NULL,
  `createdAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_AToB`
--

DROP TABLE IF EXISTS `_AToB`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_AToB` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `A` char(25) CHARACTER SET utf8 NOT NULL,
  `B` char(25) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `AB_unique` (`A`,`B`),
  KEY `A` (`A`),
  KEY `B` (`B`),
  CONSTRAINT `_AToB_ibfk_1` FOREIGN KEY (`A`) REFERENCES `A` (`id`) ON DELETE CASCADE,
  CONSTRAINT `_AToB_ibfk_2` FOREIGN KEY (`B`) REFERENCES `B` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_AToE`
--

DROP TABLE IF EXISTS `_AToE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_AToE` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `A` char(25) CHARACTER SET utf8 NOT NULL,
  `B` char(25) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `AB_unique` (`A`,`B`),
  KEY `A` (`A`),
  KEY `B` (`B`),
  CONSTRAINT `_AToE_ibfk_1` FOREIGN KEY (`A`) REFERENCES `A` (`id`) ON DELETE CASCADE,
  CONSTRAINT `_AToE_ibfk_2` FOREIGN KEY (`B`) REFERENCES `E` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_AWithIdToC`
--

DROP TABLE IF EXISTS `_AWithIdToC`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_AWithIdToC` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `A` char(25) CHARACTER SET utf8 NOT NULL,
  `B` char(25) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `AB_unique` (`A`,`B`),
  KEY `A` (`A`),
  KEY `B` (`B`),
  CONSTRAINT `_AWithIdToC_ibfk_1` FOREIGN KEY (`A`) REFERENCES `AWithId` (`id`) ON DELETE CASCADE,
  CONSTRAINT `_AWithIdToC_ibfk_2` FOREIGN KEY (`B`) REFERENCES `C` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_AWithIdToD`
--

DROP TABLE IF EXISTS `_AWithIdToD`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_AWithIdToD` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `A` char(25) CHARACTER SET utf8 NOT NULL,
  `B` char(25) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `AB_unique` (`A`,`B`),
  KEY `A` (`A`),
  KEY `B` (`B`),
  CONSTRAINT `_AWithIdToD_ibfk_1` FOREIGN KEY (`A`) REFERENCES `AWithId` (`id`) ON DELETE CASCADE,
  CONSTRAINT `_AWithIdToD_ibfk_2` FOREIGN KEY (`B`) REFERENCES `D` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_RelayId`
--

DROP TABLE IF EXISTS `_RelayId`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `_RelayId` (
  `id` char(25) CHARACTER SET utf8 NOT NULL,
  `stableModelIdentifier` char(25) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-02-05  9:56:08
