<?php


namespace Core\Producto\Aplication\UseCases;


use Core\Producto\Domain\Entity\ProductoEntity;
use Core\Producto\Domain\Repositories\ProductoRepository;
use Core\Producto\Domain\ValueObjects\IDClaseProducto;
use Core\Producto\Domain\ValueObjects\IDLOTE;
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

    public function __invoke(string $pro_nombre, float $pro_precio_compra, float $pro_precio_venta, int $pro_cantidad, int $pro_cantidad_min,
                             string $pro_description, int $id_lote, int $id_clase_producto, int $id_unidad_medida, string $pro_cod_barra, string $pro_code, int $subclase)
    {
        $nomb = new ProNombre($pro_nombre);
        $pre_compra = new ProPrecioCompra($pro_precio_compra);
        $pre_venta = new ProPrecioVenta($pro_precio_venta);
        $pro_can = new ProCantidad($pro_cantidad);
        $pro_can_min = new ProCantidadMinima($pro_cantidad_min);
        $pro_descri = new ProDescripcion($pro_description);
        $idlote = new IDLOTE($id_lote);
        $idclase_prod = new IDClaseProducto($id_clase_producto);
        $id_unida_ned = new IDUnidadMedida($id_unidad_medida);
        $proco_barra = new ProCodeBarra($pro_cod_barra);
        $pro_code = new ProCode($pro_code);
        $idsubclase = new IDSUBLCASE($subclase);
        $Producto = ProductoEntity::create($nomb,
            $pre_compra,
            $pre_venta,
            $pro_can,
            $pro_can_min,
            $pro_descri,
            $idlote,
            $idclase_prod,
            $id_unida_ned,
            $pro_code,
            $proco_barra,
            $idsubclase);
        return $this->repository->Create($Producto);
    }

}
