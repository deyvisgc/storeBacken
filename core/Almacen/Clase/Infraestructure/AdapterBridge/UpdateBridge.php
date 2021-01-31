<?php


namespace Core\Almacen\Clase\Infraestructure\AdapterBridge;



use Core\Almacen\Clase\Aplication\UseCases\UpdateCase;
use Core\Almacen\Clase\Infraestructure\DataBase\ClaseSql;
use Illuminate\Http\Request;


class UpdateBridge
{


    /**
     * @var ClaseSql
     */
    private ClaseSql $productoSql;

    public function __construct(ClaseSql $productoSql)
    {
        $this->productoSql = $productoSql;
    }
    public function __invoke(Request $request)
    {
        $idclase=$request->input('id_clase');
        $accion=$request->input('accion');
        $classnname=$request->input('classname');
        $idclasesupe=$request->input('idclasssuperior');
        $clasecase= new UpdateCase($this->productoSql);
        return $clasecase->__invoke($accion, $classnname, $idclasesupe, $idclase);
    }
}
