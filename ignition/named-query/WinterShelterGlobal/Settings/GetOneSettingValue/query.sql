SELECT TOP 1 settingValue
FROM shelter.Settings 
WHERE settingName = :settingName AND timeRetired is NULL 