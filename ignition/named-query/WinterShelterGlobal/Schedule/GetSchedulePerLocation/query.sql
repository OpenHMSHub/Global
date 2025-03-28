SELECT
	l.id as 'locationId',
	s.id as 'scheduleId',
	s.seasonId as 'seasonId',
	
	s.totalBeds,
	CASE WHEN g.genderAccepted = 'Men Only' THEN 'Male'
	WHEN g.genderAccepted = 'Women Only' THEN 'Female'
	WHEN g.genderAccepted = 'Men or Women on Different Nights' THEN 'Male or Female'
	WHEN g.genderAccepted = 'Men & Women Together' THEN 'Male and Female' END AS gender,
	(SELECT CASE WHEN COUNT(participantId) > 0 THEN 'Checked-In'
	ELSE 'Scheduled' END AS status
	 FROM shelter.ScheduleParticipant 
	 WHERE scheduleId = s.id and locationId = l.id AND timeRetired IS NULL) as status,
	s.dayOfYear -- ,ss.Seasons
FROM shelter.Location l, shelter.Schedule s, shelter.Gender g --, shelter.Seasons ss
WHERE l.timeRetired is NULL 
AND (
(s.seasonId =  :month1SeasonId AND s.dayOfYear >=  :month1StartDayOfYear AND s.dayOfYear <=  :month1EndDayOfYear ) 
OR 
(s.seasonId =  :month2SeasonId AND s.dayOfYear >=  :month2StartDayOfYear AND s.dayOfYear <=  :month2EndDayOfYear)
)
AND l.id = :locationId AND l.id = s.locationId AND g.id = s.genderId -- AND s.seasonId = ss.id
ORDER BY s.dayOfYear
