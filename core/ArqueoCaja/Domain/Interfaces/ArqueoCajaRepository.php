<?php


namespace Core\ArqueoCaja\Domain\Interfaces;




use Core\ArqueoCaja\Domain\Entity\ArqueoEntity;

interface ArqueoCajaRepository
{
    function CreateArqueo(ArqueoEntity $entity);
    function ListArqueo();
    function ObtenerTotales($params);
}
