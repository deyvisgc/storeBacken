<?php


namespace Core\Almacen\Unidad\Domain\ValueObjects;


class UMNOMBRECORTO
{
    private string $nombrecorto;

    public function __construct(string $nombrecorto)
 {
     $this->nombrecorto = $nombrecorto;
 }

    /**
     * @return string
     */
    public function getNombrecorto(): string
    {
        return $this->nombrecorto;
    }
}
