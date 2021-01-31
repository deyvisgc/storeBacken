<?php


namespace Core\Almacen\Clase\Aplication\UseCases;


use Core\Producto\Domain\Entity\ClaseEntity;
use Core\Producto\Domain\Repositories\ClaseRepository;
use Core\Producto\Domain\ValueObjects\IDClaseProducto;
use Core\Producto\Domain\ValueObjects\IDLOTE;
use Core\Producto\Domain\ValueObjects\IDUnidadMedida;
use Core\Producto\Domain\ValueObjects\ProCantidad;
use Core\Producto\Domain\ValueObjects\ProCantidadMinima;
use Core\Producto\Domain\ValueObjects\ProCode;
use Core\Producto\Domain\ValueObjects\ProCodeBarra;
use Core\Producto\Domain\ValueObjects\ProDescripcion;
use Core\Producto\Domain\ValueObjects\ProNombre;
use Core\Producto\Domain\ValueObjects\ProPrecioCompra;
use Core\Producto\Domain\ValueObjects\ProPrecioVenta;

class DeleteCase
{
    /**
     * @var ClaseRepository
     */
    private ClaseRepository $repository;

    public function __construct(ClaseRepository $repository)
    {
        $this->repository = $repository;
    }
    public function __invokexid(int $idproducto)
    {
        return $this->repository->delete($idproducto);
    }

}
