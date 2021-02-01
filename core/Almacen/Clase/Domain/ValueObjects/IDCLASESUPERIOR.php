<?php


namespace Core\Almacen\Clase\Domain\ValueObjects;


class IDCLASESUPERIOR
{
    private string $idclasesupe;

    public function __construct(int $idclasesupe)
  {
      $this->idclasesupe = $idclasesupe;
  }

    /**
     * @return string
     */
    public function getClassName(): string
    {
        return $this->idclasesupe;
    }

}
