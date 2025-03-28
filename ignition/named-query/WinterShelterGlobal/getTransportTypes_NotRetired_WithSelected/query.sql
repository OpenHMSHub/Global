SELECT id,transportType 
FROM shelter.TransportType
WHERE ( timeRetired IS NULL or id =  :selectedOption )
order by transportType Asc