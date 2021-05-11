<?php


namespace Core\ManagePerson\Infraestructura\AdapterBridge;


use Core\ManagePerson\Application\UseCases\UpdatePersonUseCase;
use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Infraestructura\DataBase\PersonRepositoryImpl;

class UpdatePersonAdapter
{
    /**
     * @var PersonRepositoryImpl
     */
    private PersonRepositoryImpl $personRepositoryImpl;

    public function __construct(PersonRepositoryImpl $personRepositoryImpl)
    {
        $this->personRepositoryImpl = $personRepositoryImpl;
    }

    public function updatePerson(PersonEntity $personEntity, $perfil) {
        $person = new UpdatePersonUseCase($this->personRepositoryImpl);
        return $person->updatePerson($personEntity, $perfil);
    }
}
