<?php


namespace Core\ManagePerson\Infraestructura\AdapterBridge;


use Core\ManagePerson\Application\UseCases\DeletePersonUseCase;
use Core\ManagePerson\Infraestructura\DataBase\PersonRepositoryImpl;

class DeletePersonAdapter
{
    /**
     * @var PersonRepositoryImpl
     */
    private PersonRepositoryImpl $personRepositoryImpl;

    public function __construct(PersonRepositoryImpl $personRepositoryImpl)
    {
        $this->personRepositoryImpl = $personRepositoryImpl;
    }

    public function deletePerson(int $idPerson){
        $person = new DeletePersonUseCase($this->personRepositoryImpl);
        return $person->deletePerson($idPerson);
    }
}
