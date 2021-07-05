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

    public function __construct(IDPADRE $idPadre,CLASSNAME $classname, IDHIJO $id_Clasesuperior)
    {

        $this->classname = $classname;
        $this->id_Clasesuperior = $id_Clasesuperior;
        $this->idPadre = $idPadre;
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

     function createCategoria() : array
    {
        return [
            'clas_id_clase_superior' => $this->IdClasesuperior()->getIdclasesupe(),
            'clas_name' => $this->Classname()->getClassName(),
            'clas_status' => 'active'
        ];
    }

     function updateCategoria(): array
    {
        return [
            'clas_name' => $this->Classname()->getClassName()
        ];
    }
    function updateSubCategoria(): array
    {
        return [
            'clas_name' => $this->Classname()->getClassName(),
            'clas_id_clase_superior' =>$this->IdClasesuperior()->getIdclasesupe()
        ];
    }


}
