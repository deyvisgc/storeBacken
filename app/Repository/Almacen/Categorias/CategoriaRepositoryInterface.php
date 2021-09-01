<?php


namespace App\Repository\Almacen\Categorias;


use App\Repository\RepositoryInterface;

interface CategoriaRepositoryInterface extends RepositoryInterface
{
    public function selectCategoria($params);
}
