<?php


namespace Core\HistorialCaja\Domain\Repositories;


use Core\HistorialCaja\Domain\Entity\HistorialCajaEntity;

interface HistorialCajaRepository
{
    public function listHistorialCaja();
    public function editHistorialCaja(HistorialCajaEntity $historialCajaEntity);
    public function createHistorialCaja(HistorialCajaEntity  $historialCajaEntity);
    public function deleteHistorialCaja(int $idCajaHistory);
}
