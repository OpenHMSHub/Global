SELECT DISTINCT   :congregationId  AS congregationId,
  :title AS title,
  :startTime AS startTime,
  :endTime AS endtime,
  :notes AS notes,
   Congregation_Name 
FROM shelter.TotalTable
WHERE id =  :congregationId 
