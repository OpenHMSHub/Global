SELECT shelter.taskType.id AS id,
  shelter.taskType.type
FROM shelter.taskType 
WHERE timeRetired IS NULL