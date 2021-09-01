<?php


namespace App\Repository\Almacen\Categorias;


use Carbon\Carbon;

class dtoCategoria
{
    private $classname;
    private $id_Clasesuperior;
    private $idPadre;
    public function __construct($idPadre, $classname, $id_Clasesuperior)
    {

        $this->classname = $classname;
        $this->id_Clasesuperior = $id_Clasesuperior;
        $this->idPadre = $idPadre;
    }

    /**
     * @return mixed
     */
    public function getClassname()
    {
        return $this->classname;
    }

    /**
     * @return mixed
     */
    public function getIdClasesuperior()
    {
        return $this->id_Clasesuperior;
    }

    /**
     * @return mixed
     */
    public function getIdPadre()
    {
        return $this->idPadre;
    }

    function create() : array
    {
        return [
            'clas_id_clase_superior' => $this->id_Clasesuperior,
            'clas_name' => ucwords($this->classname),
            'clas_status' => 'active',
            'fecha_creacion' => Carbon::now(new \DateTimeZone('America/Lima'))->format('Y-m-d')
        ];
    }
    function updateCategoria(): array
    {
        return [
            'clas_name' => ucwords($this->classname)
        ];
    }
    function updateSubCategoria(): array
    {
        return [
            'clas_name' => $this->classname,
            'clas_id_clase_superior' =>$this->id_Clasesuperior
        ];
    }

}
