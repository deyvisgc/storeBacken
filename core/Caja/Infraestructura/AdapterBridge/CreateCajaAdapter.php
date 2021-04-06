<?php


namespace Core\Caja\Infraestructura\AdapterBridge;


use Core\Caja\Application\UseCases\createCajaUseCase;
use Core\Caja\Domain\Entity\CajaEntity;
use Core\Caja\Infraestructura\DataBase\CajaRepositoryImpl;

class CreateCajaAdapter
{

    private CajaRepositoryImpl $cajaRepositoryImpl;

    public function __construct(CajaRepositoryImpl $cajaRepositoryImpl)
    {
        $this->cajaRepositoryImpl = $cajaRepositoryImpl;
    }
    public function createCaja(CajaEntity $cajaEntity){
        $createCaja= new createCajaUseCase($this->cajaRepositoryImpl);
        return $createCaja->createCaja($cajaEntity);
    }
     function AperturarCaja($caja){
        $createCaja= new createCajaUseCase($this->cajaRepositoryImpl);
        return $createCaja->AperturarCaja($caja);
    }
    function GuardarCorteDiario($corteCaja) {
        $createCaja= new createCajaUseCase($this->cajaRepositoryImpl);
        return $createCaja->GuardarCorteDiario($corteCaja);
    }
}
