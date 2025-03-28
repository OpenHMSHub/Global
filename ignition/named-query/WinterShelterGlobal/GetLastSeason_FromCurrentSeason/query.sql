DECLARE @currentSeason varchar(4) = (SELECT Seasons FROM shelter.Seasons where id = :currentSeasonId) 
DECLARE @lastYearEnd varchar(4) = SUBSTRING(@currentSeason, 1, 4)
SELECT s.id,s.Seasons  FROM shelter.Seasons s WHERE s.Seasons like '%' + @lastYearEnd