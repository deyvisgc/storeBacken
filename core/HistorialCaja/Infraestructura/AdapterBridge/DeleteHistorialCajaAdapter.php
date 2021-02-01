<?php


namespace Core\HistorialCaja\Infraestructura\AdapterBridge;


use Core\HistorialCaja\Application\UseCases\deleteHistorialCajaUseCase;
use Core\HistorialCaja\Infraestructura\DataBase\HistorialCajaRepositoryImpl;

class DeleteHistorialCajaAdapter
{
    private HistorialCajaRepositoryImpl $historialCajaRepositoryImpl;

    public function __construct(HistorialCajaRepositoryImpl $historialCajaRepositoryImpl)
    {
        $this->historialCajaRepositoryImpl=$historialCajaRepositoryImpl;
    }
    public function deleteHistorialCaja($idCajaHistory){
        $deleteHistoria = new deleteHistorialCajaUseCase($this->historialCajaRepositoryImpl);
        return $deleteHistoria->deleteHistorialCaja($idCajaHistory);
    }
}
