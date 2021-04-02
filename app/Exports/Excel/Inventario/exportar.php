<?php


namespace App\Exports\Excel\Inventario;


use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromView;

class exportar implements FromView
{
    private $codigo;
    private $nombre;
    private $categoria;

    public function __construct($codigo, $nombre, $categoria)
    {

        $this->codigo = $codigo;
        $this->nombre = $nombre;
        $this->categoria = $categoria;
    }
    public function view(): View
    {
        $query = DB::table('product as p');
        if ($this->codigo) {
            $query->where('pro_code',$this->codigo);
        }
        if ($this->nombre) {
            $query->where('pro_name',$this->nombre);
        }
        if ($this->categoria) {
            $query->where('p.id_clase_producto',$this->categoria);
        }
        $query->join('clase_producto as cl', 'p.id_clase_producto', '=', 'cl.id_clase_producto')
            ->select('p.pro_code', 'p.pro_name','cl.clas_name','p.pro_cantidad','p.pro_precio_venta',
                DB::raw('p.pro_cantidad * p.pro_precio_venta as total'))
            ->orderBy('pro_cantidad','desc');
        $result= $query->get();
        $suma = 0;
        foreach ($result as $value) {
            $suma += $value->total;
        }

        return view('Exportar.Excel.Inventario.inventario', [
            'inventario' => array($result, 'total'=> $suma)
        ]);
    }
}
