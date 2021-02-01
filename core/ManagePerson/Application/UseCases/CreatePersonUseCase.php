<?php


namespace Core\ManagePerson\Application\UseCases;


use Core\ManagePerson\Domain\Entity\PersonEntity;
use Core\ManagePerson\Domain\Repositories\PersonRepository;

class CreatePersonUseCase
{

    /**
     * @var PersonRepository
     */
    private PersonRepository $personRepository;

    public function __construct(PersonRepository $personRepository)
    {
        $this->personRepository = $personRepository;
    }

    public function createPerson(PersonEntity $personEntity) {
        $responseDB  = $this->personRepository->createPerson($personEntity);

        if ($responseDB === true) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Persona registrada']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Persona no registrada']);
        }
    }
}
