<?php


namespace Core\CortesCaja\Domain\ValueObjects;


class IdUsuario
{
    private int $idUsuario;

    public function __construct(int $idUsuario)
    {
        $this->idUsuario = $idUsuario;
    }

    function ValidateMayorA0() {
        if ($this->idUsuario === 0) {
            return 'su numero de usuario debe ser mayor a 0';
        }
        return [true];
    }
    public function getIdUsuario(): int
    {
        return $this->idUsuario;
    }

}
