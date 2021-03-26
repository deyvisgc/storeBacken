<?php


namespace App\Exports\Excel;


use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Concerns\FromView;
use Maatwebsite\Excel\Concerns\WithCustomStartCell;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithTitle;

class ComprasCreditoBuyID  implements WithTitle
{
    private $id;

    public function __construct($id)
    {
        $this->id = $id;
    }

    public function view(): View
    {
        /*Log::info('err '.$result);*/
        return view('Exportar.Excel.DetalleCompras', [
            'compras' => DB::table('detalle_compra as dt')
                         ->join('compra as c', 'dt.idCompra', '=', 'c.idCompra')
                         ->join('product as pr', 'dt.idProduct', '=', 'pr.id_product')
                         ->select('dt.idCompraDetalle as id', 'dt.dcCantidad as cantidad',
                             'dt.dcPrecioUnitario as precio', 'dt.dcSubTotal as subTotal', 'dt.idCompra as codecompra',
                              'pr.pro_name as producto')
                         ->orderBy('dt.idCompraDetalle','desc')
                         ->where('dt.idCompra', '=', $this->id)
                         ->get()
        ]);
    }
    public function title(): string
    {
        return 'Detalle';
    }

}
