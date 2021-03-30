<?php


namespace Core\Almacen\Clase\Domain\Repositories;


use Core\Almacen\Clase\Domain\Entity\ClaseEntity;

interface ClaseRepository
{
    function Create(ClaseEntity $claseEntity);
    function Update(array $data);
    function Read();
    function getclasepadre();
    function delete(int $id);
    function CambiarStatus(int $id);
    function ObtenerPadreehijoclase();
    function Obtenerclasexid (int $idpadre);
    function viewchild(int $idpadre);
    function Actualizarcate (int $idclase, string $nombrecate);
    function ChangeStatusCate (int $idclase, string $status);
    function ChangeStatusCateRecursiva (int $idclase, string $status);
}
