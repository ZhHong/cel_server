
CREATE TABLE IF NOT EXISTS `platform_data` (
	`platform` varchar(50) NOT NULL,
	`log_date` date NOT NULL,
	`log_key` varchar(50) NOT NULL,
	`log_value` bigint(11) DEFAULT 0,
	PRIMARY KEY (`platform`,`log_date`,`log_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `daily_close_state` (
	`daily_date` date NOT NULL,
	`state` int(4) DEFAULT 0,
	PRIMARY KEY (`daily_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP PROCEDURE IF EXISTS `insert_log`;
CREATE PROCEDURE `insert_log`(IN `in_module` varchar(50),IN `in_platform` varchar(20),IN `in_server_id` bigint(11),IN `in_event_type` bigint(11),IN `in_username` varchar(32),IN `in_playerid` bigint(11),IN `in_level` int(4),
				IN `in_num_param1` bigint(11),IN `in_num_param2` bigint(11),IN `in_num_param3` bigint(11),IN `in_num_param4` bigint(11),IN `in_num_param5` bigint(11),IN `in_num_param6` bigint(11),IN `in_num_param7` bigint(11),IN `in_num_param8` bigint(11),IN `in_num_param9` bigint(11),IN `in_num_param10` bigint(11),
				IN `in_str_param1` varchar(255),IN `in_str_param2` varchar(255),IN `in_str_param3` varchar(255),IN `in_str_param4` varchar(255),IN `in_str_param5` varchar(255),IN `in_str_param6` varchar(255),IN `in_str_param7` varchar(255),IN `in_str_param8` varchar(255),IN  `in_str_param9` varchar(255),IN `in_str_param10` varchar(255))
BEGIN
	declare fieldclause varchar(1024) default '';
	declare valueclause varchar(10240) default '';
	declare insertflag int(4) default 0;

	SET @result =0;
	SET fieldclause = '`platform`,`server_id`,`event_type`,`last_insert_time`';
	SET valueclause = CONCAT("'",in_platform,"',",in_server_id,",",in_event_type,",UNIX_TIMESTAMP()");
	IF in_username>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`username`");
			SET valueclause = CONCAT(valueclause,",",in_username);
			SET insertflag = 1;
	END IF;
	IF in_playerid>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`playerid`");
			SET valueclause = CONCAT(valueclause,",",in_playerid);
			SET insertflag = 1;
	END IF;
	IF in_level>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`level`");
			SET valueclause = CONCAT(valueclause,",",in_level);
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param1)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param1`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param1 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param2)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param2`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param2 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param3)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param3`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param3 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param4)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param4`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param4 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param5)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param5`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param5 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param6)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param6`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param6 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param7)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param7`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param7 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param8)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param8`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param8 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param9)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param9`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param9 as char),"'");
			SET insertflag = 1;
	END IF;
	IF CHAR_LENGTH(in_str_param10)>0 THEN
			SET fieldclause = CONCAT(fieldclause,",`str_param10`");
			SET valueclause = CONCAT(valueclause,",'",CAST(in_str_param10 as char),"'");
			SET insertflag = 1;
	END IF;
	IF in_num_param1>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param1`");
			SET valueclause = CONCAT(valueclause,",",in_num_param1);
			SET insertflag = 1;
	END IF;
	IF in_num_param2>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param2`");
			SET valueclause = CONCAT(valueclause,",",in_num_param2);
			SET insertflag = 1;
	END IF;
	IF in_num_param3>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param3`");
			SET valueclause = CONCAT(valueclause,",",in_num_param3);
			SET insertflag = 1;
	END IF;
	IF in_num_param4>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param4`");
			SET valueclause = CONCAT(valueclause,",",in_num_param4);
			SET insertflag = 1;
	END IF;
	IF in_num_param5>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param5`");
			SET valueclause = CONCAT(valueclause,",",in_num_param5);
			SET insertflag = 1;
	END IF;
	IF in_num_param6>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param6`");
			SET valueclause = CONCAT(valueclause,",",in_num_param6);
			SET insertflag = 1;
	END IF;
	IF in_num_param7>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param7`");
			SET valueclause = CONCAT(valueclause,",",in_num_param7);
			SET insertflag = 1;
	END IF;
	IF in_num_param8>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param8`");
			SET valueclause = CONCAT(valueclause,",",in_num_param8);
			SET insertflag = 1;
	END IF;
	IF in_num_param9>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param9`");
			SET valueclause = CONCAT(valueclause,",",in_num_param9);
			SET insertflag = 1;
	END IF;
	IF in_num_param10>=0 THEN
			SET fieldclause = CONCAT(fieldclause,",`num_param10`");
			SET valueclause = CONCAT(valueclause,",",in_num_param10);
			SET insertflag = 1;
	END IF;
	
	IF insertflag <> 0 THEN
			SET @sql = CONCAT("insert `",in_module,"` (",fieldclause,") values(",valueclause,")");
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
	END IF;
	SET @result =1;

