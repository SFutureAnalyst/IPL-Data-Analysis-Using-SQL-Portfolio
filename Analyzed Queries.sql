-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ====================================================================================== IPL DATA ANALYSIS ==============================================================================================
-- ========================================================================================= MySQL =======================================================================================================

-- SELECTION OF DATABASE .
	 USE ipl;
     
-- VIEWING THE TABLES THAT ARE PRESENTED IN THE IPL DATABASE.
	SHOW TABLES;   # 2 TABLES.
   
-- SEEING 1st TABLE IN IPL DATABASE.
	
    SELECT * FROM Matches;
    
-- SEEING 2nd TABLE IN THE IPL DATABASE.

	SELECT * FROM deliveries;
    
-- ========================================================================== ANALYIS STARTS FROM HERE =================================================================================================

-- QUESTIONS.

--  WHAT ARE THE TOP 5 PLAYERS WITH THE MOST PLAYER OF THE MATCH AWARDS?

	SELECT * FROM matches;
    
    SELECT player_of_match, COUNT(*) as Match_Awards 
    FROM matches
    GROUP BY player_of_match
    ORDER BY Match_Awards DESC
    LIMIT 5;
    
-- HOW MANY MATCHES WERE WON BY EACH TEAM IN EACH SEASON?

	SELECT * FROM matches;
    
    SELECT season,winner as team, COUNT(*) as Match_Won 
    FROM matches
    GROUP BY season,winner;
    
-- WHAT IS THE AVERAGE STRIKE RATE OF BATSMEN IN THE IPL DATASET?

	SELECT * FROM deliveries;
    
    SELECT AVG(strike_rate) as  Average_Strike_Rate
    FROM(
    SELECT batsman,(SUM(total_runs) / COUNT(ball)) * 100 as strike_rate
    FROM deliveries
    GROUP BY batsman) as Batsman_Status;
    
-- WHAT IS THE NUMBER OF MATCHES WON BY EACH TEAM BATTING FIRST VERSUS BATTING SECOND?

	SELECT * FROM matches;
    
    SELECT batting_first, COUNT(*) as Matches_won
    FROM( SELECT case when win_by_runs>0 then team1
		  else team2 end as batting_first
          FROM matches
          WHERE winner != "Tie") as batting_first_teams
          GROUP BY batting_first ;
          

-- WHICH BATSMAN HAS THE HIGHEST STRIKE RATE (MINIMUM 200 RUNS SCORED)?

	SELECT * FROM  deliveries;
    
    SELECT batsman,(SUM(batsman_runs)*100/COUNT(*)) as Strike_rate
    FROM deliveries
    GROUP BY batsman
    HAVING SUM(batsman_runs) >= 200
    ORDER BY Strike_rate DESC
    LIMIT 1;
    
-- HOW MANY TIMES HAS EACH BATSMAN BEEN DISMISSED BY THE BOWLER 'MALINGA'?

	SELECT * FROM deliveries;
    
    SELECT batsman,COUNT(*) as Total_Dismissals
    FROM deliveries
    WHERE player_dismissed IS NOT NULL AND bowler = 'SL MALINGA'
    GROUP BY batsman;
    

-- WHAT IS THE AVERAGE PERCENTAGE OF BOUNDARIES (FOURS AND SIXES COMBINED) HIT BY EACH BATSMAN?
    
    SELECT batsman ,AVG(CASE WHEN batsman_runs = 4 or batsman_runs = 6 THEN 1 ELSE 0 END) * 100 as Average_Boundaries
    FROM deliveries 
    GROUP BY batsman;
    
-- WHAT IS THE AVERAGE NUMBER OF BOUNDARIES HIT BY EACH TEAM IN EACH SEASON?

	SELECT * FROM matches;
    
    SELECT season,batting_team,AVG(fours+sixes) as Average_Boundaries
    FROM(SELECT Season,match_id,batting_team,SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END) as fours,
          SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END) as sixes
          FROM deliveries,matches
          WHERE deliveries.match_id = matches.id
          GROUP BY season,match_id,batting_team) as team_boundaries
	GROUP BY Season,batting_team;
    
