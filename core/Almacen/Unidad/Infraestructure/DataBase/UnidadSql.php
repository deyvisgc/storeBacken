<?php


namespace Core\Almacen\Unidad\Infraestructure\DataBase;


use Core\Almacen\Unidad\Domain\Entity\UnidadEntity;
use Core\Almacen\Unidad\Domain\Repositories\UnidadRepository;
use Illuminate\Support\Facades\DB;

class UnidadSql implements UnidadRepository
{

    function Create(UnidadEntity $unidadEntity, string $accion)
    {
        // TODO: Implement Create() method.
    }

    function Update(UnidadEntity $unidadEntity, int $id, string $accion)
    {
        // TODO: Implement Update() method.
    }

    function Read()
    {
        return DB::table('unidad_medida')->get();
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
