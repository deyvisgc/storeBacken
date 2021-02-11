<?php


namespace Core\Producto\Domain\ValueObjects;


class IDSUBLCASE
{
    private int $idsubclase;

    public function __construct(int $idsubclase)
    {
        $this->idsubclase = $idsubclase;
    }
    public function getIdsubclase(): int
    {
        return $this->idsubclase;
    }

}
