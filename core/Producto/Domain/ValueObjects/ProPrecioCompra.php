<?php


namespace Core\Producto\Domain\ValueObjects;


/**
 * @property string ProPrecioCompra
 */
class ProPrecioCompra
{


    private float $pro_precio_Compra;

    public function __construct(float $ProPrecioCompra)
    {
        $this->pro_precio_Compra = $ProPrecioCompra;
    }

    public function getProPrecioCompra(): float
    {
        return $this->pro_precio_Compra;
    }


}
