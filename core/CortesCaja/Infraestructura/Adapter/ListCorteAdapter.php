<?php


namespace Core\CortesCaja\Infraestructura\Adapter;


use Core\CortesCaja\Application\CaseUse\ListUseCase;
use Core\CortesCaja\Domain\ValueObjects\IdCaja;
use Core\CortesCaja\Infraestructura\DataBase\CorteSql;

class ListCorteAdapter
{
    /**
     * @var CorteSql
     */
    private CorteSql $corteSql;

    public function __construct(CorteSql $corteSql)
    {
        $this->corteSql = $corteSql;
    }
    function totales($idPersona, $idCaja, $fechaDesde, $fechaHasta) {
        $listCaja = new ListUseCase($this->corteSql);
        return $listCaja->totales($idPersona, $idCaja, $fechaDesde, $fechaHasta);
    }
    function obtenerSaldoInicial(int $idCaja) {
        $listCaja = new ListUseCase($this->corteSql);
        return $listCaja->obtenerSaldoInicial($idCaja);
    }
    function buscarcortesxfechas($fechaDesde, $fechaHasta, $idCaja) {
        $listCaja =  new ListUseCase($this->corteSql);
        return $listCaja->buscarCortesXFechas($fechaDesde, $fechaHasta, $idCaja);
    }
    function obtenerTotalesCorte($filtros) {
        $fechaDesde = $filtros['fechaDesde'];
        $fechaHasta = $filtros['fechaHasta'];
        $idCaja = $filtros['idCaja'];
        $idUsuario = $filtros['idUsuario'];
        $listCaja =  new ListUseCase($this->corteSql);
        return $listCaja->obtenerTotalesCorte($fechaDesde, $fechaHasta, $idCaja, $idUsuario);
    }
}
