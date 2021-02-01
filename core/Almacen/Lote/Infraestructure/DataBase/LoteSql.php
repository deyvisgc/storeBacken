<?php


namespace Core\Almacen\Lote\Infraestructure\DataBase;


use Core\Almacen\Lote\Domain\Entity\LoteEntity;
use Core\Almacen\Lote\Domain\Repositories\LoteRepository;
use Illuminate\Support\Facades\DB;

class LoteSql implements LoteRepository {
    function Create(LoteEntity $loteEntity,string $accion)
    {
        // TODO: Implement Create() method.
    }

    function Update(LoteEntity $loteEntity, int $id, string $accion)
    {
        // TODO: Implement Update() method.
    }

    function Read()
    {
        return DB::table('lote')->get();
    }

    function Readxid(int $id)
    {
        // TODO: Implement Readxid() method.
    }

    function delete(int $id)
    {
        // TODO: Implement delete() method.
    }

    function CambiarStatus(int $id)
    {
        // TODO: Implement CambiarStatus() method.
    }
}
