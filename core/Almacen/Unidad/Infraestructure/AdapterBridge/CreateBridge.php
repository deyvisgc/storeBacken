<?php


namespace Core\Almacen\Unidad\Infraestructure\AdapterBridge;


use Core\Almacen\Unidad\Aplication\UseCases\CreateCase;
use Core\Almacen\Unidad\Domain\Repositories\UnidadRepository;
use Core\Almacen\Unidad\Infraestructure\DataBase\UnidadSql;
use Illuminate\Http\Request;

class CreateBridge
{


    /**
     * @var UnidadSql
     */
    private UnidadSql $unidadSql;

    public function __construct(UnidadSql $unidadSql)
    {
        $this->unidadSql = $unidadSql;
    }
    public function __invoke(Request $request)
    {
        $accion=$request->input('accion');
        $um_name=$request->input('um_name');
        $nom_corto=$request->input('um_nombre_corto');
        $create= new CreateCase($this->unidadSql);
        return $create->__invoke($accion, $um_name, $nom_corto);

    }
}
