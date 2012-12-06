-- (c) jwm/foundry ALL RIGHTS RESERVED
-- MySQL dump 10.11
--
-- Host: localhost    Database: test
-- ------------------------------------------------------
-- Server version	5.0.92-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `import`
--

DROP TABLE IF EXISTS `import`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `import` (
  `message_id` int(10) NOT NULL auto_increment,
  `date` date default NULL,
  `time` time default NULL,
  `number` varchar(255) default NULL,
  `sender` varchar(255) default NULL,
  `message` text,
  PRIMARY KEY  (`message_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37184 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `import`
--

LOCK TABLES `import` WRITE;
/*!40000 ALTER TABLE `import` DISABLE KEYS */;
INSERT INTO `import` VALUES (10,'2001-02-23','14:18:46','','Jai','hey trace-wordup! hows yor wk in Lndn bin? i came bk on mon& tis a rite slog since - wish i woz down there! wen u bck? speak l8r'),(11,'2001-02-23','17:56:00','','Dz','VIC COACH STATION SAT IN PUB WAITING 4 COACH BACK IN LON ON SUN'),(12,'2001-02-23','18:03:30','','Carol','NOT A LOT! RU IN MANCHESTER?'),(13,'2001-02-23','18:03:56','','Jai','Wickdwickdwickd!!'),(14,'2001-02-23','18:25:12','','','NOT 2 MUCH SERIOUS TALKING! IT\'S BIZARRE, HE\'S HERE NOW - WAS ILL ON HIS WAY 2 WORK & HAS STAYED. TALK MORE SOON'),(15,'2001-03-21','18:54:39','','Nk','ON A STEPLADDER!'),(16,'2001-03-21','19:02:33','','Kurt','and u r ?'),(17,'2001-03-26','12:46:40','','Dz','COOL, HOW\'S LIFE TREATING U?'),(18,'2001-03-26','12:56:27','','Dz','WELL DONE TO J ROB SAID WELL DONE AS WELL U GOING 2 LONDON 4 GOOD? IF SO WHEN?'),(19,'2001-03-26','13:03:07','','Dz','YEA IT\'LL COME RIGHT NO SWEAT'),(20,'2001-03-26','15:09:52','','Carol','christening ok, got throught day! enjoy meal? speak later? C');
/*!40000 ALTER TABLE `people` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `test_table`
--

DROP TABLE IF EXISTS `test_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `test_table` (
  `message_id` int(11) NOT NULL auto_increment,
  `date` date default NULL,
  `time` time default NULL,
  `number` varchar(255) default NULL,
  `sender` varchar(255) default NULL,
  `message` text,
  PRIMARY KEY  (`message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test_table`
--

LOCK TABLES `test_table` WRITE;
/*!40000 ALTER TABLE `test_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `test_table` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2012-06-10 22:53:26
