INSERT INTO staff.VolunteerEvents
(eventId, volunteerId, timeCreated)
VALUES(:eventId, :volunteerId, GETDATE());
