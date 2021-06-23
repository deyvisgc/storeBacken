<?php


namespace Core\Producto\Domain\Entity;


use Core\Producto\Domain\ValueObjects\FECHA;
use Core\Producto\Domain\ValueObjects\IDClaseProducto;
use Core\Producto\Domain\ValueObjects\IDPRODUCTO;
use Core\Producto\Domain\ValueObjects\IDSUBLCASE;
use Core\Producto\Domain\ValueObjects\IDUnidadMedida;
use Core\Producto\Domain\ValueObjects\ProCantidad;
use Core\Producto\Domain\ValueObjects\ProCodeBarra;
use Core\Producto\Domain\ValueObjects\ProDescripcion;
use Core\Producto\Domain\ValueObjects\ProNombre;
use Core\Producto\Domain\ValueObjects\ProPrecioCompra;
use Core\Producto\Domain\ValueObjects\ProPrecioVenta;

class ProductoEntity
{

    private ProNombre $nombre;
    private ? ProDescripcion $descripcion;
    private IDClaseProducto $IDClaseProducto;
    private ? IDUnidadMedida $unidadMedida;
    private ? ProCodeBarra $barra;
    private $id_producto;
    private ? IDSUBLCASE $id_subclase;
    private  $fecha;
    private ProCantidad $cantidad;
    private ProPrecioCompra $precioCompra;
    private ProPrecioVenta $precioVenta;
    public function __construct(IDPRODUCTO  $id_producto,ProNombre  $nombre, ?ProDescripcion $descripcion, IDClaseProducto $IDClaseProducto,
                                ?IDUnidadMedida $unidadMedida,?ProCodeBarra $barra, ?IDSUBLCASE $id_subclase, FECHA $fecha,
                                ProCantidad $cantidad, ProPrecioCompra $precioCompra, ProPrecioVenta $precioVenta)
    {
        $this->nombre = $nombre;
        $this->descripcion = $descripcion;
        $this->IDClaseProducto = $IDClaseProducto;
        $this->unidadMedida = $unidadMedida;
        $this->barra = $barra;
        $this->id_subclase = $id_subclase;
        $this->fecha = $fecha;
        $this->id_producto = $id_producto;
        $this->cantidad = $cantidad;
        $this->precioCompra = $precioCompra;
        $this->precioVenta = $precioVenta;
    }

    public function getNombre(): string
    {
        return $this->nombre->getProNombre();
    }
    public function getDescripcion(): ?string
    {
        return $this->descripcion->getProDescripcion();
    }
    public function getIDClaseProducto(): int
    {
        return $this->IDClaseProducto->getIdclaseProducto();
    }
    public function getUnidadMedida(): ?int
    {
        return $this->unidadMedida->getIdunidadmedida();
    }
    public function getBarra(): ?string
    {
        return $this->barra->getBarra();
    }
    public function getIdProducto(): int
    {
        return $this->id_producto->getIDProducto();
    }
    public function getIdSubclase(): ?int
    {
        return $this->id_subclase->getIdsubclase();
    }

    public function getFecha(): string
    {
        return $this->fecha-> getFecha();
    }
    public function getCantidad (): int {
        return $this->cantidad->getProCantidad();
    }
    public function getPrecioCompra () :  float {
        return $this->precioCompra->getProPrecioCompra();
    }
    public function getPrecioVenta () : float {
        return $this->precioVenta->getProPrecioVenta();
    }

    /**
     * @param IDPRODUCTO $id_producto
     */
    public function setIdProducto(int $id_producto): void
    {
        $this->id_producto = $id_producto;
    }

    function Create(): array {
        return [
            'pro_name' => ucwords(strtolower($this->nombre->getProNombre())),//agregar la primera letra en mayuscula
            'pro_description' => ucwords(strtolower($this->getDescripcion())),
            'id_clase_producto' => $this->getIDClaseProducto(),
            'id_unidad_medida' => $this->getUnidadMedida() === 0 ? null: $this->getUnidadMedida(),
            'pro_cod_barra' => $this->getBarra(),
            'id_subclase' =>$this->getIdSubclase() === 0 ? null: $this->getIdSubclase(),
            'pro_fecha_creacion' => $this->getFecha(),
            'pro_status'=> 'active'
        ];
    }
    function Update(): array {
        return [
            'pro_name' => ucwords(strtolower($this->nombre->getProNombre())),//agregar la primera letra en mayuscula
            'pro_description' => ucwords(strtolower($this->getDescripcion())),
            'id_clase_producto' => $this->getIDClaseProducto(),
            'id_unidad_medida' => $this->getUnidadMedida() === 0 ? null: $this->getUnidadMedida(),
            'pro_cod_barra' => $this->getBarra(),
            'id_subclase' =>$this->getIdSubclase() === 0 ? null: $this->getIdSubclase(),
            'pro_fecha_creacion' => $this->getFecha()
        ];
    }
    function CreateProductUnidades(): array {
        return [
            'id_product' => $this->id_producto,
            'cantidad' => $this->getCantidad(),
            'precio_venta' => $this->getPrecioVenta(),
            'precio_compra' => $this->getPrecioCompra()
        ];
    }

}
