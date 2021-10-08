<?php


namespace App\Repository\Inventario\Movimientos;


use App\Repository\Inventario\Movimientos\Entity\dtoRetiroStockAlmacen;
use App\Repository\RepositoryInterface;

interface MovimientosRepositoryInterface extends RepositoryInterface
{
   function ajustarStock($params);
   function getRepocision($params);
   function trasladoMultiple($params);
   function removeStock(dtoRetiroStockAlmacen $retiroStockAlmacen);
   function obtenerStock($params);
}
