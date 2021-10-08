<?php


namespace App\Repository\Inventario\Movimientos;


use App\Exports\Excel\Almacen\ExportHistorial;
use App\Http\Excepciones\Exepciones;
use App\Repository\Almacen\Productos\dtoProducto;
use App\Repository\Inventario\Movimientos\Entity\dtoRetiroStockAlmacen;
use Barryvdh\DomPDF\Facade as PDF;
use Carbon\Carbon;
use Core\Traits\QueryTraits;
use Illuminate\Support\Facades\DB;
use Maatwebsite\Excel\Facades\Excel;

class MovimientosRepository implements MovimientosRepositoryInterface
{
    use QueryTraits;
    public function all($params)
    {
        try {
            $lista = DB::table('inventario as in')
                     ->join('almacen as a', 'in.id_almacen', '=', 'a.id')
                     ->select('in.*', 'a.descripcion as almacen')
                     ->orderByDesc('producto')
                     ->get();
            $excepcion = new Exepciones(true, '', 200, $lista);
            return $excepcion->SendStatus();
        } catch (\Exception $exception) {
            $excepcion = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }
    public function create($params) // trasladar
    {
        DB::beginTransaction();
        try {
            $idInventario = $params['idInventario'];
            $nombre = $params['producto'];
            $idAlmacenOrigen = $params['almacenOrigen'];
            $nombreAlmacenOrigen = $params['nombreAlmacenOrigen'];
            $almacenDestino = (int)$params['almacenDestino'];
            $nombreAlmacenDestino = $params['nombreAlmacenDestino'];
            $stockTrasladar = $params['cantidadAtrasladar'];
            $motivoTraslado = $params['motivoTraslado'];
            $idTraslado =  DB::table('traslado')->insertGetId([
                'fecha_creacion' => Carbon::now(new \DateTimeZone('America/Lima'))->format('Y-m-d H:i'),
                'cantidad_total_producto' => 1
            ]);
            $product = DB::table('inventario')->where('producto', $nombre)->where('id_almacen', $almacenDestino)->first();
            if ($product) {

                DB::table('inventario')->where('id', $product->id)->update([
                    'stock' => DB::raw('stock + '.(int)$stockTrasladar.'')
                ]);
                DB::table('inventario')->where('id', $idInventario)->update([
                    'stock' => DB::raw('stock - '.(int)$stockTrasladar.'')
                ]);
                $this->insertTrasladoHistorial($nombre, $idTraslado, $stockTrasladar, $nombreAlmacenOrigen, $nombreAlmacenDestino, $motivoTraslado);

            } else {
                $inventario = DB::table('inventario')->where('id_almacen', $idAlmacenOrigen)->first();
                DB::table('inventario')->insert([
                    'producto'       => $nombre,
                    'id_producto'    => $inventario->id_producto,
                    'stock'          => $stockTrasladar,
                    'stock_minimo'   =>5,
                    'id_almacen'     =>$almacenDestino,
                    'fecha_creacion' => Carbon::now(new \DateTimeZone('America/Lima'))->format('Y-m-d H:i')
                ]);
                DB::table('inventario')->where('id', (int)$idInventario)->update([
                    'stock' => DB::raw('stock - '.(int)$stockTrasladar.'')
                ]);
                $this->insertTrasladoHistorial($nombre, $idTraslado, $stockTrasladar, $nombreAlmacenOrigen, $nombreAlmacenDestino, $motivoTraslado);
            }
            DB::commit();
            $exepcion = new Exepciones(true,'Traslado entre almacenes exitoso.', 200, []);
            return $exepcion->SendStatus();

        } catch (\Exception $exception) {
            DB::rollback();
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }
    function trasladoMultiple($params)
    {
        DB::beginTransaction();
        try {
            $idTraslado =  DB::table('traslado')->insertGetId([
                'fecha_creacion' => Carbon::now(new \DateTimeZone('America/Lima'))->format('Y-m-d H:i'),
                'cantidad_total_producto' => count($params)
            ]);
            foreach ($params as $items) {
                $product = DB::table('inventario')->where('producto', $items['producto'])->where('id_almacen', $items['id_almacenDestino'])->first();
                if ($product) {

                    DB::table('inventario')->where('id', $product->id)->update([
                        'stock' => DB::raw('stock + '.(int)$items['stocktrasladar'].'')
                    ]);
                    DB::table('inventario')->where('id', $items['id'])->update([
                        'stock' => DB::raw('stock - '.(int)$items['stocktrasladar'].'')
                    ]);
                    $this->insertTrasladoHistorial($items['producto'], $idTraslado, $items['stocktrasladar'], $items['almacen'], $items['nombreAlmacenDestino'], $items['motivoTraslado']);
                } else {
                    $idInventario = DB::table('inventario')->insertGetId([
                        'producto'       => $items['producto'],
                        'stock'          => $items['stocktrasladar'],
                        'stock_minimo'   =>5,
                        'id_almacen'     => $items['id_almacenDestino'],
                        'fecha_creacion' => Carbon::now(new \DateTimeZone('America/Lima'))->format('Y-m-d H:i')
                    ]);

                    $inventario = DB::table('inventario')->where('id', $items['id'])->first();

                    DB::table('inventario')->where('id', $idInventario)->update(['id_producto'=> $inventario->id_producto]);

                    DB::table('inventario')->where('id', $items['id'])->update([
                        'stock' => DB::raw('stock - '.(int)$items['stocktrasladar'].'')
                    ]);
                    $this->insertTrasladoHistorial($items['producto'], $idTraslado, $items['stocktrasladar'], $items['almacen'], $items['nombreAlmacenDestino'], $items['motivoTraslado']);
                }
            }
            DB::commit();
            $exepcion = new Exepciones(true,'Traslado entre almacenes exitoso.', 200, []);
            return $exepcion->SendStatus();
        } catch (\Exception $exception) {
            DB::rollback();
            $exepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepcion->SendStatus();
        }
    }
    function ajustarStock($params)
    {
        DB::beginTransaction();
        try {
            if (count($params['lote']) === 0) {
                $history = DB::table('inventario')
                    ->where('id_producto', $params['id_producto'])
                    ->where('id_almacen', $params['id_almacen'])
                    ->first();
                if ($history) {
                    DB::table('inventario')->where('id', $history->id)
                        ->update([
                            'stock' => DB::raw('stock + '.(int) $params['stock_ajustar'])
                        ]);
                    DB::table('product')->where('id_product', $params['id_producto'])
                        ->update([
                            'pro_precio_compra' => $params['pro_precio_compra'],
                            'pro_precio_venta' => $params['pro_precio_venta'],
                            'pro_fecha_vencimiento' =>$params['pro_fecha_vencimiento']
                        ]);
                    $producto = DB::table('product')->where('id_product', $params['id_producto'])->first();
                    $idHistoria = $this->insertarHistorial($producto, $history->stock, (int)$params['stock'], (int)$params['stock'] + (int) $history->stock);
                    if ($idHistoria > 0) {
                        $status = true;
                        $message = 'Exito al Ajustar Stock';
                    } else {
                        $status = false;
                        $message = 'Error al Insertar en la tabla reposición de productos.';
                    }
                } else {
                    $message = 'El producto no se encuentra en este almacén.';
                    $status = false;
                }
            } else {
                $status =  $this->validarAjustarStock($params['lote']);
                if (count($status) > 0) {
                    $excepciones = new Exepciones(false,'error', 401, ['error'=>$status]);
                    return $excepciones->SendStatus();
                } else {
                    foreach ($params['lote'] as $item) {
                        $history = DB::table('product')
                            ->where('id_producto', $item['id_producto'])
                            ->where('id_almacen', $item['id_almacen'])
                            ->first();
                        if ($history) {
                            DB::table('inventario')->where('id', $history->id)
                                ->update([
                                    'stock' => DB::raw('stock + '.(int) $item['stock_ajustar'])
                                ]);
                            DB::table('product')->where('id_product', $item['id_producto'])
                                ->update([
                                    'pro_precio_compra' => $item['pro_precio_compra'],
                                    'pro_precio_venta' => $item['pro_precio_venta'],
                                    'pro_fecha_vencimiento' =>$item['lot_expiration_date']
                                ]);
                            $producto = DB::table('product')->where('id_product', $params['id_producto'])->first();
                            $this->insertarHistorial($producto, $history->stock, (int)$params['stock'], (int)$params['stock'] + (int) $history->stock);
                        }
                    }
                    $message = 'Exito al Ajustar Stock.';
                }
            }
            DB::commit();
            $excepciones = new Exepciones($status,$message, 200, []);
            return $excepciones->SendStatus();
        } catch (\Exception $exception) {
            DB::rollBack();
            $excepciones = new Exepciones(false,$exception->getMessage(), $exception->getCode(), []);
            return $excepciones->SendStatus();
        }
    }
    function removeStock(dtoRetiroStockAlmacen $retiroStockAlmacen)
    {
        try {
            DB::beginTransaction();
            $inven = DB::table('inventario')->where('id', $retiroStockAlmacen->getId())->first();
            if ($inven->stock === $retiroStockAlmacen->getStockActual()) {
                DB::table('inventario')
                    ->where('id_producto', $retiroStockAlmacen->getIdProducto())
                    ->where('id_almacen', $retiroStockAlmacen->getIdAlmacen())
                    ->update(['stock' => DB::raw('stock - '.$retiroStockAlmacen->getStockRetira().''),]);
                DB::commit();
                $status = DB::table('retiro_almacen')->insert($retiroStockAlmacen->toArray());
                if ($status) {
                    $exepeciones = new Exepciones(true, 'Retiro exitoso', 200, []);
                } else {
                    $exepeciones = new Exepciones(false, 'Error al retirar', 403, []);
                }
            } else {
                $exepeciones = new Exepciones(false, 'EL stock actual es diferente al que se tiene en almacén', 402, []);
            }
            return $exepeciones->SendStatus();
        } catch (\Exception $exception) {
            DB::rollBack();
            $exepeciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepeciones->SendStatus();
        }
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
        try {
            $lista = DB::table('inventario as in')
                ->join('almacen as a', 'in.id_almacen', '=', 'a.id')
                ->where('in.id', $id)
                ->select('in.*', 'a.descripcion as almacen')
                ->get();
            $excepcion = new Exepciones(true, 'exito', 200, $lista[0]);
            return $excepcion->SendStatus();
        } catch (\Exception $exception) {
            $excepcion = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $excepcion->SendStatus();
        }
    }
    function exportar($params)
    {
        try {
            $lista = $this->getRepocision($params);
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
    function getRepocision($params)
    {
        try {
            $desde = Carbon::make($params['desde'])->format('Y-m-d');
            $hasta = Carbon::make($params['hasta'])->format('Y-m-d');
            $query = DB::table('product_history as ph');
            if ($desde && $hasta && !$params['fechaVencimiento']) {
                $query->whereBetween(DB::raw("CONVERT(fecha_creacion, date)"), [$desde, $hasta]);
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
                  ->leftJoin('product_por_lotes as pl', 'ph.id_lote', '=', 'pl.id_lote')
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
    function validarAjustarStock($params) {
        $detalleError = array();
        foreach ($params as $item) {
            if ($item['pro_nombre'] === '') {
                $error = 'El producto  es requerido';
                array_push($detalleError, $error);
            }
            if ($item['codigo_lote'] === '') {
                $error = 'Lote del producto '.$item['pro_nombre']. ' es requerido';
                array_push($detalleError, $error);
            }
            if ($item['lot_expiration_date'] === '') {
                $error = 'La fecha de vencimiento del producto '.$item['pro_nombre'].' es requerido';
                array_push($detalleError, $error);
            }
            if ($item['stock_inicial'] === 0 || !$item['stock_inicial']) {
                $error = 'El stock Inicial del producto '.$item['pro_nombre'].' debe ser mayor a cero';
                array_push($detalleError, $error);
            }
            if ($item['pro_precio_compra'] === 0 || !$item['pro_precio_compra']) {
                $error = 'El precio de compra del producto '.$item['pro_nombre'].' debe ser mayor a cero';
                array_push($detalleError, $error);
            }
            if ($item['pro_precio_venta'] === 0 || !$item['pro_precio_venta']) {
                $error = 'El precio de venta del producto '.$item['pro_nombre'].' debe ser mayor a cero';
                array_push($detalleError, $error);
            }
            if (!$item['almacen']) {
                $error = 'El almacen del producto '.$item['pro_nombre'].' es requerido';
                array_push($detalleError, $error);
            }
        }
        return $detalleError;
    }
    function insertarHistorial($params, $stockAntiguo, $stockNuevo, $stockTotal) {
        $status = DB::table('product_history')->insertGetId([
            'id_producto' => $params->id_product,
            'id_lote' => $params->id_lote,
            'fecha_vencimiento' => $params->pro_fecha_vencimiento,
            'fecha_creacion' =>  Carbon::now(new \DateTimeZone('America/Lima'))->format('Y-m-d h:i'),
            'stock_antiguo' => $stockAntiguo,
            'stock_nuevo' => $stockNuevo,
            'stock_total' => $stockTotal,
            'almacen'=> $params->id_almacen,
            'precio_compra' =>$params->pro_precio_compra,
            'precio_venta' => $params->pro_precio_venta
        ]);
        return $status;
    }
    function insertTrasladoHistorial($producto, $idTraslado, $stock, $nombreAlmacenOrigen, $nombreAlmacenDestino, $motivoTraslado) {
        DB::table('historial_traslado')->insert([
            'producto'        => $producto,
            'id_traslado'     => $idTraslado,
            'stock'           => $stock,
            'almacen_origen'  => $nombreAlmacenOrigen,
            'almacen_destino' => $nombreAlmacenDestino,
            'motivoTraslado'  => $motivoTraslado
        ]);
    }
    function obtenerStock($params)
    {
        try {
            $lista = DB::table('inventario')
                ->where('id_producto', $params['id_producto'])
                ->where('id_almacen', $params['id_almacen'])
                ->select('stock')
                ->first();
            $execpiones = new Exepciones(true, '', 200, $lista);
            return $execpiones->SendStatus();
        } catch (\Exception $exception) {
            $execpiones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), $lista);
            return $execpiones->SendStatus();
        }
    }
}
