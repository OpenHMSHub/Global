SELECT
	s.id,
	s.Seasons as 'season'
FROM
	shelter.Seasons s
INNER JOIN
	 shelter.LocationSeasonal ls ON ls.seasonId  = s.id
WHERE
	ls.locationId =  :locationId 
ORDER BY season