-- WHAT IS THE HIGHEST PARTNERSHIP (RUNS) FOR EACH TEAM IN EACH SEASON?

	SELECT season,batting_team,MAX(total_runs) as Highest_Partnership
    FROM(SELECT season,batting_team,partnership,SUM(Total_runs) as total_runs
    FROM(SELECT season,match_id,batting_team,over_no,SUM(batsman_runs) as partnership,SUM(batsman_runs)+SUM(extra_runs) as total_runs
		 FROM deliveries,matches
         WHERE deliveries.match_id = matches.id
         GROUP BY season, match_id, batting_team,over_no ) as team_scores
         GROUP BY season, batting_team, partnership) as Highest_Partnership
         GROUP BY season, batting_team;
         
-- HOW MANY EXTRAS (WIDES & NO-BALLS) WERE BOWLED BY EACH TEAM IN EACH MATCH?

	SELECT * FROM matches;
    SELECT * FROM deliveries;
    
    SELECT m.id as Match_no,d.bowling_team,SUM(extra_runs) as extras
    FROM matches as m
    JOIN deliveries as d
    ON d.match_id  = m.id
    WHERE extra_runs > 0
    GROUP BY m.id,d.bowling_team;
    
    
-- WHICH BOWLER HAS THE BEST BOWLING FIGURES (MOST WICKETS TAKEN) IN A SINGLE MATCH?

	SELECT m.id,d.bowler,COUNT(*) as Wicket_taken
    FROM matches m
    JOIN deliveries d
    ON d.match_id = m.id
    WHERE d.player_dismissed IS NOT NULL
    GROUP BY m.id,d.bowler
    ORDER BY Wicket_taken DESC
    LIMIT 1;
    
-- HOW MANY MATCHES RESULTED IN A WIN FOR EACH TEAM IN EACH CITY ?

	SELECT * FROM matches;
    
    SELECT m.city,CASE WHEN m.team1= m.winner THEN m.team1 WHEN m.team2 = m.winner THEN m.team2 ELSE 'Draw' END as Winning_Team,
    COUNT(*) as wins
    FROM matches m
    JOIN deliveries d
    ON d.match_id = m.id
    WHERE m.result != 'Tie'
    GROUP BY m.city,winning_team;
    

-- HOW MANY TIMES DID EACH TEAM WIN THE TOSS IN EACH SEASON?

	SELECT season,toss_winner,COUNT(*) AS Toss_Winner
    FROM matches
    GROUP BY season,toss_winner;
    
    
-- HOW MANY MATCHES DID EACH PLAYER WIN THE "PLAYER OF THE MATCH" AWARD?

	SELECT player_of_match,COUNT(*) as Most_Award
    FROM matches
    WHERE player_of_match IS NOT NULL
    GROUP BY player_of_match
    ORDER BY Most_Award DESC;
    
-- WHAT IS THE AVERAGE NUMBER OF RUNS SCORED IN EACH OVER OF THE INNINGS IN EACH MATCH?

	SELECT m.id, d.inning,d.over_no, AVG(total_runs) as Average_Runs
    FROM matches m
    JOIN deliveries d
    ON d.match_id = m.id
    GROUP BY m.id,d.inning,d.over_no;
    
-- WHICH TEAM HAS THE HIGHEST TOTAL SCORE IN A SINGLE MATCH?

	SELECT * FROM matches;
    SELECT * FROM deliveries;
    
    SELECT m.season,m.id as Match_No, d.batting_team,SUM(total_runs) as Highest_Score
    FROM matches as m
    JOIN deliveries as d
    ON d.match_id = m.id
    GROUP BY m.season,m.id,d.batting_team
    ORDER BY Highest_Score DESC
    LIMIT 1;
    
    
-- WHICH BATSMAN HAS SCORED THE MOST RUNS IN A SINGLE MATCH?

	SELECT m.season,m.id as Match_no,d.batsman,SUM(d.batsman_runs) as Most_Runs
    FROM matches as m
    JOIN deliveries as d
    ON d.match_id = m.id
    GROUP BY m.season,m.id,d.batsman
    ORDER BY Most_Runs DESC
    LIMIT 1;

    