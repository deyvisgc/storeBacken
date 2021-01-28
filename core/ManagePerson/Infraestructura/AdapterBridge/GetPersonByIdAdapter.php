<?php


namespace Core\ManagePerson\Infraestructura\AdapterBridge;


use Core\ManagePerson\Application\UseCases\GetPersonByIdUseCase;
use Core\ManagePerson\Infraestructura\DataBase\PersonRepositoryImpl;

class GetPersonByIdAdapter
{
    /**
     * @var PersonRepositoryImpl
     */
    private PersonRepositoryImpl $personRepositoryImpl;

    public function __construct(PersonRepositoryImpl $personRepositoryImpl)
    {
        $this->personRepositoryImpl = $personRepositoryImpl;
    }

    public function getPersonById(int $idPerson) {
        $person = new GetPersonByIdUseCase($this->personRepositoryImpl);
        return $person->getPersonById($idPerson);
    }
}
