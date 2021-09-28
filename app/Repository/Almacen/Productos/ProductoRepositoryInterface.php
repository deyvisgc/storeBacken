<?php


namespace App\Repository\Almacen\Productos;


use App\Repository\RepositoryInterface;

interface ProductoRepositoryInterface extends RepositoryInterface
{
    function getAtributos();
    function generarCodigoBarra();
    function edit(int $id);
    function changeStatus($data);
    function selectProducto($params);
}
