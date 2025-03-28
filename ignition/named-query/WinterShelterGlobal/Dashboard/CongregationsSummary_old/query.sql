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
	ISNULL(seaLast.seasons, sea.seasons) as 'lastActiveSeason',
	c.id as 'CID',
	l.locationName,
	l.city,
	l.zipCode,
	ISNULL(g.genderAccepted,gp.genderAccepted) as 'genderAccepted',
	ls.genderId,
	ISNULL(ls.beds,lsp.beds) as 'beds',
	ls.bedsProjected as 'projection',
	ls.bedsActual as 'actual',
	lsp.bedsActual as 'lastYear',
	cast(ISNULL(ls.seasonId,0) as bit) as 'registered',
	'' as 'options',
	CASE 
		WHEN (lsp.bedsActual IS NULL OR lsp.bedsActual = 0) THEN ls.bedsProjected 
		ELSE (CAST((ls.bedsProjected-lsp.bedsActual) AS FLOAT)/lsp.bedsActual)*100 END AS 'PercentBedGrowth'
	
FROM shelter.Location l
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE seasonID = @thisSeasonId) ls ON l.id = ls.locationid
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select max(id) FROM shelter.LocationSeasonal 
			WHERE seasonID <= @lastSeasonID GROUP BY locationId)) lsp ON l.id = lsp.locationid
LEFT JOIN organization.congregation c ON l.congregationId = c.id
LEFT JOIN shelter.Gender g ON g.id = ls.genderId
LEFT JOIN shelter.Gender gp ON gp.id = lsp.genderId
LEFT JOIN shelter.Seasons sea on ls.seasonId = sea.id
LEFT JOIN shelter.Seasons seaLast on lsp.seasonId = seaLast.id
WHERE
	NOT(ls.seasonId is null AND lsp.seasonId is NULL)
	AND {seasonId} 
	AND {locationName} 
	AND {city}
	AND {zipCode}
	AND {minGuests}
	AND {maxGuests}
	AND {genders}
	AND {search}
	AND {PercentGrowth}