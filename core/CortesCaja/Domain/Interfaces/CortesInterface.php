<?php


namespace Core\CortesCaja\Domain\Interfaces;


interface CortesInterface
{
    function obtenerSaldoInicial(int $idCaja);
    function buscarCortesXFechas($fechaDesde, $fechaHasta, $idCaja);
    function GuardarCorte($detallecorteCaja,$corteCaja);
    function totales(int $idPersona, int $idcaja, $fechaDesde, $fechaHasta);
    function obtenerTotalesCorte($fechaDesde , $fechaHasta, $idUsuario, $idCaja);
}
