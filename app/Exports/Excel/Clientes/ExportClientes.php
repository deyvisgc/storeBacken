<?php


namespace App\Exports\Excel\Clientes;
use Illuminate\Contracts\View\View;
use Maatwebsite\Excel\Concerns\FromView;

class ExportClientes implements FromView
{
    private $query;
    private $titulo;

    public function __construct($data, $titulo)
    {

        $this->query = $data;
        $this->titulo = $titulo;
    }
    public function view(): View
    {
        return view('Exportar.Excel.Clientes.Clientes', [
            'cliente' => $this->query,
            'titulo' =>$this->titulo
        ]);
    }
    public function title(): string
    {
        return 'Month';
    }
}
