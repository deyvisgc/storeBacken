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
    public function __invoke($request)
    {
        $accion=$request['accion'];
        $idpadre=$request['clasePadre'];
        $idhijo=$request['clasehijo'];
        $clasecase= new UpdateCase($this->productoSql);
        return $clasecase->__invoke($accion, $idpadre, $idhijo);
    }
    public function __Actualizarcate($request)
    {
        $idclase=$request['idclase'];
        $name=$request['Cla_nombre'];
        $clasecase= new UpdateCase($this->productoSql);
        return $clasecase->Actualizaracate($idclase, $name);
    }
    public function __Changestatu($request)
    {
        $idclase=$request['id_clase_producto'];
        $status=$request['clas_status'];
        $clasecase= new UpdateCase($this->productoSql);
        return $clasecase->ChangeStatus($idclase,$status);
    }
    public function __ChangestatuRecursiva($request)
    {
        $idclase=$request[0];//idclase
        $status=$request[1]; // valor del estado hijo
        $clasecase= new UpdateCase($this->productoSql);
        return $clasecase->ChangeStatusRecursiva($idclase,$status);
    }
}
