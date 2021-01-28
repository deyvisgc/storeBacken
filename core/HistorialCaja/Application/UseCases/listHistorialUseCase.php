<?php


namespace Core\HistorialCaja\Application\UseCases;


use Core\HistorialCaja\Domain\Repositories\HistorialCajaRepository;

class listHistorialUseCase
{
    private HistorialCajaRepository $historialCajaRepository;

    public function __construct(HistorialCajaRepository $historialCajaRepository)
    {
        $this->historialCajaRepository=$historialCajaRepository;
    }
    public function listHistorial()
    {
        return $this->historialCajaRepository->listHistorialCaja();
    }
}
