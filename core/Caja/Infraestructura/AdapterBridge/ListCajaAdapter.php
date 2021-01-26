<?php


namespace Core\Caja\Infraestructura\AdapterBridge;


use Core\Caja\Application\UseCases\listCajaUseCase;
use Core\Caja\Infraestructura\DataBase\CajaRepositoryImpl;

class ListCajaAdapter
{

    private CajaRepositoryImpl $cajaRepositoryImpl;

    public function __construct(CajaRepositoryImpl $cajaRepositoryImpl)
    {
        $this->cajaRepositoryImpl=$cajaRepositoryImpl;
    }
    public function listCaja()
    {
        $listCaja = new listCajaUseCase($this->cajaRepositoryImpl);
        return $listCaja->listCaja();
    }
}
