<?php


namespace App\Repository\Almacen\Categorias;


use App\Repository\RepositoryInterface;

interface CategoriaRepositoryInterface extends RepositoryInterface
{
    public function selectCategoria($params);
    public function changeStatus($params);
    public function editSubCate($params);
    public function selectSubCategoria($params);
    public function searchSubCate($params);
    public function searchCategoria($params);
}
