<?php


namespace Core\Producto\Aplication\UseCases;


use Core\Producto\Domain\Entity\ProductoEntity;
use Core\Producto\Domain\Repositories\ProductoRepository;
use Core\Producto\Domain\ValueObjects\FECHA;
use Core\Producto\Domain\ValueObjects\IDClaseProducto;
use Core\Producto\Domain\ValueObjects\IDLOTE;
use Core\Producto\Domain\ValueObjects\IDPRODUCTO;
use Core\Producto\Domain\ValueObjects\IDSUBLCASE;
use Core\Producto\Domain\ValueObjects\IDUnidadMedida;
use Core\Producto\Domain\ValueObjects\ProCantidad;
use Core\Producto\Domain\ValueObjects\ProCantidadMinima;
use Core\Producto\Domain\ValueObjects\ProCode;
use Core\Producto\Domain\ValueObjects\ProCodeBarra;
use Core\Producto\Domain\ValueObjects\ProDescripcion;
use Core\Producto\Domain\ValueObjects\ProNombre;
use Core\Producto\Domain\ValueObjects\ProPrecioCompra;
use Core\Producto\Domain\ValueObjects\ProPrecioVenta;

class CreateCase
{


    /**
     * @var ProductoRepository
     */
    private ProductoRepository $repository;

    public function __construct(ProductoRepository $repository)
    {
        $this->repository = $repository;
    }

    public function __invoke(int $id_producto, string $pro_nombre, float $pro_precio_compra, float $pro_precio_venta, int $pro_cantidad, string $pro_descripcion, string $pro_cod_barra,  int $id_clase_producto, int $id_sub_clase, int $id_unidad_medida, $lote, string $fecha)
    {
        $id_prod = new IDPRODUCTO($id_producto);
        $nomb = new ProNombre($pro_nombre);
        $pre_compra = new ProPrecioCompra($pro_precio_compra);
        $pre_venta = new ProPrecioVenta($pro_precio_venta);
        $pro_can = new ProCantidad($pro_cantidad);
        $pro_descri = new ProDescripcion($pro_descripcion);
        $idclase_prod = new IDClaseProducto($id_clase_producto);
        $id_unida_medi = new IDUnidadMedida($id_unidad_medida);
        $proco_barra = new ProCodeBarra($pro_cod_barra);
        $idsubclase = new IDSUBLCASE($id_sub_clase);
        $fecha = new FECHA($fecha);
        $producto = new ProductoEntity($id_prod, $nomb, $pre_compra, $pre_venta, $pro_can, $pro_descri, $idclase_prod, $id_unida_medi, $proco_barra, $idsubclase, $fecha);
        return $this->repository->Create($producto, $lote);
    }

}
