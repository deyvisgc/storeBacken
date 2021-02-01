<?php


namespace Core\ManagePerson\Infraestructura\AdapterBridge;


use Core\ManagePerson\Application\UseCases\CreatePersonUseCase;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Infraestructura\DataBase\PersonRepositoryImpl;

class CreatePersonAdapter
{


    /**
     * @var PersonRepositoryImpl
     */
    private PersonRepositoryImpl $personRepositoryImpl;

    public function __construct(PersonRepositoryImpl $personRepositoryImpl)
    {

        $this->personRepositoryImpl = $personRepositoryImpl;
    }

    public function createPerson(PersonEntity $personEntity) {
        $person = new CreatePersonUseCase($this->personRepositoryImpl);
        return $person->createPerson($personEntity);
    }
}
