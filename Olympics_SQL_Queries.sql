-- 1. How many olympic games have been held?

USE Practice

SELECT COUNT( DISTINCT Games) AS total_games_held
FROM   olympic_history


-- 2. List down all Olympic games held so far.

SELECT DISTINCT 
       Games,
       City
FROM   olympic_history
ORDER  BY Games


-- 3. Mention the total no of nations who participated in each olympic games.

SELECT DISTINCT 
       Games,
       City,
       COUNT(DISTINCT NOC) AS number_of_nations_participating
FROM   olympic_history
GROUP  BY Games, City
ORDER  BY Games


-- 4. Which year saw the highest and lowest no of countries participating in the olympics?

WITH 
     nations_participating AS (
                               SELECT DISTINCT 
                                      Games,
                                      City,
                                      COUNT(DISTINCT NOC) AS number_of_nations_participating
                               FROM   olympic_history
                               GROUP  BY Games, City
                              )				   
SELECT Games,
       City,
	   number_of_nations_participating
FROM   nations_participating
WHERE  number_of_nations_participating IN (
                                          (SELECT MIN(number_of_nations_participating) FROM nations_participating),
                                          (SELECT MAX(number_of_nations_participating) FROM nations_participating) 
                                          )


-- 5. Which nation has participated in all of the olympic games?

-- How many olympics were held in total:

SELECT COUNT( DISTINCT Games) AS total_games_held
FROM   olympic_history

-- Nations that participated in all of the olympics: 

SELECT n.region,
       COUNT(DISTINCT o.Games) AS total_games_participated
FROM   olympic_history AS o
JOIN   noc_regions AS n 
ON     o.NOC = n.NOC
GROUP  BY n.region 
HAVING COUNT(DISTINCT Games) = 51

-- OR 

WITH 
     olympic_games_held AS (
                            SELECT COUNT( DISTINCT Games) AS total_games_held
                            FROM   olympic_history
							),

     games_participated AS (
                            SELECT DISTINCT 
                                   NOC,
                                   COUNT(DISTINCT Games) AS total_games_participated
                            FROM   olympic_history
                            GROUP  BY NOC
                            )	
SELECT n.region,
	   g.total_games_participated
FROM   games_participated AS g
JOIN   noc_regions AS n 
ON     g.NOC = n.NOC
JOIN   olympic_games_held AS o 
ON     g.total_games_participated = o.total_games_held


-- 6. Identify the sport which was played in all summer olympics.

-- How many summer olympics were held:

SELECT COUNT(DISTINCT Games) AS total_summer_olympics
FROM   olympic_history
WHERE  Season = 'Summer'

-- Sports played at all summer olympics:

SELECT Sport,
       COUNT(DISTINCT Games) AS total_olympics_played_at
FROM   olympic_history 
WHERE  Season = 'Summer'
GROUP  BY Sport
HAVING COUNT(DISTINCT Games) = 29

-- OR 

WITH 
    summer_olympics AS (
                        SELECT COUNT(DISTINCT Games) AS total_summer_olympics
                        FROM   olympic_history
                        WHERE  Season = 'Summer'
						),
    sports_played   AS (
	                    SELECT Sport,
                               COUNT(DISTINCT Games) AS total_olympics_played_at
                        FROM   olympic_history
				        GROUP  BY Sport
					    )
SELECT p.Sport,
       p.total_olympics_played_at
FROM   sports_played AS p 
JOIN   summer_olympics AS s 
ON     total_summer_olympics = total_olympics_played_at 


-- 7. Which Sports were just played once in the olympics?

SELECT Sport,
       COUNT(DISTINCT Games) AS total_olympics_played_at
FROM   olympic_history 
GROUP  BY Sport
HAVING COUNT(DISTINCT Games) = 1

-- 7.1 What olympics do they correspond to? 

WITH 
    sports_played AS (
	                  SELECT Sport,
                             COUNT(DISTINCT Games) AS total_olympics_played_at
                      FROM   olympic_history 
                      GROUP  BY Sport
					  HAVING COUNT(DISTINCT Games) = 1 
					  )
SELECT DISTINCT
       s.Sport,
       s. total_olympics_played_at,
	   o. Games,
	   o. City
FROM   sports_played AS s
JOIN   olympic_history AS o
ON     s.Sport = o.Sport


-- 8. Fetch the total number of sports played in each olympic games.

SELECT Games,
       COUNT(DISTINCT Sport) AS total_sports_played
FROM   olympic_history 
GROUP  BY Games
ORDER  BY total_sports_played DESC


-- 9. Fetch oldest athletes to win a gold medal.

WITH 
     gold_medals AS ( 
                     SELECT MAX(Age) AS Age
					 FROM   olympic_history
					 WHERE  Medal = 'Gold'
					 )
SELECT o.Name,
       o.Sex,
       o.Age,
	   o.Team,
	   o.Games,
	   o.City,
	   o.Sport,
	   o.Event,
	   o.Medal
FROM   olympic_history AS o
JOIN   gold_medals AS g
ON     o.Age = g.Age
WHERE  o.Medal = 'Gold'

