INSERT INTO shelter.Location (
	addressLine1,
	congregationId, 
	locationName,
	city,
	state,
	zipCode,
	timeCreated)
VALUES (
	:line1,
	:congregationId, 
	:locationName,
	'',
	'',
	-1,
	getDate());