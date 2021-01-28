<?php


namespace Core\Caja\Infraestructura\AdapterBridge;


use Core\Caja\Application\UseCases\updateCajaUseCase;
use Core\Caja\Domain\Entity\CajaEntity;
use Core\Caja\Infraestructura\DataBase\CajaRepositoryImpl;

class UpdateCajaAdapter
{
    private CajaRepositoryImpl $cajaRepositoryImpl;

    public function __construct(CajaRepositoryImpl $cajaRepositoryImpl)
    {
        $this->cajaRepositoryImpl=$cajaRepositoryImpl;
    }
    public function updateCaja(CajaEntity $cajaEntity)
    {
        $updateCaja = new updateCajaUseCase($this->cajaRepositoryImpl);
        return $updateCaja->updateCaja($cajaEntity);
    }
}
