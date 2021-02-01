<?php


namespace Core\Almacen\Clase\Domain\Entity;


use Core\Almacen\Clase\Domain\ValueObjects\CLASSNAME;
use Core\Almacen\Clase\Domain\ValueObjects\IDCLASESUPERIOR;

class ClaseEntity
{


    /**
     * @var CLASSNAME
     */
    private CLASSNAME $classname;
    /**
     * @var IDCLASESUPERIOR
     */
    private IDCLASESUPERIOR $id_Clasesuperior;

    public function __construct(CLASSNAME $classname, IDCLASESUPERIOR $id_Clasesuperior)
    {

        $this->classname = $classname;
        $this->id_Clasesuperior = $id_Clasesuperior;
    }

    static function create(CLASSNAME $classname, IDCLASESUPERIOR $id_Clasesuperior)
    {
        return new self($classname, $id_Clasesuperior);
    }

    static function update(CLASSNAME $classname, IDCLASESUPERIOR $id_Clasesuperior)
    {
        return new self($classname, $id_Clasesuperior);
    }


}
