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
    public function ChangeStatusCate($request)
    {
        $idclase=$request['id_clase_producto'];
        $status=$request['clas_status'];
        $clasecase= new UpdateCase($this->productoSql);
        return $clasecase->ChangeStatus($idclase,$status);
    }
     function ChangeStatusSubCate($request)
    {
        $idclase=$request['id'];
        $status=$request['status'];
        $clasecase= new UpdateCase($this->productoSql);
        return $clasecase->ChangeStatusSubCate($idclase,$status);
    }
}
