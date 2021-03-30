<?php


namespace Core\ManagePerson\Application\UseCases;


use Core\ManagePerson\Domain\Repositories\PersonRepository;

class ChangeStatusPersonUseCase
{
    /**
     * @var PersonRepository
     */
    private PersonRepository $personRepository;

    public function __construct(PersonRepository $personRepository)
    {
        $this->personRepository = $personRepository;
    }

    public function changeStatusPerson(int $idPerson) {
        if ($idPerson <= 0) {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'Datos no encontrados']);
        }

        $person = $this->personRepository->changeStatusPerson($idPerson);

        if ($person === 1) {
            return response()->json(['status' => true, 'code' => 200, 'message' => 'Estado habilitado']);
        } else {
            return response()->json(['status' => false, 'code' => 400, 'message' => 'No se pudo habilitar al usuario']);
        }
    }
}
