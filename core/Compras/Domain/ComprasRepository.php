<?php


namespace Core\Compras\Domain;


interface ComprasRepository
{
    public function Read(object $data);
    public function Detalle(int $id);
    public function UpdateStatus(int $id);
}
