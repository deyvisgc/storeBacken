<?php


namespace Core\Almacen\Lote\Domain\Repositories;



use Core\Almacen\Lote\Domain\Entity\LoteEntity;

interface LoteRepository
{
    function Create(LoteEntity $loteEntity,string $accion);

    function Update(LoteEntity $loteEntity, int $id,string $accion);

    function Read();

    function Readxid(int $id);

    function delete(int $id);

    function CambiarStatus(int $id);
}
