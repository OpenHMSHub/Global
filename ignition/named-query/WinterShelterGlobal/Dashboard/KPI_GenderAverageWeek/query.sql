select AVG(beds) as 'Week Average'
from
shelter.LocationSeasonal
where seasonId = :seasonId
and genderId = :genderId