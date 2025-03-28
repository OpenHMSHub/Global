Insert into shelter.CongregationLog
(locationId, actionDate, actionBy, action, actionFields, userName) 
VALUES 
(:locationId, GetDate(),:staffEmployeeId,:action, :actionFields, :userName)
