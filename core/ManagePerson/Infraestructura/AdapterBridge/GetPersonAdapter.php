<?php


namespace Core\ManagePerson\Infraestructura\AdapterBridge;


use Core\ManagePerson\Application\UseCases\GetPeopleUseCase;
use Core\ManagePerson\Infraestructura\DataBase\PersonRepositoryImpl;

class GetPersonAdapter
{
    /**
     * @var PersonRepositoryImpl
     */
    private PersonRepositoryImpl $personRepositoryImpl;

    public function __construct(PersonRepositoryImpl $personRepositoryImpl)
    {
        $this->personRepositoryImpl = $personRepositoryImpl;
    }

    public function getPerson() {
        $person = new GetPeopleUseCase($this->personRepositoryImpl);
        return $person->getPeople();
    }
}
