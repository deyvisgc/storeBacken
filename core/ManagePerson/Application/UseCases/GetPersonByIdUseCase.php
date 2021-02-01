<?php


namespace Core\ManagePerson\Application\UseCases;


use Core\ManagePerson\Domain\Repositories\PersonRepository;

class GetPersonByIdUseCase
{
    /**
     * @var PersonRepository
     */
    private PersonRepository $personRepository;

    public function __construct(PersonRepository $personRepository)
    {
        $this->personRepository = $personRepository;
    }

    public function getPersonById(int $idPerson) {
        return $this->personRepository->getPersonById($idPerson);
    }
}
