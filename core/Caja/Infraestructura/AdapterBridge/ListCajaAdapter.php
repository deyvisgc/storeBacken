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
    function totales($idPersona, $fechaDesde, $fechaHasta, $month, $year) {
        $listCaja = new listCajaUseCase($this->cajaRepositoryImpl);
        return $listCaja->totales($idPersona, $fechaDesde, $fechaHasta, $month, $year);
    }
    function obtenerSaldoInicial(int $idCaja) {
        $listCaja = new listCajaUseCase($this->cajaRepositoryImpl);
        return $listCaja->obtenerSaldoInicial($idCaja);
    }
    function buscarcortesxfechas($fechaDesde, $fechaHasta) {
        $listCaja = new listCajaUseCase($this->cajaRepositoryImpl);
        return $listCaja->buscarCortesXFechas($fechaDesde, $fechaHasta);
    }
}
