<?php


namespace Core\ArqueoCaja\Application\UseCase;


use Core\ArqueoCaja\Domain\Entity\ArqueoEntity;
use Core\ArqueoCaja\Domain\Interfaces\ArqueoCajaRepository;

class CreateUseCase
{
    /**
     * @var ArqueoCajaRepository
     */
    private ArqueoCajaRepository $repository;

    function __construct(ArqueoCajaRepository  $repository)
    {
        $this->repository = $repository;
    }
    function create(ArqueoEntity $entity) {
        return $this->repository->CreateArqueo($entity);
    }

}
