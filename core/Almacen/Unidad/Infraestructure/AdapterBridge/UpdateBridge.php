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
    private UnidadSql $unidadsql;

    public function __construct(UnidadSql $unidadSql)
    {
        $this->unidadsql = $unidadSql;
    }
    public function __invoke(Request $request)
    {
        $id=$request['data']['id_unidad_medida'];
        $um_name=$request['data']['unidad_update'];
        $nom_corto=$request['data']['alias_update'];
        $fecha_creacion = $request['data']['fecha_creacion_update'];
        $create= new UpdateCase($this->unidadsql);
      return  $create->__invoke($id, $um_name, $nom_corto, $fecha_creacion);
    }
    public function __changestatus(Request $request) {
        $id=$request['data']['id_unidad_medida'];
        $status=$request['data']['um_status'];
        $UpdateUnidad= new UpdateCase($this->unidadsql);
        return $UpdateUnidad->ChangeStatus($id, $status);
    }
}
