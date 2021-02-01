<?php


namespace Core\HistorialCaja\Application\UseCases;


use Core\HistorialCaja\Domain\Entity\HistorialCajaEntity;
use Core\HistorialCaja\Domain\Repositories\HistorialCajaRepository;

class updateHistorialCajaUseCase
{
    private HistorialCajaRepository $historialCajaRepository;

    public function __construct(HistorialCajaRepository $historialCajaRepository)
    {
        $this->historialCajaRepository=$historialCajaRepository;
    }
    public function updateHistorial(HistorialCajaEntity $historialCajaEntity)
    {
        return $this->historialCajaRepository->editHistorialCaja($historialCajaEntity);
    }
}
