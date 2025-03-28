UPDATE	shelter.location
SET addressLine1 = :locationStreet,
	addressLine2 = :locationStreet2,
	city = :locationCity,
	state = :locationState,
	zipCode = :locationZipCode,
	hostLocal  = :hostLocal

WHERE id = :locationId;
