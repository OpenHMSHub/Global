DECLARE @totalBeds INT;
DECLARE @totalCheckIns INT;

SELECT @totalBeds = COALESCE(SUM(totalBeds),0)
FROM shelter.Schedule 
WHERE dayOfYear =  :dayOfYear AND seasonId =  :seasonId AND timeCancelled is NULL

SELECT @totalCheckIns = COUNT(id)
FROM shelter.ScheduleParticipant
WHERE scheduleId in (SELECT id FROM shelter.Schedule 
WHERE dayOfYear =  :dayOfYear AND seasonId =  :seasonId )
AND timeRetired IS NULL

--SELECT CASE WHEN @totalBeds = 0 THEN ' ' 
--ELSE CONCAT(@totalCheckIns, ' of ' , @totalBeds , ' Checked-In' )
--END AS result

SELECT CONCAT(@totalCheckIns, ' of ' , @totalBeds , ' Checked-In' )


