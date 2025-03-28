SELECT CASE WHEN h.HostLocationType = 'Our Location' THEN 'Congregation'
ELSE h.HostLocationType END AS HostLocationType
FROM
shelter.LocationSeasonal l, shelter.HostLocationType h
WHERE l.locationId =  :locationId AND l.seasonId = :seasonId AND l.hostLocationTypeId = h.id