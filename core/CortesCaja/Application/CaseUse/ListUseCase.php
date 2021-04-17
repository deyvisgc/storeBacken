<?php


namespace Core\CortesCaja\Application\CaseUse;


use Core\CortesCaja\Domain\Interfaces\CortesInterface;
use Core\CortesCaja\Domain\ValueObjects\fechaDesde;
use Core\CortesCaja\Domain\ValueObjects\fechaHasta;
use Core\CortesCaja\Domain\ValueObjects\IdCaja;
use Core\CortesCaja\Domain\ValueObjects\IdUsuario;

class ListUseCase
{
    private CortesInterface $cortes;

    public function __construct(CortesInterface $cortes)
    {
        $this->cortes = $cortes;
    }
    function totales($idPersona, $idCaja, $fechaDesde, $fechaHasta) {
        return $this->cortes->totales($idPersona, $idCaja, $fechaDesde, $fechaHasta);
    }
    function obtenerSaldoInicial (int $idCaja) {
        return $this->cortes->obtenerSaldoInicial($idCaja);
    }
    function buscarCortesXFechas ($fechaDesde, $fechaHasta, $idCaja) {
        return $this->cortes->buscarCortesXFechas($fechaDesde, $fechaHasta,$idCaja);
    }
    function obtenerTotalesCorte ($fechaDesde, $fechaHasta, $idCaja, $idUsuario){
        return $this->cortes->obtenerTotalesCorte($fechaDesde, $fechaHasta, $idUsuario, $idCaja);
    }
}
