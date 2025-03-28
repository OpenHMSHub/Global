select sum(beds) as 'Beds'
from
shelter.LocationSeasonal
where 
	 seasonId = :seasonId