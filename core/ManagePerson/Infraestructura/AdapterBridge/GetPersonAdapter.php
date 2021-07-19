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
    function getPerson($request) {
      $getCase = new GetPeopleUseCase($this->personRepositoryImpl);
      return $getCase->getPerson($request);
    }
    function getPersonById(int $idPerson) {
        $getCase = new GetPeopleUseCase($this->personRepositoryImpl);
        return $getCase->getPersonById($idPerson);
    }

}
