<?php


namespace App\Repository\CLientes;


use App\Repository\RepositoryInterface;

interface ClienteRepositoryInterface extends RepositoryInterface
{
    function getTypeCliente();

}
