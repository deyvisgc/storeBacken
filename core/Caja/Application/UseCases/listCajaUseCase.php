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
    function totales($idPersona, $fechaDesde, $fechaHasta, $month, $year) {
        return $this->cajaRepository->totales($idPersona, $fechaDesde, $fechaHasta, $month, $year);
    }
    function obtenerSaldoInicial (int $idcaja) {
        return $this->cajaRepository->obtenerSaldoInicial($idcaja);
    }
    function buscarCortesXFechas ($fechaDesde, $fechaHasta) {
        return $this->cajaRepository->buscarCortesXFechas($fechaDesde, $fechaHasta);
    }
}
