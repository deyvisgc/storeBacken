<?php


namespace Core\ArqueoCaja\Application\UseCase;


use Core\ArqueoCaja\Domain\Interfaces\ArqueoCajaRepository;

class ReadUseCase
{
    /**
     * @var ArqueoCajaRepository
     */
    private ArqueoCajaRepository $repository;

    function __construct(ArqueoCajaRepository $repository)
    {
        $this->repository = $repository;
    }
    function ObtenerTotales($params) {
       return $this->repository->ObtenerTotales($params);
    }
}