END;


DROP PROCEDURE IF EXISTS `create_table`;
CREATE PROCEDURE `create_table`(IN `in_module` varchar(50))
BEGIN
	declare createsql varchar(10240) default '';
	SET @result = 0;
	SET createsql = CONCAT("CREATE TABLE IF NOT EXISTS `", in_module,"` (
		`idx`  int(11) NOT NULL AUTO_INCREMENT ,
		`platform` varchar(20) NULL DEFAULT '',
		`username` varchar(32) DEFAULT '',
		`server_id`  int(11) NULL DEFAULT NULL ,
		`event_type`  int(11) NULL DEFAULT NULL ,
		`uid`  bigint(11) NULL DEFAULT NULL ,
		`playerid`  int(11) NULL DEFAULT NULL ,
		`level` int(4) DEFAULT 0,
		`str_param1`  varchar(255) NULL DEFAULT NULL ,
		`str_param2`  varchar(255) NULL DEFAULT NULL ,
		`str_param3`  varchar(255) NULL DEFAULT NULL ,
		`str_param4`  varchar(255) NULL DEFAULT NULL ,
		`str_param5`  varchar(255) NULL DEFAULT NULL ,
		`str_param6`  varchar(255) NULL DEFAULT NULL ,
		`str_param7`  varchar(255) NULL DEFAULT NULL ,
		`str_param8`  varchar(255) NULL DEFAULT NULL ,
		`str_param9`  varchar(255) NULL DEFAULT NULL ,
		`str_param10`  varchar(255) NULL DEFAULT NULL ,
		`num_param1`  bigint(20) NULL DEFAULT NULL ,
		`num_param2`  bigint(20) NULL DEFAULT NULL ,
		`num_param3`  bigint(20) NULL DEFAULT NULL ,
		`num_param4`  bigint(20) NULL DEFAULT NULL ,
		`num_param5`  bigint(20) NULL DEFAULT NULL ,
		`num_param6`  bigint(20) NULL DEFAULT NULL ,
		`num_param7`  bigint(20) NULL DEFAULT NULL ,
		`num_param8`  bigint(20) NULL DEFAULT NULL ,
		`num_param9`  bigint(20) NULL DEFAULT NULL ,
		`num_param10`  bigint(20) NULL DEFAULT NULL ,
		`last_insert_time`  bigint(20) NULL DEFAULT NULL ,
		PRIMARY KEY (`idx`)
	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;");
	SET @sql = createsql;
	PREPARE stmt FROM @sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;		
END;


DROP PROCEDURE IF EXISTS daily_close;
CREATE PROCEDURE daily_close(IN opendate varchar(20))
BEGIN
	SELECT daily_date,state INTO @daily_date,@state FROM daily_close_state ORDER BY daily_date DESC LIMIT 1;
	IF IFNULL(@daily_date,'') = '' THEN
		SET @daily_date =  str_to_date(opendate,'%Y-%m-%d');
		SET @state = 0;
		REPLACE INTO daily_close_state SET daily_date=@daily_date,state=@state;
	END IF;
	WHILE (@daily_date < CURRENT_DATE()) DO
		SET @daily_time = UNIX_TIMESTAMP(@daily_date);			
		CASE 
			WHEN @state = 0 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'reg',count(1) FROM uid_log WHERE 1 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;				
				SET @state = 1;
			WHEN @state =1 THEN				
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'login',count(DISTINCT(playerId)) FROM player_login WHERE 1 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;
				SET @state = 2;
			WHEN @state = 2 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'login_times',count(1) FROM player_login WHERE 1 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;				
				SET @state = 3;			
			WHEN @state = 3 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'login_times',count(1) FROM player_login WHERE 1 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;				
				SET @state = 4;
			WHEN @state = 4 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'device_reg',count(1) FROM device_reg_log WHERE 1 AND regtime>=@daily_time AND regtime<@daily_time+86400 GROUP BY platform;				
				SET @state = 5;			
			WHEN @state =5 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'device_login',count(DISTINCT(str_param3)) FROM player_login WHERE 1 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;
				SET @state = 6;
			WHEN @state =6 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'online_time',avg(IFNULL(num_param2,0)) FROM player_login WHERE 1 AND event_type=21 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;
				SET @state = 7;
			WHEN @state =7 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'pay_amount',sum(IFNULL(num_param1,0)) FROM pay_log WHERE 1 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;
				SET @state = 8;
			WHEN @state =8 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'pay_playernum',count(DISTINCT(playerId)) FROM pay_log WHERE 1 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;
				SET @state = 9;
			WHEN @state =9 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'pay_new',count(1) FROM pay_log WHERE 1 AND num_param2=1 AND last_insert_time>=@daily_time AND last_insert_time<@daily_time+86400 GROUP BY platform;
				SET @state = 10;
			WHEN @state =10 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'reg_total',count(DISTINCT(playerId)) FROM uid_log WHERE 1 AND last_insert_time<@daily_time+86400 GROUP BY platform;
				SET @state = 11;
			WHEN @state =11 THEN
				REPLACE INTO platform_data (platform,log_date,log_key,log_value)
				SELECT platform,@daily_date,'pay_total',count(DISTINCT(playerId)) FROM pay_log WHERE 1 AND last_insert_time<@daily_time+86400 GROUP BY platform;
				SET @state = 99;
			WHEN @state = 99 THEN
				SET @daily_date = DATE_ADD(@daily_date,INTERVAL 1 DAY);
				SET @state = 0;
		END CASE;
		REPLACE INTO daily_close_state SET daily_date=@daily_date,state=@state;
	END WHILE;
END;


DROP PROCEDURE IF EXISTS `add_player_login`;
CREATE PROCEDURE `add_player_login`(IN `in_platform` varchar(20),IN `in_server_id` bigint(11),IN `in_event_type` bigint(11),IN `in_username` varchar(32),IN `in_playerid` bigint(11),IN `in_level` int(4),IN `in_num_param1` bigint(11),IN `in_num_param2` bigint(11),IN `in_num_param3` bigint(11),IN `in_num_param4` bigint(11),IN `in_num_param5` bigint(11),IN `in_num_param6` bigint(11),IN `in_num_param7` bigint(11),IN `in_num_param8` bigint(11),IN `in_num_param9` bigint(11),IN `in_num_param10` bigint(11),IN `in_str_param1` varchar(255),IN `in_str_param2` varchar(255),IN `in_str_param3` varchar(255),IN `in_str_param4` varchar(255),IN `in_str_param5` varchar(255),IN `in_str_param6` varchar(255),IN `in_str_param7` varchar(255),IN `in_str_param8` varchar(255),IN  `in_str_param9` varchar(255),IN `in_str_param10` varchar(255))
BEGIN
	INSERT `player_login` (platform,username,server_id,playerid,level,event_type,last_insert_time,str_param1,str_param2,str_param3,str_param4,str_param5,str_param6,str_param7,str_param8,str_param9,str_param10,num_param1,num_param2,num_param3,num_param4,num_param5,num_param6,num_param7,num_param8,num_param9,num_param10)
	VALUES(in_platform,in_username,in_server_id,in_playerid,in_level,in_event_type,UNIX_TIMESTAMP(),in_str_param1,in_str_param2,in_str_param3,in_str_param4,in_str_param5,in_str_param6,in_str_param7,in_str_param8,in_str_param9,in_str_param10,in_num_param1,in_num_param2,in_num_param3,in_num_param4,in_num_param5,in_num_param6,in_num_param7,in_num_param8,in_num_param9,in_num_param10);
	IF in_event_type = 21 THEN
		IF IFNULL(in_str_param3,'') <> '' THEN	
			SELECT count(1) INTO @is_reg FROM device_reg_log WHERE platform=in_platform and deviceid=in_str_param3;
			IF @is_reg = 0 THEN
				REPLACE INTO device_reg_log SET device_system=in_str_param2,deviceid=in_str_param3,device_appid=in_str_param4,platform=in_platform,username=in_username,server_id=in_server_id,playerid=in_playerid,regtime=UNIX_TIMESTAMP();
			END IF;
		END IF;
	END IF;
END;
