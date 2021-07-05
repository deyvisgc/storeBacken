<?php


namespace Core\Almacen\Clase\Infraestructure\AdapterBridge;


use Core\Almacen\Clase\Aplication\UseCases\CreateCase;
use Core\Almacen\Clase\Infraestructure\DataBase\ClaseSql;
use Illuminate\Http\Request;

class CreateBridge
{


    /**
     * @var ClaseSql
     */
    private ClaseSql $claseSql;

    public function __construct(ClaseSql $claseSql)
    {

        $this->claseSql = $claseSql;
    }
    public function categoria($request)
    {
        $idclase=$request['id_categoria'];
        $categoria=$request['nombre_categoria'];
        $clase_superior=$request['clase_superior'];
        $createClass= new CreateCase($this->claseSql);
      return  $createClass->create($idclase, $categoria, $clase_superior);
    }
}
