UPDATE 
	humans.Human 
SET  
	firstName = :firstName,
	middleName = :middleName,
	lastName = :lastName,
	dob = :dob,
	dobQualityId = :dob_quality,
	genderId = :gender,
	street = :address,
	city = :city,
	zipCode = :zipcode,
	phone = :primaryPhone,
	altPhone = :eveningPhone,
	email = :email,
	communicationTypeId = :preferredCommunicationMethod,
	preferredCommunication = :preferredCommunication
WHERE 
	id = :human_id