-- OR 

SELECT Name,
       Sex,
       Age,
	   Team,
	   Games,
	   City,
	   Sport,
	   Event,
	   Medal
FROM   olympic_history
WHERE  Medal = 'Gold'
AND    Age = (
              SELECT MAX(Age) 
			  FROM   olympic_history
			  WHERE  Medal = 'Gold'
			  )


-- 10. Find the Ratio of female to male athletes that participated in all olympic games.

WITH 
     participants_by_sex AS (
                             SELECT CAST(SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END)AS FLOAT) AS female_participants,
				                    CAST(SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END)AS FLOAT) AS male_participants
							 FROM   olympic_history
							 )
SELECT CONCAT(female_participants/female_participants, ' : ', ROUND(male_participants/female_participants, 2)) AS ratio
FROM   participants_by_sex


-- 11. Fetch the top 5 athletes who have won the most gold medals.

SELECT TOP 5 
       Name,
       Team,
	   SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS total_gold_medals
FROM   olympic_history
GROUP  BY Name, Team
ORDER  BY total_gold_medals DESC


-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

SELECT TOP 5 
       Name,
       Team,
	   SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM   olympic_history
GROUP  BY Name, Team
ORDER  BY total_medals DESC


-- 13. Fetch the top 5 most successful countries in the olympics. Success is defined by no of medals won.

SELECT TOP 5
       n.region,
	   SUM(CASE WHEN o.Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM   olympic_history AS o
JOIN   noc_regions AS n
ON     o.NOC = n.NOC
GROUP  BY n.region
ORDER  BY total_medals DESC


-- 14. List down total gold, silver and bronze medals won by each country.

SELECT n.region, 
	   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
	   SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
	   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
FROM   olympic_history AS o
JOIN   noc_regions AS n
ON     o.NOC = n.NOC
GROUP  BY n.region
ORDER  BY gold DESC


-- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

SELECT o.Games,
       n.region, 
	   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
	   SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
	   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
FROM   olympic_history AS o
JOIN   noc_regions AS n
ON     o.NOC = n.NOC
GROUP  BY o.Games, n.region
ORDER  BY o.Games 


-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

WITH 
     medals AS (
                SELECT o.Games,
                       n.region, 
	                   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
	                   SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
	                   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
                FROM   olympic_history AS o
                JOIN   noc_regions AS n
                ON     o.NOC = n.NOC
                GROUP  BY o.Games, n.region
               )
SELECT DISTINCT 
	   Games,
       CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY gold DESC), ' - ' , first_value(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS max_gold,
	   CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY silver DESC), ' - ', first_value(silver) OVER(PARTITION BY games ORDER BY silver DESC)) AS max_silver,
	   CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY bronze DESC), ' - ', first_value(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)) AS max_bronze
FROM   medals
GROUP  BY Games, region, gold, silver, bronze


-- 17. Identify which country won the most gold, most silver, most bronze medals as well as the most medals in each olympic games.

WITH 
     medals AS (
                SELECT o.Games,
                       n.region, 
	                   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
	                   SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
	                   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze,
					   SUM(CASE WHEN o.Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
                FROM   olympic_history AS o
                JOIN   noc_regions AS n
                ON     o.NOC = n.NOC
                GROUP  BY o.Games, n.region
               )
SELECT DISTINCT 
       Games,
       CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY gold DESC), ' - ' , first_value(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS max_gold,
	   CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY silver DESC), ' - ' , first_value(silver) OVER(PARTITION BY games ORDER BY silver DESC)) AS max_silver,
	   CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY bronze DESC), ' - ' , first_value(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)) AS max_bronze,
	   CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY total_medals DESC), ' - ' , first_value(total_medals) OVER(PARTITION BY games ORDER BY total_medals DESC)) AS max_medals
FROM   medals
GROUP  BY Games, region, gold, silver, bronze, total_medals 


-- 18. Which countries have never a won gold medal but have won silver/bronze medals?

WITH 
     medals AS (
                SELECT n.region, 
	                   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
	                   SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
	                   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
                FROM   olympic_history AS o
                JOIN   noc_regions AS n
                ON     o.NOC = n.NOC
                GROUP  BY n.region
               )
SELECT DISTINCT
       region,
	   gold,
	   silver,
	   bronze
FROM   medals
WHERE  gold = 0
AND   (silver <> 0 OR bronze <> 0)
GROUP  BY region, gold, silver, bronze


-- 19. In which Sport/event has India won the most medals?

SELECT TOP 1
       Team AS Country,
       Sport,
       SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM   olympic_history 
WHERE  NOC = 'IND'
GROUP  BY Team, Sport
ORDER  BY total_medals DESC
    

-- 20. Break down all olympic games where India won a medal for Hockey, and show how many Hockey medals were won in each of those olympic games.

SELECT Games,
       Team AS Country,
	   Sport,
	   SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM   olympic_history
WHERE  NOC = 'IND'
AND    Sport = 'Hockey'
AND    Medal <> 'NA'
GROUP  BY Games, Team, Sport
ORDER  BY total_medals DESC
