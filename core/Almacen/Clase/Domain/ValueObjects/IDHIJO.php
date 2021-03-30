<?php


namespace Core\Almacen\Clase\Domain\ValueObjects;


class IDHIJO
{
    private string $idhijo;

    public function __construct(int $idhijo)
  {
      $this->idhijo = $idhijo;
  }

    /**
     * @return int|string
     */
    public function getIdclasesupe()
    {
        return $this->idhijo;
    }


}
