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

    public function updatePerson(PersonEntity $personRepository): \Illuminate\Http\JsonResponse
    {
        $responseDB = $this->personRepository->updatePerson($personRepository);

        if ($responseDB === 1) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Datos persona actualizado']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Datos persona no actualizados']);
        }
    }
}
