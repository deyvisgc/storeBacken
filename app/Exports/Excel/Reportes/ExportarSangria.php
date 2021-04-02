<?php


namespace App\Exports\Excel\Reportes;


use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromView;

class ExportarSangria implements FromView
{


    private $fechaDesde;
    private $caja;
    private $tipoSangria;
    private $fechaHasta;

    public function __construct($fechaDesde, $FechaHasta, $caja, $tipoSangria)
    {

        $this->fechaDesde = $fechaDesde;
        $this->fechaHasta = $FechaHasta;
        $this->caja = $caja;
        $this->tipoSangria = $tipoSangria;
    }
    public function view(): View
    {
        $query = DB::table('sangria as s');
        if ($this->fechaDesde && $this->fechaHasta) {
            $query->whereBetween('s.san_fecha', [$this->fechaDesde , $this->fechaHasta]);
        }
        if ($this->caja) {
            $query->where('s.id_caja',$this->caja);
        }
        if ($this->tipoSangria) {
            $query->where('s.san_tipo_sangria',$this->tipoSangria);
        }
        $query->join('user as us', 's.id_user', '=', 'us.id_user')
            ->join('persona as per','per.id_user', '=', 'us.id_user')
            ->join('caja as ca', 's.id_caja', '=', 'ca.id_caja')
            ->select('s.*', 'per.per_nombre', 'ca.ca_name')
            ->get();
        $result= $query->get();
        $suma = 0;
        foreach ($result as $value) {
            $suma += $value->san_monto;
        }
        return view('Exportar.Excel.Reportes.Sangria', [
            'sangria' => array($result, 'total'=> $suma)
        ]);
    }
}
