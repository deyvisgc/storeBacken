<?php


namespace Core\Caja\Application\UseCases;


use Core\Caja\Domain\Entity\CajaEntity;
use Core\Caja\Domain\Repositories\CajaRepository;

class createCajaUseCase
{
    private CajaRepository $cajaRepository;

    public function __construct(CajaRepository $cajaRepository)
    {
        $this->cajaRepository=$cajaRepository;
    }
    public function createCaja(CajaEntity $cajaEntity){
        return $this->cajaRepository->createCaja($cajaEntity);
    }
     function AperturarCaja($caja){
        return $this->cajaRepository->aperturarCaja($caja);
    }
    function GuardarCorte($detallecorteCaja,$corteCaja){
        return $this->cajaRepository->GuardarCorte($detallecorteCaja,$corteCaja);
    }
}
