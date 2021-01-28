<?php


namespace Core\HistorialCaja\Application\UseCases;


use Core\HistorialCaja\Domain\Entity\HistorialCajaEntity;
use Core\HistorialCaja\Domain\Repositories\HistorialCajaRepository;

class createHistorialUseCase
{
    private HistorialCajaRepository $historialCajaRepository;
    public function __construct(HistorialCajaRepository $historialCajaRepository)
    {
        $this->historialCajaRepository=$historialCajaRepository;
    }
    public function createHistorialCaja(HistorialCajaEntity $historialCajaEntity)
    {
        return $this->historialCajaRepository->createHistorialCaja($historialCajaEntity);
    }
}
