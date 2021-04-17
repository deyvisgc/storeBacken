<?php


namespace Core\CortesCaja\Domain\ValueObjects;


class fechaHasta
{
    private string $fechaHasta;

    public function __construct(string $fechaHasta)
    {
        $this->fechaHasta = $fechaHasta;
    }

    /**
     * @return string
     */
    public function getFechaHasta(): string
    {
        return $this->fechaHasta;
    }

}
