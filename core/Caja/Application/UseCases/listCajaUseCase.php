<?php


namespace Core\Caja\Application\UseCases;


use Core\Caja\Domain\Repositories\CajaRepository;

class listCajaUseCase
{
    private CajaRepository $cajaRepository;

    public function __construct(CajaRepository $cajaRepository)
    {
        $this->cajaRepository=$cajaRepository;
    }
    public function listCaja()
    {
        return $this->cajaRepository->listCaja();
    }
    function totales($idPersona, $idCaja, $fechaDesde, $fechaHasta) {
        return $this->cajaRepository->totales($idPersona, $idCaja, $fechaDesde, $fechaHasta);
    }
}
