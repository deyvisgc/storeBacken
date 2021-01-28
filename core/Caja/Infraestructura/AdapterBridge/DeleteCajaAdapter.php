<?php


namespace Core\Caja\Infraestructura\AdapterBridge;


use Core\Caja\Application\UseCases\deleteCajaUseCase;
use Core\Caja\Infraestructura\DataBase\CajaRepositoryImpl;

class DeleteCajaAdapter
{
    private CajaRepositoryImpl $cajaRepositoryImpl;

    public function __construct(CajaRepositoryImpl $cajaRepositoryImpl)
    {
        $this->cajaRepositoryImpl=$cajaRepositoryImpl;
    }
    public function deleteCaja($idCaja){
        $deleteCaja = new deleteCajaUseCase($this->cajaRepositoryImpl);
        return $deleteCaja->deleteCaja($idCaja);
    }

}
