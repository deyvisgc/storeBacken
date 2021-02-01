<?php


namespace Core\Producto\Domain\ValueObjects;


class ProCantidad
{
    /**
     * @var int
     */
    private int $ProCantidad;

    public function __construct(int $ProCantidad)
    {

        $this->ProCantidad = $ProCantidad;
    }

    /**
     * @return int
     */
    public function getProCantidad(): int
    {
        return $this->ProCantidad;
    }


}
