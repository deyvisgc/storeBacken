<?php


namespace Core\ManagePerson\Infraestructura\AdapterBridge;


use Core\ManagePerson\Application\UseCases\ChangeStatusPersonUseCase;
use Core\ManagePerson\Infraestructura\DataBase\PersonRepositoryImpl;

class ChangeStatusPersonAdapter
{
    /**
     * @var PersonRepositoryImpl
     */
    private PersonRepositoryImpl $personRepositoryImpl;

    public function __construct(PersonRepositoryImpl $personRepositoryImpl)
    {
        $this->personRepositoryImpl = $personRepositoryImpl;
    }

    public function changeStatusPerson(int $idPerson): \Illuminate\Http\JsonResponse
    {
        $person = new ChangeStatusPersonUseCase($this->personRepositoryImpl);
        return $person->changeStatusPerson($idPerson);
    }
}
