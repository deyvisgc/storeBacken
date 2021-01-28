<?php


namespace Core\HistorialCaja\Infraestructura\AdapterBridge;


use Core\HistorialCaja\Application\UseCases\listHistorialUseCase;
use Core\HistorialCaja\Infraestructura\DataBase\HistorialCajaRepositoryImpl;

class ListHistorialCajaAdapter
{
    private HistorialCajaRepositoryImpl $historialCajaRepositoryImpl;

    public function __construct(HistorialCajaRepositoryImpl $historialCajaRepositoryImpl)
    {
        $this->historialCajaRepositoryImpl=$historialCajaRepositoryImpl;
    }
    public function listHistorial(){
        $listSangria = new listHistorialUseCase($this->historialCajaRepositoryImpl);
        return $listSangria->listHistorial();
    }
}
