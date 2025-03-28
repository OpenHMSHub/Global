SELECT shelter.Tasks.*,
  shelter.Congregation.congregationName
FROM shelter.Congregation
  INNER JOIN shelter.Tasks ON shelter.Congregation.id =
    shelter.Tasks.congregationId
  INNER JOIN shelter.Type ON shelter.Tasks.typeId = shelter.Type.id
  WHERE shelter.Tasks.id =  :taskID 