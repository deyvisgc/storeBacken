<?php


namespace Core\Producto\Domain\ValueObjects;


class IDPRODUCTO
{
    private int $idProducto;

    public function __construct(int $idProducto)
    {

        $this->idProducto = $idProducto;
    }

    /**
     * @return int
     */
    public function getIDProducto(): int
    {
        return $this->idProducto;
    }

}
