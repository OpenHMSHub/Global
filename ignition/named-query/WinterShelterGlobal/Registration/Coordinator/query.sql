SELECT shelter.Congregation.congregationName,
  humans.Human.firstName,
  humans.Human.lastName,
  shelter.Coordinator.isPrimary,
  shelter.Coordinator.notes
FROM humans.Human
  INNER JOIN shelter.Coordinator ON humans.Human.id =
    shelter.Coordinator.providerHumanId
  INNER JOIN shelter.Congregation ON shelter.Coordinator.congregationId =
    shelter.Congregation.id