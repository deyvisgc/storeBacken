<?php


namespace Core\Almacen\Clase\Infraestructure\DataBase;


use Core\Almacen\Clase\Domain\Entity\ClaseEntity;
use Core\Almacen\Clase\Domain\Repositories\ClaseRepository;
use Illuminate\Support\Facades\DB;

class ClaseSql implements ClaseRepository
{


    function Create(ClaseEntity $productoEntity, string $accion)
    {
        // TODO: Implement Create() method.
    }

    function Update(ClaseEntity $productoEntity,int $idclase,string $accion)
    {
        // TODO: Implement Update() method.
    }

    function Read()
    {
        return DB::table('clase_producto')->get();
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
