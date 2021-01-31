<?php


namespace Core\Almacen\Clase\Domain\Repositories;


use Core\Almacen\Clase\Domain\Entity\ClaseEntity;

interface ClaseRepository
{
    function Create(ClaseEntity $productoEntity,string $accion);

    function Update(ClaseEntity $productoEntity, int $idclase,string $accion);

    function Read();

    function Readxid(int $id);

    function delete(int $id);

    function CambiarStatus(int $id);
}
