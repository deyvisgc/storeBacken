<?php


namespace Core\Producto\Domain\ValueObjects;


class ProCantidadMinima
{
    private ?int $ProCantidadMinima;

    public function __construct(? int $ProCantidadMinima)
    {

        $this->ProCantidadMinima = $ProCantidadMinima;
    }

    /**
     * @return int
     */
    public function getProCantidadMinima(): int
    {
        return $this->ProCantidadMinima;
    }

}
