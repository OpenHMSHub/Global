SELECT id, locationName as providerName, addressLine1 as street
FROM shelter.Location
WHERE locationName {congregationName}
AND addressLine1 {street} 
ORDER BY providerName ASC
