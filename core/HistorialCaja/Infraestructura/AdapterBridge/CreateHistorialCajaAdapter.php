<?php


namespace Core\HistorialCaja\Infraestructura\AdapterBridge;


use Core\HistorialCaja\Application\UseCases\createHistorialUseCase;
use Core\HistorialCaja\Domain\Entity\HistorialCajaEntity;
use Core\HistorialCaja\Infraestructura\DataBase\HistorialCajaRepositoryImpl;

class CreateHistorialCajaAdapter
{
    private HistorialCajaRepositoryImpl $historialCajaRepositoryImpl;

    public function __construct(HistorialCajaRepositoryImpl $historialCajaRepositoryImpl)
    {
        $this->historialCajaRepositoryImpl=$historialCajaRepositoryImpl;
    }
    public function createHistorialCaja(HistorialCajaEntity $historialCajaEntity)
    {
        $createHistorialCaja = new createHistorialUseCase($this->historialCajaRepositoryImpl);
        return $createHistorialCaja->createHistorialCaja($historialCajaEntity);
    }
}
