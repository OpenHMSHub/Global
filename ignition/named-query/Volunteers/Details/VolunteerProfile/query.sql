SELECT V.volunteerGroupId, V.status, V.profile
FROM staff.Volunteer V
WHERE V.id = :volunteerId