<?php


namespace App\Exports\Excel\Almacen;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromView;

class ExportProduct implements FromView
{
    private $query;

    public function __construct($data)
    {

        $this->query = $data;
    }
    public function view(): View
    {
        return view('Exportar.Excel.Almacen.producto', [
            'productos' => $this->query
        ]);
    }
}
