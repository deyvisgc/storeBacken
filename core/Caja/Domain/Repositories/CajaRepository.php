<?php


namespace Core\Caja\Domain\Repositories;


use Core\Caja\Domain\Entity\CajaEntity;

interface CajaRepository
{
    public function createCaja(CajaEntity $cajaEntity);
    public function aperturarCaja($caja);
    public function cerrarCaja($caja);
    public function updateCaja(CajaEntity $cajaEntity);
    public function deleteCaja(int $idCaja);
    public function listCaja();
    function totales(int $idPersona, int $idcaja, $fechaDesde, $fechaHasta);

}
