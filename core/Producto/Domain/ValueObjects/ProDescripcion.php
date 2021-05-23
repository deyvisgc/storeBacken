<?php


namespace Core\Producto\Domain\ValueObjects;


class ProDescripcion
{

    private ?string $ProDescripcion;

    public function __construct(?string $ProDescripcion)
    {

        $this->ProDescripcion = $ProDescripcion;
    }

    public function getProDescripcion(): string
    {
        return $this->ProDescripcion;
    }

}
