---WinterShelter/Group/Select Groups---
SELECT CONCAT(humans.Human.firstName,' ',humans.Human.middleName,' ',humans.Human.lastName) as "Name" 
FROM staff.Volunteer
Inner join humans.Human on staff.Volunteer.id = Humans.Human.id
WHERE staff.Volunteer.timeRetired is null