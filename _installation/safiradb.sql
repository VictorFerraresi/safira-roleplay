-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           5.6.20 - MySQL Community Server (GPL)
-- OS do Servidor:               Win32
-- HeidiSQL Versão:              8.3.0.4694
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Copiando estrutura do banco de dados para safiradb
CREATE DATABASE IF NOT EXISTS `safiradb` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `safiradb`;


-- Copiando estrutura para tabela safiradb.account
CREATE TABLE IF NOT EXISTS `account` (
  `id` int(5) NOT NULL AUTO_INCREMENT COMMENT 'ID único da conta',
  `username` varchar(32) NOT NULL COMMENT 'Nome de usuário',
  `password` varchar(129) NOT NULL COMMENT 'Senha da conta (Whirlpool)',
  `admin` int(4) NOT NULL DEFAULT '0' COMMENT 'Nível de administrador da conta',
  `level` int(4) NOT NULL DEFAULT '0' COMMENT 'O nível do usuário',
  `owner` int(5) NOT NULL COMMENT 'ID único da conta do UCP do dono deste personagem',
  `tutorial` int(1) NOT NULL COMMENT 'Se o player realizou o tutorial ou não',
  `skin` int(3) NOT NULL COMMENT 'ID da skin do usuário',
  `spawnX` double NOT NULL COMMENT 'Coordenada X do spawn do usuário',
  `spawnY` double NOT NULL COMMENT 'Coordenada Y do spawn do usuário',
  `spawnZ` double NOT NULL COMMENT 'Coordenada Z do spawn do usuário',
  `spawnR` double NOT NULL COMMENT 'Coordenada R do spawn do usuário',
  `factionid` int(2) NOT NULL COMMENT 'ID da facção do usuário',
  `factionrank` int(2) NOT NULL COMMENT 'Rank interno da facção do usuário',
  `rankname` varchar(40) NOT NULL COMMENT 'Nome do rank do player na fac''~ao',
  `mask` int(6) NOT NULL COMMENT 'ID da máscara do usuário',
  `money` int(15) NOT NULL COMMENT 'Quantia de dinheiro do usuário',
  `spawnloc` int(1) NOT NULL COMMENT 'Localização do spawn do usuário',
  `leavereason` int(1) NOT NULL COMMENT 'Motivo de desconexão do usuário',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

-- Copiando dados para a tabela safiradb.account: ~3 rows (aproximadamente)
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` (`id`, `username`, `password`, `admin`, `level`, `owner`, `tutorial`, `skin`, `spawnX`, `spawnY`, `spawnZ`, `spawnR`, `factionid`, `factionrank`, `rankname`, `mask`, `money`, `spawnloc`, `leavereason`) VALUES
	(1, 'Victor_Ferraresi', 'c7108e97fbd7c14175571f181f3e09c146b81efdb196559b8fa2a91f5720ac14b89e83c3a0a16ff3aa97316dad88b0997d4803c2f383bacc8e597946ebb0266e', 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0),
	(2, 'Vitor_Vasconcellos', 'c2616e374a6a262eee7fb1723a20e2513dc098c29477d9d7b60f0f79a729986cd1a5be4100dd4f6595fd012878aa3f984b1aa31c9a07821057e6309b63aac777', 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0),
	(3, 'Rene_Kasper', 'c2616e374a6a262eee7fb1723a20e2513dc098c29477d9d7b60f0f79a729986cd1a5be4100dd4f6595fd012878aa3f984b1aa31c9a07821057e6309b63aac777', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 0);
/*!40000 ALTER TABLE `account` ENABLE KEYS */;


-- Copiando estrutura para tabela safiradb.faction
CREATE TABLE IF NOT EXISTS `faction` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID único da facção',
  `type` int(2) DEFAULT NULL COMMENT 'Tipo da facção',
  `spawnX` double DEFAULT NULL COMMENT 'Coordenada X do spawn da facção',
  `spawnY` double DEFAULT NULL COMMENT 'Coordenada Y do spawn da facção',
  `spawnZ` double DEFAULT NULL COMMENT 'Coordenada Z do spawn da facção',
  `spawnR` double DEFAULT NULL COMMENT 'Coordenada R do spawn da facção',
  `equipX` double DEFAULT NULL COMMENT 'Coordenada X do armário da facção',
  `equipY` double DEFAULT NULL COMMENT 'Coordenada Y do armário da facção',
  `equipZ` double DEFAULT NULL COMMENT 'Coordenada Z do armário da facção',
  `name` varchar(50) DEFAULT NULL COMMENT 'Nome da facção',
  `acro` varchar(10) DEFAULT NULL COMMENT 'Acrônimo da facção',
  `bank` int(15) DEFAULT NULL COMMENT 'Quantia de dinheiro no cofre da facção',
  `color` int(15) DEFAULT NULL COMMENT 'Cor da facção',
  `maxranks` int(2) DEFAULT NULL COMMENT 'Quantidade dos ranks da facção',
  `startrank` int(2) DEFAULT NULL COMMENT 'Cargo de ingresso na facção',
  `togchat` int(1) DEFAULT NULL COMMENT 'Status do chat da facção',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Copiando dados para a tabela safiradb.faction: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `faction` DISABLE KEYS */;
/*!40000 ALTER TABLE `faction` ENABLE KEYS */;


-- Copiando estrutura para tabela safiradb.house
CREATE TABLE IF NOT EXISTS `house` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID único da casa',
  `doorX` double NOT NULL DEFAULT '0' COMMENT 'Coordenada X da entrada da casa',
  `doorY` double NOT NULL DEFAULT '0' COMMENT 'Coordenada Y da entrada da casa',
  `doorZ` double NOT NULL DEFAULT '0' COMMENT 'Coordenada Z da entrada da casa',
  `interiorX` double NOT NULL DEFAULT '0' COMMENT 'Coordenada X do interior da casa',
  `interiorY` double NOT NULL DEFAULT '0' COMMENT 'Coordenada Y do interior da casa',
  `interiorZ` double NOT NULL DEFAULT '0' COMMENT 'Coordenada Z do interior da casa',
  `owner` int(5) NOT NULL DEFAULT '0' COMMENT 'ID da tabela account que se refere ao dono da casa',
  `price` int(10) NOT NULL DEFAULT '0' COMMENT 'Preço da casa',
  `vw` int(10) NOT NULL DEFAULT '0' COMMENT 'Virtual World da casa',
  `int` int(10) NOT NULL DEFAULT '0' COMMENT 'Interior da casa',
  `level` int(3) NOT NULL DEFAULT '0' COMMENT 'Level necessário para a aquisição da casa',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Copiando dados para a tabela safiradb.house: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `house` DISABLE KEYS */;
/*!40000 ALTER TABLE `house` ENABLE KEYS */;


-- Copiando estrutura para tabela safiradb.logs
CREATE TABLE IF NOT EXISTS `logs` (
  `id` int(30) NOT NULL AUTO_INCREMENT COMMENT 'ID único do LOG',
  `user` int(4) NOT NULL DEFAULT '0' COMMENT 'ID da tabela Account do usuário que executou a ação',
  `target` int(4) NOT NULL DEFAULT '0' COMMENT 'ID da tabela Accont do usuário que recebeu a ação',
  `type` int(4) NOT NULL DEFAULT '0' COMMENT 'Tipo do LOG armazenado',
  `action` varchar(256) NOT NULL DEFAULT '0' COMMENT 'Ação que foi realizada e logada',
  `userip` varchar(26) NOT NULL DEFAULT '0' COMMENT 'Endereço de IP do usuário que executou a ação',
  `targetip` varchar(26) NOT NULL DEFAULT '0' COMMENT 'Endereço de IP do usuário que recebeu a ação',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Copiando dados para a tabela safiradb.logs: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
