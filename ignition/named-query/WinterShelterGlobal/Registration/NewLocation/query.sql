INSERT INTO shelter.Location (
	addressLine1, 
	addressLine2, 
	city, 
	capacity, 
	congregationId,
	state, 
	zipCode)
VALUES (
	:line1, 
	:line2, 
	:city, 
	:capacity, 
	:congregationId,
	:state, 
	:zip);
