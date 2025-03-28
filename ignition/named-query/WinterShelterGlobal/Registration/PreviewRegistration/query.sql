---Determine the current, past and next season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 6 THEN @thisYear ELSE (@thisYear - 1) END
DECLARE @lastSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 6 THEN (@thisYear - 1) ELSE (@thisYear - 2) END
DECLARE @nextSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 6 THEN (@thisYear + 1) ELSE (@thisYear) END
---Determine the current, past and next season ID's
DECLARE @thisSeasonId int
SELECT @thisSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @thisSeasonStartYear + '%'

DECLARE @lastSeasonId int
SELECT @lastSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @lastSeasonStartYear + '%'

DECLARE @nextSeasonId int
SELECT @nextSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @nextSeasonStartYear + '%'

DECLARE @firstDayOfTheCurrentSeason as INT
DECLARE @YearStart as INT
DECLARE @YearEnd as INT
SELECT @YearStart =  CAST(SUBSTRING(seasons, 1, 4)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @YearEnd =   CAST(SUBSTRING(seasons, 6, 9)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @firstDayOfTheCurrentSeason = DATENAME(dayofyear , datefromparts(@YearStart, 11,1)) 

SELECT 	DISTINCT
		---
		---Congregation Information----
		---
		cong.Id AS 'congregationId',
		prov.id AS 'providerId',
		prov.providerName AS 'congregationName',
--		seaf.seasons AS 'firstSeason',
		cong.hostingSince AS 'firstSeason',
		(SELECT seasons FROM shelter.seasons where id = :seasonId  ) AS 'currentSeason',
		prov.street AS 'congregationAddressLine1',
		ISNULL(prov.street2,'') AS 'congregationAddressLine2',
		ISNULL(prov.city,'') AS 'congregationCity',
		ISNULL(prov.state,'') AS 'congregationState',
		prov.zipCode  AS 'congregationZipCode',
--		ISNULL(prov.zipCode,'')  AS 'congregationZipCode',
		ISNULL(prov.phone,'') AS 'congregationPhone',
		---
		---location information---
		---
		loc.hostLocal AS 'hostLocal',
		ls.hostLocationTypeId AS 'hostLocationTypeId',
		lst.HostLocationType AS 'hostLocationType',
		loc.id AS 'locationId',
		loc.locationName AS 'locationName',
		ISNULL(loc.addressLine1,'') AS 'locationAddressLine1',
		ISNULL(loc.addressLine2,'') AS 'locationAddressLine2',
		ISNULL(loc.city,'') AS 'locationCity',
		ISNULL(loc.state,'') AS 'locationState',
		ISNULL(loc.zipCode,'') AS 'locationZipCode',
		loc.timeCreated AS 'locationDateCreated',

		---
		---Primary Coordinator Information---
		pcoord.id AS 'coordinatorId',
		hcp.id AS 'coordinatorHumanId',
		hcp.firstName AS 'coordinatorFirstName',
		hcp.lastName AS 'coordinatorLastName',
		CONCAT_WS(' ',hcp.firstName,hcp.lastName) AS 'coordinatorName',
		hcp.nickname as 'coordinatorNickname', 
		ISNULL(hcp.street,'') AS 'coordinatorAddress',
		ISNULL(hcp.city,'') AS 'coordinatorCity',
		ISNULL(hcp.state,'') AS 'coordinatorState',
		ISNULL(hcp.zipCode,'') AS 'coordinatorZipCode',
		ISNULL(hcp.phone,'') AS 'coordinatorPhone', 
		ISNULL(hcp.altPhone,'') AS 'coordinatorAltPhone', 
		ISNULL(hcp.email,'') AS 'coordinatorEmail', 
		hcp.preferredCommunication AS 'coordinatorPreferredCommunication',
		ISNULL(pcoord.notes,'') AS 'coordinatorNotes',
		---
		---Secondary Coordinator Information---
		CAST (ISNULL(hcs.id,0) AS BIT) AS 'hasBackupCoordinator',
		scoord.id AS 'secondaryCoordinatorId',
		hcs.id AS 'secondaryCoordinatorHumanId',
		hcs.firstName AS 'secondaryCoordinatorFirstName',
		hcs.lastName AS 'secondaryCoordinatorLastName',
		CONCAT_WS(' ',hcs.firstName,hcs.lastName) AS 'secondaryCoordinatorName',
		hcs.nickname as 'secondaryCoordinatorNickname', 
		ISNULL(hcs.street,'') AS 'secondaryCoordinatorAddress',
		ISNULL(hcs.city,'') AS 'secondaryCoordinatorCity',
		ISNULL(hcs.state,'') AS 'secondaryCoordinatorState',
		ISNULL(hcs.zipCode,'') AS 'secondaryCoordinatorZipCode',
		ISNULL(hcs.phone,'') AS 'secondaryCoordinatorPhone', 
		ISNULL(hcs.altPhone,'') AS 'secondarycoordinatorAltPhone', 
		ISNULL(hcs.email,'') AS 'secondaryCoordinatorEmail', 
		hcs.preferredCommunication AS 'secondaryCoordinatorPreferredCommunication',
		ISNULL(scoord.notes,'') AS 'secondaryCoordinatorNotes',
		---
		----Location Features----
		----
		ls.id as 'locationSeasonId', 
		ls.seasonId, 
		ls.beds as 'capacity',
		ISNULL(lsp.beds,0) as 'capacityLastSeason',
		--ISNULL(ls.numberOfWeeks,'') as 'numberOfWeeks',  
		ls.nights as 'nightsInt',
		cast(ls.nights & 1 as bit) as 'sunday',
		cast(ls.nights & 2 as bit) as 'monday',
		cast(ls.nights & 4 as bit) as 'tuesday',
		cast(ls.nights & 8 as bit) as 'wednesday',
		cast(ls.nights & 16 as bit) as 'thursday',
		cast(ls.nights & 32 as bit) as 'friday',
		cast(ls.nights & 64 as bit) as 'saturday',
		CAST(CASE WHEN sch.bedsProjected IS NOT NULL AND sch.bedsProjected > 0 then 1 else 0 END  as bit) as 'registered',
		ls.genderId as 'genderId',
		ISNULL(g.genderAccepted,'') as 'genderAccepted',
		ISNULL(ls.families,0) as 'families',  
		ISNULL(ls.extraShortNotice,0) as 'extraShortNotice', 
		ISNULL(ls.showers,0) as 'showers',
		ISNULL(ls.clothing,0) as 'clothing',
		ISNULL(ls.laundry,0) as 'laundry',
		ISNULL(ls.sackLunches,0) as 'sackLunches',
		ISNULL(ls.breakfast,0) as 'breakfast',
		ISNULL(ls.dinner,0) as 'dinner',
		ISNULL(ls.haircuts,0) as 'haircuts',
		ISNULL(ls.hygieneItems,0) as 'hygieneItems',
		ISNULL(ls.otherService,0) as 'otherService',
		ls.otherServiceList as 'otherServiceList',
		ISNULL(ls.accessible,0) as 'accessible',
		ISNULL(ls.stairs,0) as 'stairs', 
		ISNULL(ls.smoking,0) as 'smoking',
		ISNULL(ls.partners ,'') as 'partners',
		ISNULL(ls.serviceNotes,'') as 'serviceNotes',
		ls.timeCreated as 'timeCreated',
		ISNULL(sch.bedsProjected,'') as 'bedsProjected',
		ls.bedsActual as 'bedsActual',
		ISNULL(ls.notes,'') as 'registrationNotes',
		
		-- lsp.bedsActual as 'bedsActualLastSeason',
		schprev.PrevSeasonActual as 'bedsActualLastSeason',
		schp.ThisSeasonActual as 'bedsActualThisSeason',
		lr.bedsProjected as 'originalRegistration',
		ISNULL(schedule.ScheduledBeds,0) + ISNULL(schp.ThisSeasonActual,0) as 'scheduledBeds',
		---
		---Schedule Info---
		---Actual schedule is via a seperate query---
		---
		ISNULL(ls.scheduleComments,'') as 'scheduleComments',
		ISNULL(ls.reminderCall,0) as 'reminderCall',
		ISNULL(ls.otherHostMore,'') as 'otherHostmore',
		'' as 'options',
		
		--- Transportation Info ---
		ISNULL(trans.transportTypeId,-1) as 'transportId',
		ISNULL(t.transportType,'None') as 'Transport',
		
		--- Frequency Info ---
		ISNULL(f.frequencyType,'') as 'Frequency',
--		ls.frequencyId,
		freq.frequencyTypeId as 'frequencyId',
		ls.dateSelectionPattern,
		ISNULL(ls.dateSelectionDays,'[]') as 'dateSelectionDays',
		ISNULL(ls.pickupTime, '') as pickupTime

FROM shelter.Location loc
LEFT JOIN
	(SELECT * FROM shelter.LocationSeasonal where seasonId = :seasonId  ) ls ON loc.id = ls.locationId
LEFT JOIN
	shelter.LocationRegistrationDetails lr ON ls.locationId = lr.locationId and ls.seasonId = lr.seasonId
LEFT JOIN 
	shelter.Frequency freq ON ISNULL(ls.frequencyId,-1) = freq.id	
LEFT JOIN 
	shelter.Transport trans ON ISNULL(ls.transportId,-1) = trans.id	
LEFT JOIN
	shelter.HostLocationType lst ON ls.hostLocationTypeId = lst.id
LEFT JOIN
	shelter.TransportType t ON trans.transportTypeId =  t.id
LEFT JOIN
	shelter.FrequencyType f ON freq.frequencyTypeId = f.id
LEFT JOIN 
	shelter.Gender g ON ls.genderId = g.id

LEFT JOIN
	organization.Congregation cong ON loc.congregationId = cong.Id
LEFT JOIN 
	organization.Provider prov ON cong.providerId = prov.id
LEFT JOIN
	(SELECT * FROM shelter.Coordinator WHERE isPrimary = 1) pcoord  ON loc.id = pcoord.locationId -- pcoord.congregationId
LEFT JOIN 
	humans.human hcp ON pcoord.humanId = hcp.id
LEFT JOIN
	(SELECT * FROM shelter.Coordinator WHERE isPrimary = 0) scoord  ON loc.id = scoord.locationId --scoord.congregationId
LEFT JOIN 
	humans.human hcs ON scoord.humanId = hcs.id
---First Season
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select min(id) FROM shelter.LocationSeasonal 
			WHERE seasonID <= @lastSeasonID GROUP BY locationId)) lsf ON loc.id = lsf.locationid
