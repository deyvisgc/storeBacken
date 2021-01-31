<?php


namespace Core\Almacen\Lote\Domain\ValueObjects;


class LOTCODIGO
{
    private string $lotcodigo;

    public function __construct(string $lotcodigo)
    {
        $this->lotcodigo = $lotcodigo;
    }

    /**
     * @return string
     */
    public function getLotcodigo(): string
    {
        return $this->lotcodigo;
    }

}
