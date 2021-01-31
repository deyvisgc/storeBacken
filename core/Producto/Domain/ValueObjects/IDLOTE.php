<?php


namespace Core\Producto\Domain\ValueObjects;


class IDLOTE
{
    private int $idlote;

    public function __construct(int $idlote)
    {

        $this->idlote = $idlote;
    }

    /**
     * @return int
     */
    public function getIdlote(): int
    {
        return $this->idlote;
    }

}
