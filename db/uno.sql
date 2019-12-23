-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Φιλοξενητής: 127.0.0.1
-- Χρόνος δημιουργίας: 23 Δεκ 2019 στις 17:54:34
-- Έκδοση διακομιστή: 10.4.8-MariaDB
-- Έκδοση PHP: 7.3.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Βάση δεδομένων: `uno`
--

DELIMITER $$
--
-- Διαδικασίες
--
DROP PROCEDURE IF EXISTS `clean_deck`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `clean_deck` ()  BEGIN
	REPLACE INTO remaining_deck SELECT * FROM deck;
    DELETE FROM hand;
    DELETE FROM table_deck;
    UPDATE player SET username=null, token=null, uno_status= 'not active';
    UPDATE game_status SET status='not active', p_turn=null, result=null;
END$$

DROP PROCEDURE IF EXISTS `do_move`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `do_move` (IN `table_card_color` ENUM('R','Y','B','G','W'), IN `table_card_symbol` ENUM('0','1','2','3','4','5','6','7','8','9','+4','+2','R','S','N'), IN `c_code` VARCHAR(3))  BEGIN
	DECLARE c_id TINYINT;
	DECLARE c_color ENUM('R','Y','B','G','W');
    DECLARE player_turn ENUM('p1', 'p2');
    DECLARE c_symbol ENUM('0','1','2','3','4','5','6','7','8','9','+4','+2','R','S','N');
    SELECT p_turn INTO player_turn FROM game_status;
    SELECT d.card_color, d.card_symbol, h.card_id into c_color, c_symbol, c_id FROM hand h INNER JOIN deck d on h.card_id=d.card_id WHERE d.card_code=c_code AND h.player_name=player_turn LIMIT 1;    
    IF c_symbol = 'S' THEN 
    	CALL skip_do_move(table_card_color, table_card_symbol, c_code, c_color, c_id, player_turn);
    ELSEIF c_symbol = 'R' THEN
    	CALL reverse_do_move(table_card_color, table_card_symbol, c_code, c_color, c_id, player_turn);
    ELSE
    	CALL regular_do_move(table_card_color, c_code, c_color, c_id, player_turn, table_card_symbol, c_symbol);
    END IF;
END$$

