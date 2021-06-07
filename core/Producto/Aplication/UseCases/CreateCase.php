<?php


namespace Core\Producto\Aplication\UseCases;


use Core\Producto\Domain\Entity\ProductoEntity;
use Core\Producto\Domain\Repositories\ProductoRepository;
use Core\Producto\Domain\ValueObjects\FECHA;
use Core\Producto\Domain\ValueObjects\IDClaseProducto;
use Core\Producto\Domain\ValueObjects\IDPRODUCTO;
use Core\Producto\Domain\ValueObjects\IDSUBLCASE;
use Core\Producto\Domain\ValueObjects\IDUnidadMedida;
use Core\Producto\Domain\ValueObjects\ProCodeBarra;
use Core\Producto\Domain\ValueObjects\ProDescripcion;
use Core\Producto\Domain\ValueObjects\ProNombre;

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

    public function __invoke($id_producto, $pro_nombre,$pro_descripcion, $pro_cod_barra,$id_clase_producto, $id_sub_clase, $id_unidad_medida, $lote, $fecha)
    {
        $id_prod = new IDPRODUCTO($id_producto);
        $nomb = new ProNombre($pro_nombre);
        $pro_descri = new ProDescripcion($pro_descripcion);
        $idclase_prod = new IDClaseProducto($id_clase_producto);
        $id_unida_medi = new IDUnidadMedida($id_unidad_medida);
        $proco_barra = new ProCodeBarra($pro_cod_barra);
        $idsubclase = new IDSUBLCASE($id_sub_clase);
        $fecha = new FECHA($fecha);
        $producto = new ProductoEntity($id_prod, $nomb, $pro_descri, $idclase_prod, $id_unida_medi, $proco_barra, $idsubclase, $fecha);
        return $this->repository->Create($producto, $lote);
    }

}
