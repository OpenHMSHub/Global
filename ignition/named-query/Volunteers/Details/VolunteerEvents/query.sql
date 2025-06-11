SELECT C.title, C.eventID
FROM calendar.eventInstanceVolunteers IV
LEFT JOIN calendar.eventInstances EI on EI.instanceID = IV.instanceID
LEFT JOIN calendar.CalendarEvents C on C.eventID = EI.parentEventID
WHERE IV.volunteerID = :volunteerId
GROUP BY C.title, C.eventID;