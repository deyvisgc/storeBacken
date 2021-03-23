<?php


namespace Core\Producto\Domain\Repositories;


use Core\Producto\Domain\Entity\ProductoEntity;

interface ProductoRepository
{
    function Create(ProductoEntity $productoEntity);

    function Update(ProductoEntity $productoEntity, int $idproducto, $pro_code);

    function Read();
    function LastIdProduct();
    function Readxid(int $id);

    function delete(int $id);

    function CambiarStatus(string $status,int $id);
}
