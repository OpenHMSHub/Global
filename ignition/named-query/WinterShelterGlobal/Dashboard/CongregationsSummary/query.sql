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
--DECLARE @percentGrowth float
SELECT DISTINCT LID,SID,currentSeason,SIDLast,lastActiveSeason,CID,locationName,city,zipCode,genderAccepted,genderId,beds,projection,actual,lastYear,registered,options,
/*CASE WHEN PercentBedGrowth != '' THEN (CONCAT(ROUND(PercentBedGrowth,0) , '%'))
	WHEN PercentBedGrowth = 0 THEN (CONCAT(ROUND(PercentBedGrowth,0) , '%'))
	ELSE CONCAT(PercentBedGrowth,'')
	END as 'PercentBedGrowth'*/
	ISNULL(ROUND(PercentBedGrowth,0),-1000) as 'PercentBedGrowth'
	--,max(PercentBedGrowth) over() as 'PercentBedGrowth1'
FROM
(
SELECT DISTINCT
	l.id as 'LID',
	ls.seasonId as 'SID',
	sea.seasons as 'currentSeason',
	lsp.seasonId as 'SIDLast',
	--ISNULL(ISNULL(seaLast.seasons, sea.seasons),originalSea.Seasons) as 'lastActiveSeason',
	(SELECT max(seasons) FROM shelter.Seasons WHERE id IN (SELECT seasonId FROM shelter.LocationSeasonal where locationId = l.id)) as 'lastActiveSeason',
	c.id as 'CID',
	l.locationName,
	l.city,
	l.zipCode,
	ISNULL(ISNULL(ISNULL(g.genderAccepted,gp.genderAccepted),originalGen.genderAccepted),'') as 'genderAccepted',
	ISNULL(ISNULL(ISNULL(ls.genderId,lsp.genderId),originalLoc.genderId),'') as 'genderId',--ls.genderId,
	ISNULL(ISNULL(ls.beds,lsp.beds),-1000) as 'beds',
	ISNULL(sch.bedsProjected,-1000) as 'projection',
	ISNULL(schp.ThisSeasonActual,-1000) as 'actual',
--	ls.bedsActual as 'actual',
--	lsp.bedsActual as 'lastYear',
	ISNULL(schprev.PrevSeasonActual,-1000) as 'lastYear',
	CAST(CASE WHEN sch.bedsProjected IS NOT NULL AND sch.bedsProjected > 0 then 1 else 0 END  as bit) as 'registered',
	CASE WHEN sch.bedsProjected IS NOT NULL AND sch.bedsProjected > 0 then 'registered' else NULL END  as 'fullyRegistered',
	'' as 'options', 

	CASE WHEN (schprev.PrevSeasonActual IS NULL OR schprev.PrevSeasonActual = 0) THEN ls.bedsProjected 
		ELSE (CAST((sch.bedsProjected-schprev.PrevSeasonActual) AS FLOAT)/schprev.PrevSeasonActual)*100 END AS 'PercentBedGrowth'

	
FROM organization.Provider p
LEFT JOIN shelter.Location l ON p.providerName =  l.locationName 
LEFT JOIN organization.congregation c ON l.congregationId = c.id

LEFT JOIN (
	SELECT * FROM 
	(	SELECT locs.*,row_number() over(partition by locationId order by s.Seasons DESC) as roworder 
		FROM shelter.LocationSeasonal locs
			LEFT JOIN shelter.Seasons s on s.id = locs.seasonId
	) lso WHERE roworder = 1) originalLoc ON l.id = originalLoc.locationid
LEFT JOIN shelter.Seasons originalSea on originalLoc.seasonId = originalSea.id
LEFT JOIN shelter.Gender originalGen ON originalGen.id = originalLoc.genderId

LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE seasonID = @thisSeasonId) ls ON l.id = ls.locationid
LEFT JOIN shelter.Gender g ON g.id = ls.genderId
LEFT JOIN shelter.Seasons sea on ls.seasonId = sea.id

LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select min(id) FROM shelter.LocationSeasonal 
			WHERE seasonID = @lastSeasonID GROUP BY locationId)) lsp ON l.id = lsp.locationid
LEFT JOIN shelter.Gender gp ON gp.id = lsp.genderId
LEFT JOIN shelter.Seasons seaLast on lsp.seasonId = seaLast.id
LEFT JOIN ( SELECT locationId, seasonId , sum(totalBeds) as bedsProjected
FROM shelter.Schedule 
WHERE timeCancelled is NULL 
GROUP BY locationId, seasonId ) sch ON ls.seasonId = sch.seasonId AND ls.locationId = sch.locationId
LEFT JOIN ( SELECT locationId, seasonId , count(id) as ThisSeasonActual
FROM shelter.ScheduleParticipant 
WHERE timeRetired is NULL
GROUP BY locationId, seasonId )schp ON ls.seasonId = schp.seasonId AND ls.locationId = schp.locationId

LEFT JOIN ( SELECT locationId, seasonId , count(id) as PrevSeasonActual
FROM shelter.ScheduleParticipant 
WHERE timeRetired is NULL
GROUP BY locationId, seasonId )schprev ON lsp.seasonId = schprev.seasonId AND lsp.locationId = schprev.locationId
WHERE
	--NOT(ls.seasonId is null AND lsp.seasonId is NULL)
	l.locationName IS NOT NULL
	AND l.congregationId IN (select id from organization.Congregation where timeRetired IS NULL) 
--	AND {seasonId} 
	AND {locationName} 
	AND {city}
	AND {zipCode}
	AND {minGuests}
	AND {maxGuests}
--	AND {genders}
	AND {search}
)bg
WHERE {PercentGrowth}
AND {seasonId}
AND {genders}
ORDER BY locationName;
--ORDER BY p.providerName
--	AND PercentBedGrowth > 0