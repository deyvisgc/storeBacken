<?php


namespace Core\Caja\Application\UseCases;


use Core\Caja\Domain\Entity\CajaEntity;
use Core\Caja\Domain\Repositories\CajaRepository;

class updateCajaUseCase
{
    private CajaRepository $cajaRepository;

    public function __construct(CajaRepository $cajaRepository)
    {
        $this->cajaRepository=$cajaRepository;
    }
     function updateCaja(CajaEntity $cajaEntity)
    {
        return $this->cajaRepository->updateCaja($cajaEntity);
    }
     function cerrarCaja($caja)
    {
        return $this->cajaRepository->cerrarCaja($caja);
    }
}
