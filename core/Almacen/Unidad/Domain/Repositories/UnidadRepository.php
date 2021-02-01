<?php


namespace Core\Almacen\Unidad\Domain\Repositories;


use Core\Almacen\Unidad\Domain\Entity\UnidadEntity;

interface UnidadRepository
{
    function Create(UnidadEntity $unidadEntity,string $accion);

    function Update(UnidadEntity $unidadEntity, int $id,string $accion);

    function Read();

    function Readxid(int $id);

    function delete(int $id);

    function CambiarStatus(int $id);
}
