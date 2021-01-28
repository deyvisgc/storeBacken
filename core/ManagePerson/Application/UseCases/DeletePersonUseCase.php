<?php


namespace Core\ManagePerson\Application\UseCases;


use Core\ManagePerson\Domain\Repositories\PersonRepository;

class DeletePersonUseCase
{
    /**
     * @var PersonRepository
     */
    private PersonRepository $personRepository;

    public function __construct(PersonRepository $personRepository)
    {
        $this->personRepository = $personRepository;
    }

    public function deletePerson(int $idPerson) {
        $responseDB = $this->personRepository->deletePerson($idPerson);

        if ($responseDB === 1) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Persona eliminada']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Persona no eliminada']);
        }
    }
}
