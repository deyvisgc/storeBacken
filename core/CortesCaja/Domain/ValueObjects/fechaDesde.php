<?php


namespace Core\CortesCaja\Domain\ValueObjects;


class fechaDesde
{
    private string $fecchaDesde;

    public function __construct(string $fecchaDesde)
    {
        $this->fecchaDesde = $fecchaDesde;
    }

    /**
     * @return string
     */
    public function getFecchaDesde(): string
    {
        return $this->fecchaDesde;
    }

}