LEFT JOIN 
	shelter.Seasons seaf ON lsf.seasonId = seaf.id	
---Last Season
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select min(id) FROM shelter.LocationSeasonal 
			WHERE seasonID = @lastSeasonID GROUP BY locationId)) lsp ON loc.id = lsp.locationid
LEFT JOIN 
	shelter.Seasons seap ON lsp.seasonId = seap.id	
LEFT JOIN
	( 	SELECT locationId, seasonId , sum(totalBeds) as bedsProjected
		FROM shelter.Schedule 
		WHERE timeCancelled is NULL 
		GROUP BY locationId, seasonId ) sch ON ls.seasonId = sch.seasonId AND sch.locationId = ls.locationId
LEFT JOIN ( SELECT locationId, seasonId , count(id) as ThisSeasonActual
	FROM shelter.ScheduleParticipant 
	WHERE timeRetired is NULL
	GROUP BY locationId, seasonId )schp ON ls.seasonId = schp.seasonId AND ls.locationId = schp.locationId
LEFT JOIN ( SELECT locationId, seasonId , count(id) as PrevSeasonActual
	FROM shelter.ScheduleParticipant 
	WHERE timeRetired is NULL
	GROUP BY locationId, seasonId )schprev ON lsp.seasonId = schprev.seasonId AND lsp.locationId = schprev.locationId	
LEFT JOIN
	(SELECT s.locationId, s.seasonId , sum(s.totalBeds) as 'ScheduledBeds' FROM 
		(select *,DateAdd(DAY,dayOfYear, case when dayOfYear<@firstDayOfTheCurrentSeason then DateFromParts(@YearEnd-1,12,31) Else DateFromParts(@YearStart-1,12,31) end) as DateFromDayOfYear from shelter.Schedule) s 
		LEFT JOIN
		(select COUNT(participantId) as totalParticipants, dayOfYear , seasonId, locationId 
			 from shelter.ScheduleParticipant 
			 where timeRetired IS NULL GROUP BY seasonId, locationId, dayOfYear) sp
		ON s.locationId = sp.locationId and s.seasonId = sp.seasonId and s.dayOfYear = sp.dayOfYear
	WHERE s.timeCancelled IS NULL
	AND COALESCE(sp.totalParticipants,0) = 0 and s.DateFromDayOfYear >= CAST(GetDate() as Date)
	GROUP BY s.locationId, s.seasonId
	) as schedule ON ls.seasonId = schedule.seasonId AND ls.locationId = schedule.locationId
	
	WHERE
	--ls.seasonId =  @thisSeasonId
	
	loc.id = :locationId 