DROP PROCEDURE IF EXISTS `draw_card`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `draw_card` (IN `player_name` ENUM('p1','p2') CHARSET utf8)  BEGIN
    DECLARE d_counter smallint;
    SELECT draw_counter INTO d_counter FROM game_status LIMIT 1;
    IF d_counter = 0 THEN
    	CALL general_draw(player_name);
        UPDATE game_status SET draw_counter = 1;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `general_draw`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `general_draw` (IN `player` ENUM('p1','p2'))  BEGIN
	DECLARE c_id tinyint;
    DECLARE uno ENUM('active', 'not active');
    SELECT uno_status INTO uno FROM player WHERE player_name=player;
	SELECT card_id into c_id FROM remaining_deck ORDER BY RAND() LIMIT 1; 
	INSERT INTO hand VALUES (player, c_id);
	DELETE FROM remaining_deck WHERE card_id=c_id;
    IF uno='active' THEN
    	UPDATE player SET uno_status='not active' WHERE player_name=player;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `pass`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pass` ()  BEGIN
DECLARE player_turn ENUM('p1', 'p2');
DECLARE d_counter smallint;
SELECT draw_counter INTO d_counter FROM game_status LIMIT 1;
SELECT p_turn, draw_counter INTO player_turn, d_counter FROM game_status LIMIT 1;
IF d_counter = 1 THEN
    IF player_turn = 'p1' THEN
        UPDATE game_status SET p_turn='p2', draw_counter = 0;
    ELSEIF player_turn = 'p2' THEN
        UPDATE game_status SET p_turn='p1', draw_counter =0;
    END IF;
END IF;
END$$

DROP PROCEDURE IF EXISTS `regular_do_move`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `regular_do_move` (IN `t_color` ENUM('R','Y','B','G','W'), IN `c_code` VARCHAR(3), IN `c_color` ENUM('R','Y','B','G','W'), IN `c_id` TINYINT, IN `player_turn` ENUM('p1','p2'), IN `t_symbol` ENUM('0','1','2','3','4','5','6','7','8','9','+4','+2','R','S','N'), IN `c_symbol` ENUM('0','1','2','3','4','5','6','7','8','9','+4','+2','R','S','N'))  NO SQL
BEGIN
	IF c_color = t_color OR c_symbol = t_symbol THEN
    	INSERT INTO table_deck (card_code) VALUES (c_code);
        DELETE FROM hand WHERE player_name=player_turn AND card_id=c_id;
        IF player_turn = 'p1' THEN
        	UPDATE game_status SET p_turn='p2', draw_counter=0; 
        ELSE 
        	UPDATE game_status SET p_turn='p1', draw_counter=0; 
        END IF;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `reverse_do_move`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `reverse_do_move` (IN `t_color` ENUM('R','Y','B','G','W'), IN `t_symbol` ENUM('0','1','2','3','4','5','6','7','8','9','+4','+2','R','S','N'), IN `c_code` VARCHAR(3), IN `c_color` ENUM('R','Y','B','G','W'), IN `c_id` TINYINT, IN `player_turn` ENUM('p1','p2'))  NO SQL
BEGIN
	IF t_symbol='R' OR t_color=c_color THEN
        INSERT INTO table_deck (card_code) VALUES (c_code);
        DELETE FROM hand WHERE player_name=player_turn AND card_id=c_id;
        UPDATE game_status SET p_turn=player_turn; 
	END IF;
END$$

DROP PROCEDURE IF EXISTS `skip_do_move`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `skip_do_move` (IN `t_color` ENUM('R','Y','B','G','W'), IN `t_symbol` ENUM('0','1','2','3','4','5','6','7','8','9','+4','+2','R','S','N'), IN `c_code` VARCHAR(3), IN `c_color` ENUM('R','Y','B','G','W'), IN `c_id` TINYINT, IN `player_turn` ENUM('p1','p2'))  BEGIN
	IF t_symbol='S' OR t_color=c_color THEN
        INSERT INTO table_deck (card_code) VALUES (c_code);
        DELETE FROM hand WHERE player_name=player_turn AND card_id=c_id;
        UPDATE game_status SET p_turn=player_turn; 
	END IF;
END$$

DROP PROCEDURE IF EXISTS `start_cards`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `start_cards` (IN `player` ENUM('p1','p2') CHARSET utf8)  BEGIN
    CALL general_draw(player);
END$$

DROP PROCEDURE IF EXISTS `start_game`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `start_game` ()  BEGIN
DECLARE c_code varchar(3);
DECLARE p_name ENUM('p1', 'p2');
SELECT card_code INTO c_code FROM remaining_deck ORDER BY RAND() LIMIT 1;
ALTER TABLE table_deck AUTO_INCREMENT = 0;
INSERT INTO table_deck(card_code) VALUES (c_code);
DELETE FROM remaining_deck WHERE c_code = card_code;

END$$

DROP PROCEDURE IF EXISTS `uno_status`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `uno_status` ()  NO SQL
BEGIN 
	DECLARE usern varchar(20);
    DECLARE uno ENUM('active', 'not active');
	SELECT p.username, p.uno_status INTO usern, uno FROM game_status g inner join player p on p.player_name=g.p_turn;
    IF uno = 'not active' THEN
		UPDATE player SET uno_status='active' WHERE username=usern;
    ELSE 
    	UPDATE player SET uno_status='not active' WHERE username=usern;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `deck`
--

DROP TABLE IF EXISTS `deck`;
CREATE TABLE `deck` (
  `card_id` tinyint(4) NOT NULL,
  `card_symbol` enum('0','1','2','3','4','5','6','7','8','9','+4','+2','R','S','N') COLLATE utf8_bin NOT NULL,
  `card_color` enum('R','Y','B','G','W') COLLATE utf8_bin NOT NULL,
  `card_code` varchar(3) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Άδειασμα δεδομένων του πίνακα `deck`
--

INSERT INTO `deck` (`card_id`, `card_symbol`, `card_color`, `card_code`) VALUES
(1, '0', 'R', '0R'),
(2, '1', 'R', '1R'),
(3, '1', 'R', '1R'),
(4, '2', 'R', '2R'),
(5, '2', 'R', '2R'),
(6, '3', 'R', '3R'),
(7, '3', 'R', '3R'),
(8, '4', 'R', '4R'),
(9, '4', 'R', '4R'),
(10, '5', 'R', '5R'),
(11, '5', 'R', '5R'),
(12, '6', 'R', '6R'),
(13, '6', 'R', '6R'),
(14, '7', 'R', '7R'),
(15, '7', 'R', '7R'),
(16, '8', 'R', '8R'),
(17, '8', 'R', '8R'),
(18, '9', 'R', '9R'),
(19, '9', 'R', '9R'),
(20, '+2', 'R', '+2R'),
(21, '+2', 'R', '+2R'),
(22, 'R', 'R', 'RR'),
(23, 'R', 'R', 'RR'),
(24, 'S', 'R', 'SR'),
(25, 'S', 'R', 'SR'),
(26, '0', 'Y', '0Y'),
(27, '1', 'Y', '1Y'),
(28, '1', 'Y', '1Y'),
(29, '2', 'Y', '2Y'),
(30, '2', 'Y', '2Y'),
(31, '3', 'Y', '3Y'),
(32, '3', 'Y', '3Y'),
(33, '4', 'Y', '4Y'),
(34, '4', 'Y', '4Y'),
(35, '5', 'Y', '5Y'),
(36, '5', 'Y', '5Y'),
(37, '6', 'Y', '6Y'),
(38, '6', 'Y', '6Y'),
(39, '7', 'Y', '7Y'),
(40, '7', 'Y', '7Y'),
(41, '8', 'Y', '8Y'),
(42, '8', 'Y', '8Y'),
(43, '9', 'Y', '9Y'),
(44, '9', 'Y', '9Y'),
(45, '+2', 'Y', '+2Y'),
(46, '+2', 'Y', '+2Y'),
(47, 'R', 'Y', 'RY'),
(48, 'R', 'Y', 'RY'),
(49, 'S', 'Y', 'SY'),
(50, 'S', 'Y', 'SY'),
(51, '0', 'B', '0B'),
(52, '1', 'B', '1B'),
(53, '1', 'B', '1B'),
(54, '2', 'B', '2B'),
(55, '2', 'B', '2B'),
(56, '3', 'B', '3B'),
(57, '3', 'B', '3B'),
(58, '4', 'B', '4B'),
(59, '4', 'B', '4B'),
(60, '5', 'B', '5B'),
(61, '5', 'B', '5B'),
(62, '6', 'B', '6B'),
(63, '6', 'B', '6B'),
(64, '7', 'B', '7B'),
(65, '7', 'B', '7B'),
(66, '8', 'B', '8B'),
(67, '8', 'B', '8B'),
(68, '9', 'B', '9B'),
(69, '9', 'B', '9B'),
(70, '+2', 'B', '+2B'),
(71, '+2', 'B', '+2B'),
(72, 'R', 'B', 'RB'),
(73, 'R', 'B', 'RB'),
(74, 'S', 'B', 'SB'),
(75, 'S', 'B', 'SB'),
(76, '0', 'G', '0G'),
(77, '1', 'G', '1G'),
(78, '1', 'G', '1G'),
(79, '2', 'G', '2G'),
(80, '2', 'G', '2G'),
(81, '3', 'G', '3G'),
(82, '3', 'G', '3G'),
(83, '4', 'G', '4G'),
(84, '4', 'G', '4G'),
(85, '5', 'G', '5G'),
(86, '5', 'G', '5G'),
(87, '6', 'G', '6G'),
(88, '6', 'G', '6G'),
(89, '7', 'G', '7G'),
(90, '7', 'G', '7G'),
(91, '8', 'G', '8G'),
(92, '8', 'G', '8G'),
(93, '9', 'G', '9G'),
(94, '9', 'G', '9G'),
(95, '+2', 'G', '+2G'),
(96, '+2', 'G', '+2G'),
(97, 'R', 'G', 'RG'),
(98, 'R', 'G', 'RG'),
(99, 'S', 'G', 'SG'),
(100, 'S', 'G', 'SG'),
(101, '+4', 'W', '4W'),
(102, '+4', 'W', '4W'),
(103, '+4', 'W', '4W'),
(104, '+4', 'W', '4W'),
(105, 'N', 'W', 'NW'),
(106, 'N', 'W', 'NW'),
(107, 'N', 'W', 'NW'),
(108, 'N', 'W', 'NW');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `game_status`
--

DROP TABLE IF EXISTS `game_status`;
CREATE TABLE `game_status` (
  `status` enum('not active','initialized','started','ended','aborded') COLLATE utf8_bin NOT NULL DEFAULT 'not active',
  `p_turn` enum('p1','p2') COLLATE utf8_bin DEFAULT NULL,
  `draw_counter` smallint(6) NOT NULL DEFAULT 0,
  `result` enum('p1','p2','d') COLLATE utf8_bin DEFAULT NULL,
  `last_change` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Άδειασμα δεδομένων του πίνακα `game_status`
--

INSERT INTO `game_status` (`status`, `p_turn`, `draw_counter`, `result`, `last_change`) VALUES
('not active', NULL, 0, NULL, '2019-12-22 15:41:10');

--
-- Δείκτες `game_status`
--
DROP TRIGGER IF EXISTS `game_status_update`;
DELIMITER $$
CREATE TRIGGER `game_status_update` BEFORE UPDATE ON `game_status` FOR EACH ROW BEGIN
	set NEW.last_change = now();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `hand`
--

DROP TABLE IF EXISTS `hand`;
CREATE TABLE `hand` (
  `player_name` enum('p1','p2') COLLATE utf8_bin NOT NULL,
  `card_id` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Άδειασμα δεδομένων του πίνακα `hand`
--

INSERT INTO `hand` (`player_name`, `card_id`) VALUES
('p2', 1),
('p2', 6),
('p1', 17),
('p1', 19),
('p2', 36),
('p1', 43),
('p2', 48),
('p1', 50),
('p1', 67),
('p2', 76),
('p1', 81),
('p2', 83),
('p2', 87),
('p1', 100);

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `player`
--

DROP TABLE IF EXISTS `player`;
CREATE TABLE `player` (
  `player_name` enum('p1','p2') COLLATE utf8_bin NOT NULL,
  `username` varchar(20) COLLATE utf8_bin DEFAULT NULL,
  `uno_status` enum('active','not active') COLLATE utf8_bin NOT NULL DEFAULT 'not active',
  `token` varchar(32) COLLATE utf8_bin DEFAULT NULL,
  `last_action` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Άδειασμα δεδομένων του πίνακα `player`
--

INSERT INTO `player` (`player_name`, `username`, `uno_status`, `token`, `last_action`) VALUES
('p1', NULL, 'not active', NULL, '2019-12-22 15:41:09'),
('p2', NULL, 'not active', NULL, '2019-12-22 15:41:09');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `remaining_deck`
--

DROP TABLE IF EXISTS `remaining_deck`;
CREATE TABLE `remaining_deck` (
  `card_id` tinyint(4) NOT NULL,
  `card_symbol` enum('0','1','2','3','4','5','6','7','8','9','+4','+2','R','S','N') COLLATE utf8_bin NOT NULL,
  `card_color` enum('R','Y','B','G','W') COLLATE utf8_bin NOT NULL,
  `card_code` varchar(3) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Άδειασμα δεδομένων του πίνακα `remaining_deck`
--

INSERT INTO `remaining_deck` (`card_id`, `card_symbol`, `card_color`, `card_code`) VALUES
(2, '1', 'R', '1R'),
(3, '1', 'R', '1R'),
(4, '2', 'R', '2R'),
(5, '2', 'R', '2R'),
(7, '3', 'R', '3R'),
(8, '4', 'R', '4R'),
(9, '4', 'R', '4R'),
(10, '5', 'R', '5R'),
(11, '5', 'R', '5R'),
(12, '6', 'R', '6R'),
(13, '6', 'R', '6R'),
(14, '7', 'R', '7R'),
(15, '7', 'R', '7R'),
(16, '8', 'R', '8R'),
(18, '9', 'R', '9R'),
(20, '+2', 'R', '+2R'),
(21, '+2', 'R', '+2R'),
(22, 'R', 'R', 'RR'),
(23, 'R', 'R', 'RR'),
(24, 'S', 'R', 'SR'),
(25, 'S', 'R', 'SR'),
(26, '0', 'Y', '0Y'),
(27, '1', 'Y', '1Y'),
(28, '1', 'Y', '1Y'),
(29, '2', 'Y', '2Y'),
(30, '2', 'Y', '2Y'),
(31, '3', 'Y', '3Y'),
(32, '3', 'Y', '3Y'),
(33, '4', 'Y', '4Y'),
(34, '4', 'Y', '4Y'),
(35, '5', 'Y', '5Y'),
(37, '6', 'Y', '6Y'),
(38, '6', 'Y', '6Y'),
(39, '7', 'Y', '7Y'),
(40, '7', 'Y', '7Y'),
(41, '8', 'Y', '8Y'),
(42, '8', 'Y', '8Y'),
(44, '9', 'Y', '9Y'),
(45, '+2', 'Y', '+2Y'),
(46, '+2', 'Y', '+2Y'),
(47, 'R', 'Y', 'RY'),
(49, 'S', 'Y', 'SY'),
(51, '0', 'B', '0B'),
(52, '1', 'B', '1B'),
(53, '1', 'B', '1B'),
(54, '2', 'B', '2B'),
(55, '2', 'B', '2B'),
(56, '3', 'B', '3B'),
(57, '3', 'B', '3B'),
(58, '4', 'B', '4B'),
(59, '4', 'B', '4B'),
(60, '5', 'B', '5B'),
(61, '5', 'B', '5B'),
(62, '6', 'B', '6B'),
(63, '6', 'B', '6B'),
(64, '7', 'B', '7B'),
(65, '7', 'B', '7B'),
(66, '8', 'B', '8B'),
(68, '9', 'B', '9B'),
(69, '9', 'B', '9B'),
(70, '+2', 'B', '+2B'),
(71, '+2', 'B', '+2B'),
(74, 'S', 'B', 'SB'),
(75, 'S', 'B', 'SB'),
(77, '1', 'G', '1G'),
(78, '1', 'G', '1G'),
(79, '2', 'G', '2G'),
(80, '2', 'G', '2G'),
(82, '3', 'G', '3G'),
(84, '4', 'G', '4G'),
(85, '5', 'G', '5G'),
(86, '5', 'G', '5G'),
(88, '6', 'G', '6G'),
(89, '7', 'G', '7G'),
(90, '7', 'G', '7G'),
(91, '8', 'G', '8G'),
(92, '8', 'G', '8G'),
(93, '9', 'G', '9G'),
(94, '9', 'G', '9G'),
(95, '+2', 'G', '+2G'),
(96, '+2', 'G', '+2G'),
(97, 'R', 'G', 'RG'),
(98, 'R', 'G', 'RG'),
(99, 'S', 'G', 'SG'),
(101, '+4', 'W', '4W'),
(102, '+4', 'W', '4W'),
(103, '+4', 'W', '4W'),
(104, '+4', 'W', '4W'),
(105, 'N', 'W', 'NW'),
(106, 'N', 'W', 'NW'),
(107, 'N', 'W', 'NW'),
(108, 'N', 'W', 'NW');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `table_deck`
--

DROP TABLE IF EXISTS `table_deck`;
CREATE TABLE `table_deck` (
  `table_id` tinyint(4) NOT NULL,
  `card_code` varchar(3) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Άδειασμα δεδομένων του πίνακα `table_deck`
--

INSERT INTO `table_deck` (`table_id`, `card_code`) VALUES
(1, 'RB');

--
-- Ευρετήρια για άχρηστους πίνακες
--

--
-- Ευρετήρια για πίνακα `deck`
--
ALTER TABLE `deck`
  ADD PRIMARY KEY (`card_id`,`card_code`) USING BTREE;

--
-- Ευρετήρια για πίνακα `hand`
--
ALTER TABLE `hand`
  ADD PRIMARY KEY (`card_id`,`player_name`) USING BTREE,
  ADD KEY `player_name` (`player_name`);

--
-- Ευρετήρια για πίνακα `player`
--
ALTER TABLE `player`
  ADD PRIMARY KEY (`player_name`);

--
-- Ευρετήρια για πίνακα `remaining_deck`
--
ALTER TABLE `remaining_deck`
  ADD PRIMARY KEY (`card_id`,`card_code`);

--
-- Ευρετήρια για πίνακα `table_deck`
--
ALTER TABLE `table_deck`
  ADD PRIMARY KEY (`table_id`);

--
-- AUTO_INCREMENT για άχρηστους πίνακες
--

--
-- AUTO_INCREMENT για πίνακα `table_deck`
--
ALTER TABLE `table_deck`
  MODIFY `table_id` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Περιορισμοί για άχρηστους πίνακες
--

--
-- Περιορισμοί για πίνακα `hand`
--
ALTER TABLE `hand`
  ADD CONSTRAINT `card_id` FOREIGN KEY (`card_id`) REFERENCES `deck` (`card_id`) ON DELETE NO ACTION,
  ADD CONSTRAINT `player_name` FOREIGN KEY (`player_name`) REFERENCES `player` (`player_name`) ON DELETE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
