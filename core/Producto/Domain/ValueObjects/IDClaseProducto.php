<?php


namespace Core\Producto\Domain\ValueObjects;


class IDClaseProducto
{
    private int $idclaseProducto;

    public function __construct(int $idclaseProducto)
    {

        $this->idclaseProducto = $idclaseProducto;
    }
    public function getIdclaseProducto(): int
    {
        return $this->idclaseProducto;
    }

}
