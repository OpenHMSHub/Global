---Determine the current, past and next season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN @thisYear ELSE (@thisYear - 1) END
DECLARE @lastSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN (@thisYear - 1) ELSE (@thisYear - 2) END
DECLARE @nextSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN (@thisYear + 1) ELSE (@thisYear) END
---Determine the current, past and next season ID's
DECLARE @thisSeasonId int
SELECT @thisSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @thisSeasonStartYear + '%'

DECLARE @lastSeasonId int
SELECT @lastSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @lastSeasonStartYear + '%'

DECLARE @nextSeasonId int
SELECT @nextSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @nextSeasonStartYear + '%'
--DECLARE @percentGrowth float
SELECT DISTINCT LID,SID,currentSeason,SIDLast,lastActiveSeason,CID,locationName,city,zipCode,genderAccepted,genderId,beds,projection,actual,lastYear,registered,options,PercentBedGrowth
FROM
(
SELECT DISTINCT
	--@thisMonth,
	--@lastSeasonStartYear as 'lastSeason',
	--@lastSeasonId,
	--@thisSeasonStartYear as 'thisSeason',
	--@thisSeasonId,
	--@nextSeasonStartYear as 'nextSeason',
	--@nextSeasonId,
	l.id as 'LID',
	ls.seasonId as 'SID',
	sea.seasons as 'currentSeason',
	lsp.seasonId as 'SIDLast',
	--seaLast.seasons as 'lastActiveSeason',
	ISNULL(ISNULL(seaLast.seasons, sea.seasons),originalSea.Seasons) as 'lastActiveSeason',
	c.id as 'CID',
	l.locationName,
	--p.providerName as 'locationName',
	l.city,
	l.zipCode,
--	CASE WHEN l.zipCode = -1 THEN ' ' ELSE l.zipCode END as 'zipCode',
	ISNULL(ISNULL(ISNULL(g.genderAccepted,gp.genderAccepted),originalGen.genderAccepted),'') as 'genderAccepted',
	ls.genderId,
	ISNULL(ls.beds,lsp.beds) as 'beds',
	ls.bedsProjected as 'projection',
	
	--ISNULL(ls.bedsProjected,originalls.bedsProjected) as 'projection',
	ls.bedsActual as 'actual',
	lsp.bedsActual as 'lastYear',
	-- cast(ISNULL(ls.seasonId,0) as bit) as 'registered',
	CAST(CASE WHEN ls.bedsProjected IS NOT NULL AND ls.bedsProjected > 0 then 1 else 0 END  as bit) as 'registered',
	'' as 'options', 
	---bg.PercentBedGrowth as 'PercentBedGrowth'
	CASE WHEN bg.PercentBedGrowth != '' THEN (CONCAT(ROUND(bg.PercentBedGrowth,0) , '%'))
	WHEN bg.PercentBedGrowth = 0 THEN (CONCAT(ROUND(bg.PercentBedGrowth,0) , '%'))
	ELSE CONCAT(bg.PercentBedGrowth,'')
	END as 'PercentBedGrowth'
--	CASE 
--		WHEN (lsp.bedsActual IS NULL OR lsp.bedsActual = 0) THEN ls.bedsProjected 
--		ELSE (CAST((ls.bedsProjected-lsp.bedsActual) AS FLOAT)/lsp.bedsActual)*100 END AS 'PercentBedGrowth'
	
FROM organization.Provider p
LEFT JOIN shelter.Location l ON p.providerName =  l.locationName 
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal) originalLoc ON l.id = originalLoc.locationid
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE seasonID = @thisSeasonId) ls ON l.id = ls.locationid
--LEFT JOIN (SELECT * FROM shelter.LocationSeasonal) originalls ON l.id = ls.locationid
LEFT JOIN shelter.Seasons originalSea on originalLoc.seasonId = originalSea.id
LEFT JOIN shelter.Gender originalGen ON originalGen.id = originalLoc.genderId
--LEFT JOIN (SELECT * FROM shelter.LocationSeasonal) originalls ON l.id = originalls.locationid  AND originalls.seasonID = originalSea.id
--LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select max(id) FROM shelter.LocationSeasonal 
--			WHERE seasonID <= @lastSeasonID GROUP BY locationId)) lsp ON l.id = lsp.locationid
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select min(id) FROM shelter.LocationSeasonal 
			WHERE seasonID = @lastSeasonID GROUP BY locationId)) lsp ON l.id = lsp.locationid
LEFT JOIN organization.congregation c ON l.congregationId = c.id
--LEFT JOIN organization.Provider p ON l.congregationId = p.id
LEFT JOIN shelter.Gender g ON g.id = ls.genderId
LEFT JOIN shelter.Gender gp ON gp.id = lsp.genderId
LEFT JOIN shelter.Seasons sea on ls.seasonId = sea.id
LEFT JOIN shelter.Seasons seaLast on lsp.seasonId = seaLast.id
LEFT JOIN (SELECT l.id , lsp.bedsActual,ls.bedsProjected,
		CASE WHEN (lsp.bedsActual IS NULL OR lsp.bedsActual = 0) THEN ls.bedsProjected 
		ELSE (CAST((ls.bedsProjected-lsp.bedsActual) AS FLOAT)/lsp.bedsActual)*100 END AS 'PercentBedGrowth'
		FROM shelter.Location l
		LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE seasonID = @thisSeasonId) ls ON l.id = ls.locationid
		LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select max(id) FROM shelter.LocationSeasonal 
		WHERE seasonID = @lastSeasonID GROUP BY locationId)) lsp ON l.id = lsp.locationid) bg
		ON bg.id = l.id
		
WHERE
	--NOT(ls.seasonId is null AND lsp.seasonId is NULL)
	l.locationName IS NOT NULL
	AND l.congregationId IN (select id from organization.Congregation where timeRetired IS NULL) 
	AND {seasonId} 
	AND {locationName} 
	AND {city}
	AND {zipCode}
	AND {minGuests}
	AND {maxGuests}
	AND {genders}
	AND {search}
	AND {PercentGrowth})x

ORDER BY locationName;
--ORDER BY p.providerName
--	AND PercentBedGrowth > 0