<?php


namespace Core\Traits;


use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

trait QueryTraits
{
    public function Clasehijoxidpadre(int $idpadre)
    {
        return DB::select("select  subclase.clasehijo, subclase.clas_id_clase_superior, subclase.id_clase_producto from
                              (select clas_name as clasehijo ,clas_id_clase_superior, id_clase_producto  from
                              clase_producto where clas_id_clase_superior <> 0) as subclase,
                              clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior and subclase.clas_id_clase_superior=$idpadre group by cp.clas_name, id_clase_producto");
    }
    public function Clasehijo()
    {
        return DB::select(" select  subclase.clasehijo, subclase.clas_id_clase_superior, subclase.id_clase_producto from
                              (select clas_name as clasehijo ,clas_id_clase_superior, id_clase_producto  from
                              clase_producto where clas_id_clase_superior <> 0) as subclase,
                              clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior  group by cp.clas_name, id_clase_producto");
    }
    public function ClasePadre()
    {
        return DB::select("select cp.clas_name as clasepadre, cp.id_clase_producto from (select clas_id_clase_superior, clas_status from
                                  clase_producto where clas_id_clase_superior <> 0) as subclase,
                                  clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior or cp.clas_id_clase_superior = 0 group by cp.clas_name, id_clase_producto");
    }
    public function Padreehijoclase()
    {
        return DB::select("select cp.clas_name as clasepadre,
       subclase.clas_name as clasehijo,
       subclase.clas_status as statushijo,
       cp.clas_status as statuspadre,
       cp.id_clase_producto as idpadre,
       cp.clas_id_clase_superior,
       subclase.id_clase_producto as idhijo
       from
       (select clas_name,clas_id_clase_superior, clas_status,id_clase_producto from
       clase_producto where clas_id_clase_superior <> 0) as subclase,
       clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior
       order by cp.id_clase_producto asc");
    }
    public function Padreehijoclasexid(int $idpadre)
    {
        return DB::select("select cp.clas_name as clasepadre,
       subclase.clas_name as clasehijo,
       subclase.clas_status as statushijo,
       cp.clas_status as statuspadre,
       cp.id_clase_producto as idpadre,
       cp.clas_id_clase_superior,
       subclase.id_clase_producto as idhijo
       from
       (select clas_name,clas_id_clase_superior, clas_status,id_clase_producto from
       clase_producto where clas_id_clase_superior <> 0) as subclase,
       clase_producto as cp where cp.id_clase_producto = subclase.clas_id_clase_superior and cp.id_clase_producto =$idpadre
       order by cp.id_clase_producto asc");
    }
    public function ReadCompraxid(int $idCompra) {
       return DB::table('detalle_compra as dt')
            ->join('compra as c', 'dt.idCompra', '=', 'c.idCompra')
            ->join('product as pr', 'dt.idProduct', '=', 'pr.id_product')
            ->select('dt.idCompraDetalle as id', 'dt.dcCantidad as cantidad',
                'dt.dcPrecioUnitario as precio', 'dt.dcSubTotal as subTotal', 'dt.idCompra as codecompra',
                'pr.pro_name as producto')
            ->orderBy('dt.idCompraDetalle','desc')
            ->where('dt.idCompra', '=', $idCompra)
            ->get();
    }
    public function ValidarCajaXusuario(int $idCaja, int $idUsuario) {
       $caja = DB::table('caja')
               ->where('id_caja', $idCaja)
               ->where('id_user', $idUsuario)
               ->exists();
      return $caja;
    }

    function ValidarCaja($idcaja, $idUsers) {
        $query = DB::table('caja')
            ->where([[ 'id_caja', '=', $idcaja], ['id_user', '=', $idUsers], ['ca_status', '=', 'open']])
            ->first();
        return response()->json($query);
    }
    function SearchXRangeDate ($idCaja, $fechaDesde, $fechaHasta) {
        $ingresos =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_total_dinero), 0) as totalIngreso'))
            ->where('ch.id_caja', $idCaja)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'ingreso')
            ->whereBetween(DB::raw('DATE(ch.ch_fecha_operacion)'), [$fechaDesde , $fechaHasta])
            ->first();
        $salidas =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_total_dinero), 0) as totalSalidas'))
            ->where('ch.id_caja', $idCaja)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'salida')
            ->whereBetween(DB::raw('DATE(ch.ch_fecha_operacion)'), [$fechaDesde , $fechaHasta])
            ->first();
        $devoluciones =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_total_dinero), 0) as totalDevoluciones'))
            ->where('c.ca_status', '=', 'open')
            ->where('ch.id_caja', $idCaja)
            ->where('ch.ch_tipo_operacion', '=', 'devolucion')
            ->whereBetween(DB::raw('DATE(ch.ch_fecha_operacion)'), [$fechaDesde , $fechaHasta])
            ->first();
        $montoInicial =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_total_dinero), 0) as montoInicial'))
            ->where('c.ca_status', '=', 'open')
            ->where('ch.id_caja', $idCaja)
            ->where('ch.ch_tipo_operacion', '=', 'apertura')
            ->whereBetween(DB::raw('DATE(ch.ch_fecha_operacion)'), [$fechaDesde , $fechaHasta])
            ->first();
        return array($montoInicial, $ingresos, $salidas,$devoluciones);
    }
    function SearchNowDate ($idCaja, $fechaHoy) {
        $ingresos =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_total_dinero), 0) as totalIngreso'))
            ->where('ch.id_caja', $idCaja)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'ingreso')
            ->where(DB::raw('DATE(ch.ch_fecha_operacion)'), $fechaHoy)
            ->first();
        $salidas =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_total_dinero), 0) as totalSalidas'))
            ->where('ch.id_caja', $idCaja)
            ->where('c.ca_status', '=', 'open')
            ->where('ch.ch_tipo_operacion', '=', 'salida')
            ->where(DB::raw('DATE(ch.ch_fecha_operacion)'), $fechaHoy)
            ->first();
        $devoluciones =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_total_dinero), 0) as totalDevoluciones'))
            ->where('c.ca_status', '=', 'open')
            ->where('ch.id_caja', $idCaja)
            ->where('ch.ch_tipo_operacion', '=', 'devolucion')
            ->where(DB::raw('DATE(ch.ch_fecha_operacion)'), $fechaHoy)
            ->first();
        $montoInicial =  DB::table('caja_historial as ch')
            ->join('caja as c', 'ch.id_caja', '=', 'c.id_caja')
            ->select(DB::raw('IFNULL(SUM(ch.ch_total_dinero), 0) as montoInicial'))
            ->where('c.ca_status', '=', 'open')
            ->where('ch.id_caja', $idCaja)
            ->where('ch.ch_tipo_operacion', '=', 'apertura')
            ->where(DB::raw('DATE(ch.ch_fecha_operacion)'), $fechaHoy)
            ->first();
        return array($montoInicial, $ingresos, $salidas,$devoluciones);
    }

}
