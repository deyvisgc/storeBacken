<?php


namespace Core\Producto\Domain\ValueObjects;


class ProNombre
{
    /**
     * @var string
     */
    private string $ProNombre;

    public function __construct(string $ProNombre)
    {

        $this->ProNombre = $ProNombre;
    }

    /**
     * @return string
     */
    public function getProNombre(): string
    {
        return $this->ProNombre;
    }


}
