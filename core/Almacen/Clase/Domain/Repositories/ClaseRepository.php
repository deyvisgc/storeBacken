<?php


namespace Core\Almacen\Clase\Domain\Repositories;


use Core\Almacen\Clase\Domain\Entity\ClaseEntity;

interface ClaseRepository
{
    function Categoria(ClaseEntity $claseEntity);
    function getCategoria($params);
    function editCategory($id);
    function searchCategoria($params);
    function editSubcate ($params);
    function ChangeStatusCate (int $idclase, string $status);
    function ChangeStatusSubCate (int $idclase, string $status);
}
