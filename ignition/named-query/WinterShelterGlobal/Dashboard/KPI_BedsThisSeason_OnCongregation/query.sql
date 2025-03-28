DECLARE @firstDayOfTheCurrentSeason as INT
DECLARE @YearStart as INT
DECLARE @YeareEnd as INT
DECLARE @ActualAttendance as INT
DECLARE @RegisterForFuture as INT
DECLARE @BedThisSeason as INT

DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @lastSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN (@thisYear - 1) ELSE (@thisYear - 2) END
DECLARE @lastSeasonId int
SELECT @lastSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @lastSeasonStartYear + '%'
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
		bg.id as 'id'
FROM(
SELECT 
		loc.id as 'id'
		,CASE WHEN sch.bedsProjected IS NOT NULL AND sch.bedsProjected > 0 then 'registered' else NULL END  as 'fullyRegistered'
		,ISNULL(ISNULL(ls.genderId,lsp.genderId),'') as 'genderId'
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
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select min(id) FROM shelter.LocationSeasonal 
			WHERE seasonID = @lastSeasonID GROUP BY locationId)) lsp ON loc.id = lsp.locationid
LEFT JOIN shelter.Gender gp ON gp.id = lsp.genderId
	
WHERE
	ls.seasonId =  :season 
	AND loc.congregationId IN (select id from organization.Congregation where timeRetired IS NULL) 
	AND sch.bedsProjected IS NOT NULL AND sch.bedsProjected > 0
	AND (:locationName IS NULL or :locationName = p.providerName)
	AND (:city IS NULL or loc.city like CONCAT(:city, '%'))
	AND (:zipCode IS NULL or loc.zipCode like CONCAT(:zipCode, '%'))
	AND (:minGuests IS NULL or ls.beds >= :minGuests)
	AND (:maxGuests IS NULL or ls.beds <= :maxGuests)	
	--AND (:gender IS NULL or ISNULL(ISNULL(g.genderAccepted,gp.genderAccepted),'') = :gender)
	AND (:search IS NULL
		or p.providerName like CONCAT('%', :search, '%')
		or loc.city like CONCAT('%',:search, '%')
		or loc.zipCode like CONCAT('%',:search, '%')
		or g.genderAccepted like CONCAT('%',:search, '%')
		)
)bg
where {fullyRegistered}
AND {gender}
-- Get Bed This season count			
SET @ActualAttendance = (select count(schp.id) FROM shelter.ScheduleParticipant schp 
						WHERE schp.seasonId = :season AND schp.timeRetired is NULL and schp.locationId in (SELECT * FROM @registrationTable) )

SET @RegisterForFuture = (select COALESCE(sum(s.totalBeds),0) FROM shelter.schedule s
						WHERE s.seasonId = :season AND s.timeCancelled is NULL and s.locationId in (SELECT * FROM @registrationTable)
						AND DateAdd(DAY,s.dayOfYear, case when s.dayOfYear<@firstDayOfTheCurrentSeason then DateFromParts(@YeareEnd-1,12,31) Else DateFromParts(@YearStart-1,12,31) end) > GetDate() )
SET @BedThisSeason = @ActualAttendance + @RegisterForFuture
select @BedThisSeason as 'BedsThisSeason'
