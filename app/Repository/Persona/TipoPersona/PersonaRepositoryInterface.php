<?php


namespace App\Repository\Persona\TipoPersona;


use App\Repository\RepositoryInterface;

interface PersonaRepositoryInterface extends RepositoryInterface
{
    function searchPerson($client, $params);
    function changeStatus($params);
}
