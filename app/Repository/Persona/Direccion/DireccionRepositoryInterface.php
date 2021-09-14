<?php


namespace App\Repository\Persona\Direccion;


use App\Repository\RepositoryInterface;

interface DireccionRepositoryInterface
{
    function getDepartamento($repository);
    function getProvincia($params);
    function getDistrito($params);
    function searchDepartamento($params);
    function searchProvincia($params);
    function searchDistrito($params);
}
