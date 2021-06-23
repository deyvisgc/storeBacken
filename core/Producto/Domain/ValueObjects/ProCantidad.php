<?php


namespace Core\Producto\Domain\ValueObjects;


class ProCantidad
{

    private int $ProCantidad;

    public function __construct(int $ProCantidad)
    {

        $this->ProCantidad = $ProCantidad;
    }

    public function getProCantidad(): int
    {
        return $this->ProCantidad;
    }
}
