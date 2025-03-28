/*---WinterShelter/FindVolunteers---*/

SELECT
	'' as 'options',
	v.ID as 'volunteerId',
	h.ID as 'humanId',
	h.breezeId as 'breezeId',
	h.firstName  as 'firstName',
	ISNULL(h.middleName,'')  as 'middleName',
	h.lastName  as 'lastName',
	ISNULL(h.nickname,'')  as 'nickName',
	ISNULL(FORMAT(h.dob, 'd', 'us'),'') AS 'dob',
	DATEPART(day,h.dob) as 'dobDay',
	DATEPART(month,h.dob) as 'dobMonth',
	ISNULL(h.email ,'')  as 'email',
	h.genderId as 'genderId',
	g.genderName as 'genderName' ,
	h.congregationId as 'congregationId',
	p.providerName as 'congregationName',
	h.street as 'address',
	h.city as 'city',
	h.zipcode as 'zipcode',
	h.phone as 'phone',
	h.altPhone as 'eveningPhone',
	h.email as 'email',
	h.preferredCommunication as 'preferredCommunication'


FROM
	staff.Volunteer v
	INNER JOIN  humans.Human h on v.humanId = h.id
	LEFT JOIN humans.Gender g on h.genderId = g.id
	LEFT JOIN organization.Congregation c on h.congregationId = c.id
	LEFT JOIN organization.Provider p on c.providerId = p.id

WHERE
	v.timeRetired is null
	AND
	{firstName} 
	AND
	{middleName}
	AND
	{lastName}
	AND
	{nickName} 
	AND
	{dobYear} 
	AND
	{dobMonth} 
	AND
	{dobDay} 
	AND
	{search} 
	AND
	{email}
	AND
	{genderId} 
	AND
	h.congregationId = :congregationId 