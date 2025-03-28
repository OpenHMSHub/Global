SELECT COUNT(shelter.Schedule.beds) as beds
FROM shelter.Schedule
  INNER JOIN shelter.Location ON shelter.Schedule.locationId =shelter.Location.id
WHERE shelter.Location.congregationId =  :CongregationID and YEAR(shelter.Schedule.scheduleBegin) = :PreviousYear 