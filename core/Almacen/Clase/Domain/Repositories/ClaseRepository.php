<?php


namespace Core\Almacen\Clase\Domain\Repositories;


use Core\Almacen\Clase\Domain\Entity\ClaseEntity;

interface ClaseRepository
{
    function Categoria(ClaseEntity $claseEntity);
    function Update(array $data);
    function getCategoria($params);
    function editCategory($id);
    function searchCategoria($params);
    function getclasepadre();
    function delete(int $id);
    function CambiarStatus(int $id);
    function ObtenerPadreehijoclase();
    function editSubcate ($params);
    function viewchild(int $idpadre);
    function Actualizarcate (int $idclase, string $nombrecate);
    function ChangeStatusCate (int $idclase, string $status);
    function ChangeStatusCateRecursiva (int $idclase, string $status);
}
