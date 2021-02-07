<?php


namespace Core\Almacen\Clase\Domain\Entity;


use Core\Almacen\Clase\Domain\ValueObjects\CLASSNAME;
use Core\Almacen\Clase\Domain\ValueObjects\IDHIJO;
use Core\Almacen\Clase\Domain\ValueObjects\IDPADRE;

class ClaseEntity
{


    /**
     * @var CLASSNAME
     */
    private CLASSNAME $classname;
    /**
     * @var IDHIJO
     */
    private IDHIJO $id_Clasesuperior;
    /**
     * @var IDPADRE
     */
    private IDPADRE $IDPADRE;

    public function __construct(CLASSNAME $classname, IDHIJO $id_Clasesuperior)
    {

        $this->classname = $classname;
        $this->id_Clasesuperior = $id_Clasesuperior;
    }

    /**
     * @return CLASSNAME
     */
    public function Classname(): CLASSNAME
    {
        return $this->classname;
    }

    /**
     * @return IDHIJO
     */
    public function IdClasesuperior(): IDHIJO
    {
        return $this->id_Clasesuperior;
    }

    /**
     * @return IDPADRE
     */
    public function IDPADRE(): IDPADRE
    {
        return $this->IDPADRE;
    }

    static function create(CLASSNAME $classname, IDHIJO $id_Clasesuperior)
    {
        return new self($classname, $id_Clasesuperior);
    }

    static function update(IDPADRE $IDPADRE,IDHIJO $id_hijo)
    {
        return ['id_clase_producto' => $IDPADRE->getIdpadre(),'clas_id_clase_superior' => $id_hijo->getIdclasesupe()];
    }


}
