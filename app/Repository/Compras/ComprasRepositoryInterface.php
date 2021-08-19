<?php


namespace App\Repository\Compras;


use App\Repository\RepositoryInterface;

interface ComprasRepositoryInterface extends RepositoryInterface
{
    function getSerie($params);
}
