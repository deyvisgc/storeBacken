<?php


namespace Core\HistorialCaja\Infraestructura\AdapterBridge;


use Core\HistorialCaja\Application\UseCases\updateHistorialCajaUseCase;
use Core\HistorialCaja\Domain\Entity\HistorialCajaEntity;
use Core\HistorialCaja\Infraestructura\DataBase\HistorialCajaRepositoryImpl;

class UpdateHistorialCajaAdapter
{
    private HistorialCajaRepositoryImpl $historialCajaRepositoryImpl;

    public function __construct(HistorialCajaRepositoryImpl $historialCajaRepositoryImpl)
    {
        $this->historialCajaRepositoryImpl=$historialCajaRepositoryImpl;
    }
    public function updateHistorial(HistorialCajaEntity $historialCajaEntity)
    {
        $updateHistorial = new updateHistorialCajaUseCase($this->historialCajaRepositoryImpl);
        return $updateHistorial->updateHistorial($historialCajaEntity);
    }
}
