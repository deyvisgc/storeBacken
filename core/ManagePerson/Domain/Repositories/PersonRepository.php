<?php


namespace Core\ManagePerson\Domain\Repositories;


use Core\ManagePerson\Domain\Entity\PersonEntity;

interface PersonRepository
{
    public function createPerson(PersonEntity $personEntity);
    public function updatePerson(PersonEntity $personEntity);
    public function deletePerson(int $idPerson);
    public function getPeople();
    public function getPersonById(int $idPerson);
}
