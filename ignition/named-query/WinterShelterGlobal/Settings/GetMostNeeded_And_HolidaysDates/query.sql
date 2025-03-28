SELECT
  VALUE 
FROM 
  shelter.Settings CROSS APPLY STRING_SPLIT(settingValue, ',')
WHERE
	settingName = :settingName