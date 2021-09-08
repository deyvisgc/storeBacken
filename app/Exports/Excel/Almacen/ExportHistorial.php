<?php


namespace App\Exports\Excel\Almacen;


use Illuminate\Contracts\View\View;
use Maatwebsite\Excel\Concerns\FromView;

class ExportHistorial implements FromView
{
    private $query;

    public function __construct($data)
    {

        $this->query = $data;
    }
    public function view(): View
    {
        return view('Exportar.Excel.Almacen.historialProducto', [
            'historial' => $this->query
        ]);
    }
}
