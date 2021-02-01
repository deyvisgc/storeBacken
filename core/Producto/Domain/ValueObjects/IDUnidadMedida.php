<?php


namespace Core\Producto\Domain\ValueObjects;


class IDUnidadMedida
{

    private int $idunidadmedida;

    public function __construct(int $idunidadmedida)
    {

        $this->idunidadmedida = $idunidadmedida;
    }

    /**
     * @return int
     */
    public function getIdunidadmedida(): int
    {
        return $this->idunidadmedida;
    }

}
