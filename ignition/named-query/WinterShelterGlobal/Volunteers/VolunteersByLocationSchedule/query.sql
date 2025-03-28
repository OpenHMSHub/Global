DECLARE @locationId AS INT = 160;
DECLARE @scheduleId AS INT = 14;
DECLARE @shelterStaffTypeId AS INT = 0;

SELECT 
    [id]
    ,[locationId]
    ,(SELECT [dayOfYear] FROM [shelter].[Schedule] WHERE [id] = @scheduleId AND [locationId] = @locationId AND [timeRetired] IS NULL) AS schedule
    ,(SELECT [staffType] FROM [shelter].[ShelterStaffType] WHERE [id] = @shelterStaffTypeId AND [timeRetired] IS NULL) AS shelterStaffType
    ,[firstname]
    ,[lastname]
    ,[phone]
    ,[altphone]
    ,[email]
    ,[timeCreated]
    ,[timeRetired]
FROM [shelter].[ShelterVolunteers]
WHERE [locationId] = @locationId