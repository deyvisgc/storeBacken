<?php


namespace App\Traits\Search;


use Illuminate\Support\Facades\DB;

trait SeacrhTraits
{
    public function seachxlote (int $idlote) {

        return DB::table('product as pro')
            ->join('lote as l','pro.id_lote','=','l.id_lote')
            ->where('pro.id_lote',$idlote)
            ->select('pro.*','l.lot_name as lote')
            ->orderBy('id_product','Asc')
            ->get();
    }
    public function seachxclase (int $idclase) {
        return DB::table('product as pro')
            ->join('clase_producto as cp','pro.id_clase_producto', '=', 'cp.id_clase_producto')
            ->where('pro.id_clase_producto',$idclase)
            ->select('pro.*','cp.*')
            ->orderBy('id_product','Asc')
            ->get();
    }
    public function seachxunidad (int $id_unidad) {
        return DB::table('product as pro')
            ->join('unidad_medida as um', 'pro.id_unidad_medida','=', 'um.id_unidad_medida')
            ->where('pro.id_unidad_medida',$id_unidad)
            ->select('pro.*','um.*')
            ->orderBy('id_product','Asc')
            ->get();
    }
}
