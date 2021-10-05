<?php


namespace App\Repository\Inventario\Movimientos;


use App\Repository\RepositoryInterface;

interface MovimientosRepositoryInterface extends RepositoryInterface
{
   function ajustarStock($params);
   function getRepocision($params);
   function trasladoMultiple($params);
}
