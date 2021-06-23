<?php


namespace Core\Producto\Domain\ValueObjects;


class ProPrecioCompra
{

    private float $ProPrecioCompra;

    public function __construct(float $ProPrecioCompra)
    {

        $this->ProPrecioCompra = $ProPrecioCompra;
    }
    public function getProPrecioCompra(): float
    {
        return $this->ProPrecioCompra;
    }
}
