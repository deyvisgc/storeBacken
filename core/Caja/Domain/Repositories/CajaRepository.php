<?php


namespace Core\Caja\Domain\Repositories;


use Core\Caja\Domain\Entity\CajaEntity;

interface CajaRepository
{
    public function createCaja(CajaEntity $cajaEntity);
    public function updateCaja(CajaEntity $cajaEntity);
    public function deleteCaja(int $idCaja);
    public function listCaja();

}
