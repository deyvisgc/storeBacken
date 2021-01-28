<?php


namespace Core\Caja\Application\UseCases;


use Core\Caja\Domain\Repositories\CajaRepository;

class deleteCajaUseCase
{
    private CajaRepository $cajaRepository;

    public function __construct(CajaRepository $cajaRepository)
    {
        $this->cajaRepository=$cajaRepository;
    }
    public function deleteCaja($idCaja)
    {
        return $this->cajaRepository->deleteCaja($idCaja);
    }
}
