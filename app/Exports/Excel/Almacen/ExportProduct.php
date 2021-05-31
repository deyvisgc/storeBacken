<?php


namespace App\Exports\Excel\Almacen;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromView;

class ExportProduct implements FromView
{
    private $clase;
    private $unidad;
    private $desde;
    private $hasta;
    public function __construct($clase, $unidad, $desde, $hasta)
    {

        $this->clase = $clase;
        $this->unidad = $unidad;
        $this->desde = $desde;
        $this->hasta = $hasta;
    }
    public function view(): View
    {
        $query = DB::table('product as pro');
        if ($this->clase > 0) {
                $query->where('pro.id_clase_producto',$this->clase);
            }
        if ($this->unidad > 0) {
            $query->where('pro.id_unidad_medida',$this->unidad);
        }
        if ($this->desde && $this->hasta) {
            $query->whereBetween('pro.pro_fecha_creacion',[$this->desde, $this->hasta]);
        }

        $query->leftJoin('clase_producto as subclase', 'pro.id_subclase', 'subclase.id_clase_producto')
            ->leftJoin('clase_producto as cp', 'pro.id_clase_producto', '=', 'cp.id_clase_producto')
            ->leftJoin('unidad_medida as um', 'pro.id_unidad_medida', '=', 'um.id_unidad_medida')
            ->select('pro.*', 'cp.clas_name as clasePadre', 'subclase.clas_name as classHijo', 'um.um_name as unidad')
            ->orderBy('id_product', 'Asc')
            ->get();
        $result= $query->get();
        return view('Exportar.Excel.Almacen.producto', [
            'productos' => $result
        ]);
    }
}
