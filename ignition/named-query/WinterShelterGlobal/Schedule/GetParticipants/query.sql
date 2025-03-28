SELECT sp.participantId , CONCAT(h.firstName, ' ', h.lastName) as participantName, h.dob as 'BirthDate', CASE WHEN p.timeRetired IS NULL THEN 1 ELSE 0 END AS 'isActive'
FROM shelter.ScheduleParticipant sp, participant.Participant p, humans.Human h
WHERE sp.participantId = p.id 
AND p.humanId = h.id
AND sp.scheduleId = :scheduleId 
AND sp.locationId =  :locationId  
AND sp.seasonId =  :seasonId  
AND sp.dayOfYear =  :dayOfYear 
AND sp.timeRetired is null
