<?php


namespace Core\Producto\Domain\ValueObjects;


class ProPrecioVenta
{
    private float $ProPrecioVenta;

    public function __construct(float $ProPrecioVenta)
    {
        $this->ProPrecioVenta = $ProPrecioVenta;
    }
    public function getProPrecioVenta(): float
    {
        return $this->ProPrecioVenta;
    }

}
