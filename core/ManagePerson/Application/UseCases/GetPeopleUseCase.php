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
   function getPerson($request) {
        return $this->personRepository->getPerson($request);
   }
   function getPersonById(int $idPerson) {
       return $this->personRepository->getPersonById($idPerson);
   }
}
