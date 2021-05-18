<?php


namespace Core\Almacen\Unidad\Domain\Repositories;


use Core\Almacen\Unidad\Domain\Entity\UnidadEntity;

interface UnidadRepository
{
    function Create(UnidadEntity $unidadEntity,$fecha_Creacion);

    function Update(UnidadEntity $unidadEntity, int $id,$fecha_Creacion);

    function Read($params);

    function Readxid(int $id);

    function delete(int $id);

    function CambiarStatus(int $id, string $status);

    function SearchUnidad($params);
}
