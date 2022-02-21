# Olympic_Games
Practicing SQL by Solving tefchTFQ's 20 SQL queries on Olympic Games data. 

---

#### ❔ The Questions 
- [techTFQ's Blog](https://techtfq.com/blog/practice-writing-sql-queries-using-real-dataset)

#### 📈 The Dataset
- [Kaggle](https://www.kaggle.com/heesoo37/120-years-of-olympic-history-athletes-and-results)

#### 💻 Tools Used
- Microsoft SQL Server

#### 🔗 Links
- SQL Code = [Click Here For SQL File](https://github.com/EnyaCrocock/Olympic_Games/blob/main/Olympics_SQL_Queries.sql) 

---

## Downloading and Importing Data
- olympic_history table:

  ![image](https://user-images.githubusercontent.com/94410139/155007818-7000e9cf-d577-4f69-919b-1043fa1b6a10.png)

- noc_regions table:

  ![image](https://user-images.githubusercontent.com/94410139/155008021-3d85fca6-fcf6-4977-a33a-596f812c7312.png)

## SQL Queries
Screen shots don't always show all the records 

```sql
-- 1. How many olympic games have been held?

SELECT COUNT( DISTINCT Games) AS total_games_held
FROM   olympic_history
```
 ![image](https://user-images.githubusercontent.com/94410139/155008264-ffc4f175-50bb-49be-be69-e33dc28ee5da.png)

```sql
-- 2. List down all the Olympic games held so far.

SELECT DISTINCT 
       Games,
       City
FROM   olympic_history
ORDER  BY Games
```
![image](https://user-images.githubusercontent.com/94410139/155008509-737832ea-de03-48da-9e7e-f7d66976ac0e.png)

```sql
-- 3. Mention the total number of nations who participated in each olympic games.

SELECT DISTINCT 
       Games,
       City,
       COUNT(DISTINCT NOC) AS number_of_nations_participating
FROM   olympic_history
GROUP  BY Games, City
ORDER  BY Games
```
![image](https://user-images.githubusercontent.com/94410139/155008992-20e3a3c6-fdb5-4a78-bb67-d0349d1d524b.png)


```sql
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
```
![image](https://user-images.githubusercontent.com/94410139/155009424-d9b8f2ef-59fa-481a-ad0c-3611654e66f2.png)

```sql
-- 5. Which nation has participated in all of the olympic games?
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
```
![image](https://user-images.githubusercontent.com/94410139/155009840-0a1508d8-5cd0-4bac-9f34-b9d907fa5359.png)

```sql
-- 6. Identify the sport which was played in all summer olympics.

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
```
![image](https://user-images.githubusercontent.com/94410139/155010707-1f2f6ff3-b916-4272-9c33-e365d52a2861.png)

```sql
-- 7. Which Sports were just played once in the olympics?

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
```
![image](https://user-images.githubusercontent.com/94410139/155011206-6bacac6a-5123-4e9c-a17f-81a2ebcd3650.png)

```sql
-- 8. Fetch the total number of sports played in each olympic games.

SELECT Games,
       COUNT(DISTINCT Sport) AS total_sports_played
FROM   olympic_history 
GROUP  BY Games
ORDER  BY total_sports_played DESC
```
![image](https://user-images.githubusercontent.com/94410139/155011404-cc7b9c29-6a33-4a41-b51e-898a5ae3f925.png)

```sql
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
```
![image](https://user-images.githubusercontent.com/94410139/155011803-8fe663ea-cab9-41a7-9e37-6ac396d64a3e.png)

```sql
-- 10. Find the Ratio of female to male athletes that participated in all olympic games.

WITH 
     participants_by_sex AS (
                             SELECT CAST(SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END)AS FLOAT) AS female_participants,
                                    CAST(SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END)AS FLOAT) AS male_participants
                             FROM   olympic_history
                             )
SELECT CONCAT(female_participants/female_participants, ' : ', ROUND(male_participants/female_participants, 2)) AS ratio
FROM   participants_by_sex
```
![image](https://user-images.githubusercontent.com/94410139/155012053-928f2fda-c264-4c3a-8284-cac9e2da4793.png)

```sql
-- 11. Fetch the top 5 athletes who have won the most gold medals.

SELECT TOP 5 
       Name,
       Team,
       SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS total_gold_medals
FROM   olympic_history
GROUP  BY Name, Team
ORDER  BY total_gold_medals DESC
```
![image](https://user-images.githubusercontent.com/94410139/155012213-1906ec51-096b-4af4-9b44-fb1cdb76c198.png)

```sql
-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

SELECT TOP 5 
       Name,
       Team,
       SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM   olympic_history
GROUP  BY Name, Team
ORDER  BY total_medals DESC
```
![image](https://user-images.githubusercontent.com/94410139/155012358-2707ca3b-408c-4e5d-8bd5-d8199a49a035.png)

```sql
-- 13. Fetch the top 5 most successful countries in the olympics. Success is defined by no of medals won.

SELECT TOP 5
       n.region AS Country,
       SUM(CASE WHEN o.Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM   olympic_history AS o
JOIN   noc_regions AS n
ON     o.NOC = n.NOC
GROUP  BY n.region
ORDER  BY total_medals DESC
```
![image](https://user-images.githubusercontent.com/94410139/155012706-5c7f5774-a164-40ea-b0cd-f481c3ec1cf0.png)

```sql
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
```
![image](https://user-images.githubusercontent.com/94410139/155012865-1aa98559-bfda-4182-bdcf-0a3f7ef6a456.png)

```sql
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
```
![image](https://user-images.githubusercontent.com/94410139/155013017-18a4c545-d441-4ec1-9d44-6ba97be07711.png)

```sql
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
```
![image](https://user-images.githubusercontent.com/94410139/155013412-6c9b6a38-58b0-49f4-a410-a7cc25949e7d.png)


```sql
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
       CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY silver DESC), ' - ', first_value(silver) OVER(PARTITION BY games ORDER BY silver DESC)) AS max_silver,
       CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY bronze DESC), ' - ', first_value(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)) AS max_bronze,
       CONCAT (first_value(region) OVER(PARTITION BY games ORDER BY total_medals DESC), ' - ' , first_value(total_medals) OVER(PARTITION BY games ORDER BY total_medals DESC)) AS max_medals
FROM   medals
GROUP  BY Games, region, gold, silver, bronze, total_medals 
```
![image](https://user-images.githubusercontent.com/94410139/155013662-74afedf3-886f-4542-addd-58e913bbc07b.png)

```sql
-- 18. Which countries have never won a gold medal but have won silver/bronze medals?

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
```
![image](https://user-images.githubusercontent.com/94410139/155013871-bc1ea20e-3cd5-41b1-9c41-04fcfefeb2a7.png)

```sql
-- 19. In which Sport/event has India won the most medals?

SELECT TOP 1
       Team AS Country,
       Sport,
       SUM(CASE WHEN Medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM   olympic_history 
WHERE  NOC = 'IND'
GROUP  BY Team, Sport
ORDER  BY total_medals DESC
```
![image](https://user-images.githubusercontent.com/94410139/155013948-ba4ef07a-cbeb-4df6-b082-abeff2c9cd91.png)

```sql
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
```
![image](https://user-images.githubusercontent.com/94410139/155014090-75374bc9-457d-47ce-93aa-7b4149978e5f.png)
