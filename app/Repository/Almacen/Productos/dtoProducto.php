<?php


namespace App\Repository\Almacen\Productos;



use Carbon\Carbon;
use Illuminate\Support\Facades\Date;

class dtoProducto
{
    private $nombre;
    private $descripcion;
    private $marca;
    private $modelo;
    private $fecha_vencimiento;
    private $unidad_medida;
    private $categoria;
    private $sub_categoria;
    private $precio_compra;
    private $precio_venta;
    private $stock_inicial;
    private $stock_minimo;
    private $tipo_afectacion;
    private $almacen;
    private $lotes;
    private $impuesto_igv;
    private $moneda;
    private $impuesto_bolsa_plastica;
    private $codigo_barra;
    private $id_producto;

    public function __construct($id_producto, $nombre, $descripcion, $codigo_barra, $marca, $modelo, $fecha_vencimiento,
                                $unidad_medida, $categoria, $sub_categoria, $precio_compra, $precio_venta,
                                $stock_inicial, $stock_minimo, $tipo_afectacion, $almacen, $lotes,
                                $impuesto_igv, $moneda, $impuesto_bolsa_plastica)
    {
        $this->id_producto = $id_producto;
        $this->nombre = $nombre;
        $this->descripcion = $descripcion;
        $this->codigo_barra = $codigo_barra;
        $this->marca = $marca;
        $this->modelo = $modelo;
        $this->fecha_vencimiento = $fecha_vencimiento;
        $this->unidad_medida = $unidad_medida;
        $this->categoria = $categoria;
        $this->sub_categoria = $sub_categoria;
        $this->precio_compra = $precio_compra;
        $this->precio_venta = $precio_venta;
        $this->stock_inicial = $stock_inicial;
        $this->stock_minimo = $stock_minimo;
        $this->tipo_afectacion = $tipo_afectacion;
        $this->almacen = $almacen;
        $this->lotes = $lotes;
        $this->impuesto_igv = $impuesto_igv;
        $this->moneda = $moneda;
        $this->impuesto_bolsa_plastica = $impuesto_bolsa_plastica;
    }

    /**
     * @return mixed
     */
    public function getCodigoBarra()
    {
        return $this->codigo_barra;
    }

    /**
     * @return mixed
     */
    public function getNombre()
    {
        return $this->nombre;
    }

    /**
     * @return mixed
     */
    public function getDescripcion()
    {
        return $this->descripcion;
    }

    /**
     * @return mixed
     */
    public function getMarca()
    {
        return $this->marca;
    }

    /**
     * @return mixed
     */
    public function getModelo()
    {
        return $this->modelo;
    }

    /**
     * @return mixed
     */
    public function getFechaVencimiento()
    {
        return $this->fecha_vencimiento;
    }

    /**
     * @return mixed
     */
    public function getUnidadMedida()
    {
        return $this->unidad_medida;
    }

    /**
     * @return mixed
     */
    public function getCategoria()
    {
        return $this->categoria;
    }

    /**
     * @return mixed
     */
    public function getSubCategoria()
    {
        return $this->sub_categoria;
    }

    /**
     * @return mixed
     */
    public function getPrecioCompra()
    {
        return $this->precio_compra;
    }

    /**
     * @return mixed
     */
    public function getPrecioVenta()
    {
        return $this->precio_venta;
    }

    /**
     * @return mixed
     */
    public function getStockInicial()
    {
        return $this->stock_inicial;
    }

    /**
     * @return mixed
     */
    public function getStockMinimo()
    {
        return $this->stock_minimo;
    }

    /**
     * @return mixed
     */
    public function getTipoAfectacion()
    {
        return $this->tipo_afectacion;
    }

    /**
     * @return mixed
     */
    public function getAlmacen()
    {
        return $this->almacen;
    }

    /**
     * @return mixed
     */
    public function getLotes()
    {
        return $this->lotes;
    }

    /**
     * @return mixed
     */
    public function getImpuestoIgv()
    {
        return $this->impuesto_igv;
    }

    /**
     * @return mixed
     */
    public function getMoneda()
    {
        return $this->moneda;
    }

    /**
     * @return mixed
     */
    public function getImpuestoBolsaPlastica()
    {
        return $this->impuesto_bolsa_plastica;
    }

    /**
     * @return mixed
     */
    public function getIdProducto()
    {
        return $this->id_producto;
    }

    function Create(): array {
        return [
            'pro_name' => ucwords(strtolower($this->getNombre())),//agregar la primera letra en mayuscula
            'pro_description' => ucwords(strtolower($this->getDescripcion())),
            'pro_cod_barra' => $this->getCodigoBarra(),
            'pro_fecha_creacion' => Carbon::now(new \DateTimeZone('America/Lima'))->format('Y-m-d H:i:s'),
            'pro_status'=> 'active',
            'pro_marca' => $this->getMarca(),
            'pro_modelo' => $this->getModelo(),
            'pro_fecha_vencimiento' => Carbon::make($this->getFechaVencimiento())->format('Y-m-d H:i:s'),
            'id_unidad_medida' => $this->getUnidadMedida() === 0 ? null: $this->getUnidadMedida(),
            'id_clase_producto' => !$this->getCategoria() ? null : $this->getCategoria(),
            'id_subclase' =>!$this->getSubCategoria() ? null : $this->getSubCategoria(),
            'pro_precio_compra'=>$this->getPrecioCompra(),
            'pro_precio_venta' =>$this->getPrecioVenta(),
            'pro_stock_inicial' =>$this->getStockInicial(),
            'pro_stock_minimo' =>$this->getStockMinimo(),
            'id_afectacion' =>$this->getTipoAfectacion(),
            'id_almacen' => $this->getAlmacen(),
            'id_lote' =>!$this->getLotes() ? null: $this->getLotes(),
            'incluye_igv'=>$this->getImpuestoIgv(),
            'incluye_bolsa' =>$this->getImpuestoBolsaPlastica(),
            'pro_moneda' =>$this->getMoneda()
        ];
    }
    function Update(): array {
        return [
            'pro_name' => ucwords(strtolower($this->getNombre())),//agregar la primera letra en mayuscula
            'pro_description' => ucwords(strtolower($this->getDescripcion())),
            'pro_cod_barra' => $this->getCodigoBarra(),
            'pro_marca' => $this->getMarca(),
            'pro_modelo' => $this->getModelo(),
            'pro_fecha_vencimiento' => $this->getFechaVencimiento(),
            'id_unidad_medida' => $this->getUnidadMedida() === 0 ? null: $this->getUnidadMedida(),
            'id_clase_producto' => $this->getCategoria(),
            'id_subclase' =>$this->getSubCategoria() === 0 ? null: $this->getSubCategoria(),
            'pro_precio_compra'=>$this->getPrecioCompra(),
            'pro_precio_venta' =>$this->getPrecioVenta(),
            'pro_stock_inicial' =>$this->getStockInicial(),
            'pro_stock_minimo' =>$this->getStockMinimo(),
            'id_afectacion' =>$this->getTipoAfectacion(),
            'id_lote' =>$this->getLotes(),
            'incluye_igv'=>$this->getImpuestoIgv(),
            'incluye_bolsa' =>$this->getImpuestoBolsaPlastica(),
            'pro_moneda' =>$this->getMoneda()
        ];
    }
}
