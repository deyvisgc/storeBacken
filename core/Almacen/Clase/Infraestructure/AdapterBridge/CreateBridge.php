<?php


namespace Core\Almacen\Clase\Infraestructure\AdapterBridge;


use Core\Almacen\Clase\Aplication\UseCases\CreateCase;
use Core\Almacen\Clase\Infraestructure\DataBase\ClaseSql;
use Core\Producto\Infraestructure\DataBase\ProductoSql;
use Illuminate\Http\Request;

class CreateBridge
{


    /**
     * @var ProductoSql
     */
    private ProductoSql $claseSql;

    public function __construct(ProductoSql $claseSql)
    {

        $this->claseSql = $claseSql;
    }
    public function __invoke(Request $request)
    {
        $accion=$request->input('accion');
        $classnname=$request->input('classname');
        $idclasesupe=$request->input('idclasssuperior');
        $createClass= new CreateCase($this->claseSql);
      return  $createClass->__invoke($accion, $classnname, $idclasesupe);
    }
}
