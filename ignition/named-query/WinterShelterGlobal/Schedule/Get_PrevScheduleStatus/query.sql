DECLARE @minimumTimeCreated AS DATETIME
DECLARE @todayDayOfTheYear as INT
DECLARE @firstDayOfTheCurrentSeason as INT
DECLARE @YearStart as INT
DECLARE @YeareEnd as INT
DECLARE @todaysDate AS DATE

SELECT @todayDayOfTheYear = DATENAME(dayofyear , GetDate()) 
SELECT @YearStart =  CAST(SUBSTRING(seasons, 1, 4)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @YeareEnd =   CAST(SUBSTRING(seasons, 6, 9)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @firstDayOfTheCurrentSeason = DATENAME(dayofyear , datefromparts(@YearStart, 11,1)) 
SELECT @todaysDate = CAST(GetDate() as Date)

SELECT s1.scheduleId,
CASE 
WHEN COALESCE(sp.totalParticipants,0) > 0 and s1.DateFromDayOfYear =  @todaysDate THEN 'Checked-In'
WHEN COALESCE(sp.totalParticipants,0) > 0 and s1.DateFromDayOfYear <  @todaysDate THEN 'Completed'
WHEN COALESCE(sp.totalParticipants,0) = 0 and s1.DateFromDayOfYear <  @todaysDate  THEN 'No-Show'
WHEN s1.timeCreated > datefromparts(@YearStart, 11,1) THEN 'Addition'
WHEN COALESCE(sp.totalParticipants,0) = 0 and s1.DateFromDayOfYear >=  @todaysDate THEN 'Scheduled'

END AS status 
FROM
(
SELECT
	s.id as 'scheduleId',
	s.locationId as 'locationId',
	s.dayOfYear as 'dayOfYear',
	DateAdd(DAY,s.dayOfYear, case when s.dayOfYear<@firstDayOfTheCurrentSeason then DateFromParts(@YeareEnd-1,12,31) Else DateFromParts(@YearStart-1,12,31) end) as DateFromDayOfYear ,
	s.timeRetired, s.timeCreated, s.timeCancelled, s.HostLocationType
	
FROM shelter.Schedule s
WHERE s.id = :scheduleId and (s.timeCancelled IS NULL or s.timeCancelled >= datefromparts(@YearStart, 11,1))
) s1
-- ORDER BY s.dayOfYear
LEFT JOIN
(SELECT COUNT(participantId) as totalParticipants, dayOfYear , scheduleId, locationId 
	 FROM shelter.ScheduleParticipant 
	 WHERE timeRetired IS NULL GROUP BY scheduleId, locationId, dayOfYear) sp
ON s1.locationId = sp.locationId AND s1.scheduleId = sp.scheduleId and s1.dayOfYear = sp.dayOfYear
ORDER BY s1.dayOfYear
	 
