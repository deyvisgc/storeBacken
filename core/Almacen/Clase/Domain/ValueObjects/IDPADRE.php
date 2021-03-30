<?php


namespace Core\Almacen\Clase\Domain\ValueObjects;


class IDPADRE
{
    private int $idpadre;

    public function __construct(int $idpadre)
    {
        $this->idpadre = $idpadre;
    }

    /**
     * @return int
     */
    public function getIdpadre(): int
    {
        return $this->idpadre;
    }

}
