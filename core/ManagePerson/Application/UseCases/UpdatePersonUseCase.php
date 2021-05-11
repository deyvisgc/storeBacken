<?php


namespace Core\ManagePerson\Application\UseCases;


use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Domain\Repositories\PersonRepository;

class UpdatePersonUseCase
{
    /**
     * @var PersonRepository
     */
    private PersonRepository $personRepository;

    public function __construct(PersonRepository $personRepository)
    {
        $this->personRepository = $personRepository;
    }

    public function updatePerson(PersonEntity $personRepository, $perfil)
    {
        return $this->personRepository->updatePerson($personRepository, $perfil);
    }
}
