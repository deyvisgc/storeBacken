<?php


namespace Core\Almacen\Unidad\Infraestructure\AdapterBridge;


use Core\Almacen\Unidad\Aplication\UseCases\UpdateCase;
use Core\Almacen\Unidad\Infraestructure\DataBase\UnidadSql;
use Illuminate\Http\Request;

class UpdateBridge
{


    /**
     * @var UnidadSql
     */
    private UnidadSql $productoSql;

    public function __construct(UnidadSql $unidadSql)
    {
        $this->productoSql = $unidadSql;
    }
    public function __invoke(Request $request)
    {
        $id=$request->input('id_unidad');
        $accion=$request->input('accion');
        $um_name=$request->input('um_name');
        $nom_corto=$request->input('um_nombre_corto');
        $create= new UpdateCase($this->productoSql);
      return  $create->__invoke($id, $accion, $um_name, $nom_corto);
    }
}
