<?php


namespace Core\Almacen\Unidad\Domain\ValueObjects;


class UMNAME
{
    private string $unidamedia;

    public function __construct(string $unidamedia)
    {
        $this->unidamedia = $unidamedia;
    }

    public function getUnidamedia(): string
    {
        return $this->unidamedia;
    }

}
