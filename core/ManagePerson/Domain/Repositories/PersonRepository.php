<?php


namespace Core\ManagePerson\Domain\Repositories;


use Core\ManagePerson\Domain\Entity\PersonEntity;

interface PersonRepository
{
     function createPerson($razonSocial,$tipoDocumento,$numerDocumento,$telefono,$direccion,$typePerson);
     function updatePerson(PersonEntity $personEntity, $perfil);
     function deletePerson(int $idPerson);
     function getPersonById(int $idPerson);
     function getPerson($request);
     function changeStatusPerson($data);
}
