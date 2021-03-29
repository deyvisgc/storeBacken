<?php


namespace App\Exports\Excel;


use Core\Traits\QueryTraits;
use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Maatwebsite\Excel\Concerns\FromView;
use Maatwebsite\Excel\Concerns\WithCustomStartCell;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;

class ComprasCreditoBuyID  implements FromView, WithTitle
{
    private $id;
    use QueryTraits;

    public function __construct($id)
    {
        $this->id = $id;
    }

    public function view(): View
    {
        Log::info('error '.$this->id);
        return view('Exportar.Excel.DetalleCompras', [
            'compras' => $this->ReadCompraxid($this->id)
        ]);
    }
    public function title(): string
    {
        return 'Detalle';
    }

}
