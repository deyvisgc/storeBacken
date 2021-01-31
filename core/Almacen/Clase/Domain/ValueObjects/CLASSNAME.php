<?php


namespace Core\Almacen\Clase\Domain\ValueObjects;


class CLASSNAME
{
    private string $class_name;

    public function __construct(string $class_name)
  {
      $this->class_name = $class_name;
  }

    /**
     * @return string
     */
    public function getClassName(): string
    {
        return $this->class_name;
    }

}
