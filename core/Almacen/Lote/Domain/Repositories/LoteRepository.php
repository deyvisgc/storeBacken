<?php


namespace Core\Almacen\Lote\Domain\Repositories;



use Core\Almacen\Lote\Domain\Entity\LoteEntity;

interface LoteRepository
{
    function Create(LoteEntity $loteEntity);

    function Update(LoteEntity $loteEntity, int $id);

    function Read($request);

    function obtenerCode($params);

    function Readxid(int $id);

    function delete(int $id);

    function CambiarStatus(int $id, string $status);

    function SearchLotes($params);
}
