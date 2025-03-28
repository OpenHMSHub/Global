UPDATE shelter.Settings 
SET settingValue = :settingValue
WHERE settingName = :settingName AND timeRetired is NULL 