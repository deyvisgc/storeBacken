<?php


namespace Core\HistorialCaja\Application\UseCases;


use Core\HistorialCaja\Domain\Repositories\HistorialCajaRepository;

class deleteHistorialCajaUseCase
{
    private HistorialCajaRepository $historialCajaRepository;

    public function __construct(HistorialCajaRepository $historialCajaRepository)
    {
        $this->historialCajaRepository=$historialCajaRepository;
    }
    public function deleteHistorialCaja($idCajaHistory){
        return $this->historialCajaRepository->deleteHistorialCaja($idCajaHistory);
    }
}
