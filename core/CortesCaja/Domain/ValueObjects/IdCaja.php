<?php


namespace Core\CortesCaja\Domain\ValueObjects;


class IdCaja
{
    private int $idCaja;

    public function __construct(int $idCaja)
    {
        $this->idCaja = $idCaja;
    }
    function ValidateMayorA0() {
        if ($this->idCaja === 0) {
            return 'El numero de caja debe ser mayor a 0';
        }
        return [true];
    }
    public function getIdCaja(): int
    {
        return $this->idCaja;
    }

}
