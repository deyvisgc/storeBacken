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

    public function createPerson($razonSocial,$tipoDocumento,$numerDocumento,$telefono,$direccion,$typePerson) {
        return $this->personRepository->createPerson($razonSocial,$tipoDocumento,$numerDocumento,$telefono,$direccion,$typePerson);
    }
}
