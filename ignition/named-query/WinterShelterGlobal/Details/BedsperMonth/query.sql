SELECT TOP 10 AVG(shelter.Schedule.beds) AS beds,
	MONTH(shelter.Schedule.scheduleBegin) as Month
FROM shelter.Schedule
  INNER JOIN shelter.Location ON shelter.Schedule.locationId = shelter.Location.id
WHERE shelter.Location.congregationId = :CongregationID
GROUP BY MONTH(shelter.Schedule.scheduleBegin)