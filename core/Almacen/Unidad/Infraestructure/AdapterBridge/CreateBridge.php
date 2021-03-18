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
        $um_name=$request['data']['um_name'];
        $nom_corto=$request['data']['um_alias'];
        $fecha_creacion=$request['data']['fecha_creacion'];
        $create= new CreateCase($this->unidadSql);
        return $create->__invoke($um_name, $nom_corto,$fecha_creacion);

    }
}
