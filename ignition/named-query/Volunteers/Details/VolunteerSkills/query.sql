SELECT VS.skillId, S.skillName, VS.id
FROM staff.VolunteerSkills VS
LEFT JOIN staff.Skills S on S.id = VS.skillId
WHERE VS.volunteerId = :volunteerId