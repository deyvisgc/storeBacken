<?php


namespace App\Repository\Almacen;


use App\Exports\Excel\Almacen\ExportHistorial;
use App\Exports\Excel\Almacen\ExportProduct;
use App\Http\Excepciones\Exepciones;
use Barryvdh\DomPDF\Facade as PDF;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Facades\Excel;

class AlmacenRepository implements AlmacenRepositoryInterface
{

    public function all($params)
    {
        try {
            $lista = DB::table('almacen')->where('estado', '=', 'active')->get();
            $excepciones = new Exepciones(true, 'Encontrado', 200, $lista);
            return $excepciones->SendStatus();
        } catch (\Exception $exception) {
            $excepciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepciones->SendStatus();
        }
    }

    public function create($params)
    {
        // TODO: Implement create() method.
    }

    public function update(array $data, int $id)
    {
        // TODO: Implement update() method.
    }

    public function delete(int $id)
    {
        // TODO: Implement delete() method.
    }

    public function find($params)
    {
        // TODO: Implement find() method.
    }

    public function show(int $id)
    {
        // TODO: Implement show() method.
    }

    function getHistorial($params)
    {
        try {
            $desde = Carbon::make($params['desde'])->format('Y-m-d');
            $hasta = Carbon::make($params['hasta'])->format('Y-m-d');
            $query = DB::table('product_history as ph');
            if ($desde && $hasta && !$params['fechaVencimiento']) {
                $query->whereBetween('ph.fecha_creacion', [$desde, $hasta]);
            }
            if ($params['fechaVencimiento']) {
                $fechaVencimiento = Carbon::make($params['fechaVencimiento'])->format('Y-m-d');
                $query->where('ph.fecha_vencimiento', $fechaVencimiento);
            }
            if ($params['idProducto'] > 0) {
                $query->where('ph.id_producto', $params['idProducto']);
            }
            if ($params['idLote'] > 0) {
                $query->where('ph.id_lote', $params['idLote']);
            }
            if ($params['idAlmacen'] > 0) {
                $query->where('ph.almacen', $params['idAlmacen']);
            }
            $query->join('product as p', 'ph.id_producto', '=', 'p.id_product')
                  ->join('product_por_lotes as pl', 'ph.id_lote', '=', 'pl.id_lote')
                  ->join('almacen as al', 'ph.almacen', '=', 'al.id')
                  ->select('ph.*', 'p.pro_name', 'pl.lot_name', 'al.descripcion as almacen',
                      'p.pro_precio_compra as preciocompranuevo', 'p.pro_precio_venta as precioventanuevo')
                  ->orderBy('id', 'desc');
            $lista = $query->get();
            $exepcion = new Exepciones(true, 'exito', 200, $lista);
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }

    function exportar($params)
    {
        try {
            $lista = $this->getHistorial($params);
            $opcion = $params->input('isExport');
            if ($opcion === 'excel') {
                return Excel::download(new ExportHistorial($lista['data']), 'reportesHistorial.xlsx')->deleteFileAfterSend (false);
            } else {
                $customPaper = array(0,0,710,710);
                $pdf = PDF::loadView('Exportar.Pdf.Almacen.historialProductos', ['historial'=>$lista['data']])->setPaper($customPaper);
                return $pdf->download('invoice.pdf');
            }
        } catch (\Exception $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }

    }
}
