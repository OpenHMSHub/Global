DECLARE @firstDayOfTheCurrentSeason as INT
DECLARE @YearStart as INT
DECLARE @YeareEnd as INT
-- Declare registrationTable variable
DECLARE @registrationTable table
(
Id int
)

SELECT @YearStart =  CAST(SUBSTRING(seasons, 1, 4)as INT) FROM shelter.Seasons where id = :season
SELECT @YeareEnd =   CAST(SUBSTRING(seasons, 6, 9)as INT) FROM shelter.Seasons where id = :season
SELECT @firstDayOfTheCurrentSeason = DATENAME(dayofyear , datefromparts(@YearStart, 11,1)) 

-- Insert id from registration table according to filter to @registrationTable table
INSERT INTO @registrationTable (Id)
SELECT 
	loc.id as 'id'
FROM shelter.Location loc
LEFT JOIN Organization.Congregation c ON loc.congregationId = c.Id
LEFT JOIN organization.provider p ON c.providerId = p.id
LEFT JOIN
	shelter.LocationSeasonal ls ON loc.id = ls.locationId
LEFT JOIN 
	shelter.Gender g ON ls.genderId = g.id
LEFT JOIN 
	shelter.Seasons sea ON ls.seasonId = sea.id
OUTER APPLY
	(SELECT DISTINCT TOP (1) * FROM shelter.Coordinator WHERE isPrimary = 1 and locationId = loc.id ORDER BY timeCreated DESC) AS pcoord --ON loc.id = pcoord.locationId  --ON loc.id = pcoord.locationId -- pcoord.congregationId
LEFT JOIN 
	humans.human hcp ON pcoord.humanId = hcp.id
LEFT JOIN ( SELECT locationId, seasonId , sum(totalBeds) as bedsProjected
	FROM shelter.Schedule 
	WHERE timeCancelled is NULL 
	GROUP BY locationId, seasonId ) sch ON ls.seasonId = sch.seasonId AND ls.locationId = sch.locationId
	
WHERE
	ls.seasonId =  :season 
	AND loc.congregationId IN (select id from organization.Congregation where timeRetired IS NULL) 
	AND sch.bedsProjected IS NOT NULL AND sch.bedsProjected > 0
	--AND loc.city like 'An%'
	AND {locationName} 
	AND  {city} 
	AND  {zipCode} 
	AND  {minGuests} 
	AND  {maxGuests} 
	AND  {accessible}
	AND  {families} 
	AND  {shortNotice} 
	AND  {stairs} 
	AND  {smoking} 
	AND  {reminderCall} 
	AND  {monday} 
	AND  {tuesday} 
	AND  {wednesday} 
	AND  {thursday} 
	AND  {friday} 
	AND  {saturday} 
	AND  {sunday} 
	AND  {gender} 
	AND  {search} 
	AND  {showers} 
	AND  {clothing} 
	AND  {laundry} 
	AND  {sackLunches} 
	AND  {breakfast} 
	AND  {dinner} 
	AND  {haircuts} 
	AND  {hygieneItems} 

-- Get weekly beds as per gender and location
SELECT Sum(TotalBeds)/Count(*) as WeeklyBeds FROM(
SELECT Sum(totalBeds) as TotalBeds, 'Week ' + cast(datepart(wk, DateFromDayOfYear) as varchar(2)) Week FROM
(SELECT locationId, seasonId,genderId,totalBeds,dayOfYear,DateAdd(DAY,dayOfYear, case when dayOfYear<@firstDayOfTheCurrentSeason then DateFromParts(@YeareEnd-1,12,31) Else DateFromParts(@YearStart-1,12,31) end) as DateFromDayOfYear 
FROM shelter.Schedule
Where seasonId = :season And genderId = :genderId and timeCancelled IS NULL
and locationId in (SELECT * FROM @registrationTable)) as x
group by datepart(wk, DateFromDayOfYear)
) s