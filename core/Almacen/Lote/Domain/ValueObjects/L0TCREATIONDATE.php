<?php


namespace Core\Almacen\Lote\Domain\ValueObjects;


class L0TCREATIONDATE
{
    private string $lotecreadate;

    public function __construct(string $lotecreadate)
    {
        $this->lotecreadate = $lotecreadate;
    }

    /**
     * @return string
     */
    public function getLotecreadate(): string
    {
        return $this->lotecreadate;
    }

}
