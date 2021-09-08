<?php


namespace App\Repository\Almacen;


use App\Repository\RepositoryInterface;

interface AlmacenRepositoryInterface extends RepositoryInterface
{
    function getHistorial($params);
    function exportar($params);
}
