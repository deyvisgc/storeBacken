<?php


namespace Core\Producto\Domain\Repositories;


use Core\Producto\Domain\Entity\ProductoEntity;

interface ProductoRepository
{
    function Create(ProductoEntity $productoEntity, $data);

    function Update(ProductoEntity $productoEntity, int $idproducto, $pro_code);

    function Read($params);
    function LastIdProduct();
    function Edit($params);
    function delete(int $id);

    function CambiarStatus(string $status,int $id);
}
