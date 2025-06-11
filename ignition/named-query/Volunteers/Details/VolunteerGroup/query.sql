SELECT 
	G.id,
	G.volunteerGroupName as "Name", 
	G.timeCreated,
	G.volunteerGroupDescription as "description"
FROM staff.Volunteer V
LEFT JOIN staff.volunteerGroup G on G.id = V.volunteerGroupId
WHERE V.id = :volunteerId;