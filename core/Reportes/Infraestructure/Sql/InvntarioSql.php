<?php


namespace Core\Reportes\Infraestructure\Sql;


use App\Http\Excepciones\Exepciones;
use Core\Reportes\Domain\InventarioRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
const result = array();
class InvntarioSql implements InventarioRepository
{

    public function Inventario($param)
    {
        try {
            $query = DB::table('product as p');
            if ($param->codigo) {
                $query->where('pro_code',$param->codigo);
            }
            if ($param->nombre) {
                $query->where('pro_name',$param->nombre);
            }
            if ($param->categoria) {
                $query->where('id_clase_producto',$param->categoria);
            }
            if(!$param->codigo && !$param->nombre && !$param->categoria) {
                $categoria= DB::table("clase_producto")->select('*')->get();
            }
            $query->join('clase_producto as cl', 'p.id_clase_producto', '=', 'cl.id_clase_producto')
                ->select('p.pro_code', 'p.pro_name','cl.clas_name','p.pro_cantidad','p.pro_precio_venta', DB::raw('p.pro_cantidad * p.pro_precio_venta as total'))
                ->orderBy('pro_cantidad','desc');
            $result= $query->get();
            $array = result;
            array_push($array,['lista'=>$result],['categoria',$categoria]);
            return $array;
            $exception = new Exepciones(true,'Productos encontrados',200,$result);
           return $exception->SendError();
        } catch (QueryException $exception) {
            $exception = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);
            return $exception->SendError();
        }
    }
}
