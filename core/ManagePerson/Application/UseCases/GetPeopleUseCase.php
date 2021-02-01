<?php


namespace Core\ManagePerson\Application\UseCases;


use Core\ManagePerson\Domain\Repositories\PersonRepository;

class GetPeopleUseCase
{
    /**
     * @var PersonRepository
     */
    private PersonRepository $personRepository;

    public function __construct(PersonRepository $personRepository)
    {
        $this->personRepository = $personRepository;
    }

    public function getPeople() {
        return $this->personRepository->getPeople();
    }
}
