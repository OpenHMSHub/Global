UPDATE staff.Volunteer
SET profile = :profile, status = :status, volunteerGroupId = :volunteerGroupId
WHERE staff.Volunteer.id = :volunteerId