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
    public function __invoke(Request $request)
    {
        $classnname=$request['data']['Cla_nombre'];
        $idclasesupe=$request['data']['clase_superior'];
        $createClass= new CreateCase($this->claseSql);
        if ($idclasesupe == '') {
            $idclasesupe=0;
        }
      return  $createClass->__invoke($classnname, $idclasesupe);
    }
}
