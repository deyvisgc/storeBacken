<?php

$router->group(['prefix'=> 'api/v1/'],function ($app) {
    $app->get('Caja', 'Caja\CajaController@listCaja');
    $app->post('Caja','Caja\CajaController@createCaja');
    $app->put('Caja','Caja\CajaController@updateCaja');
    $app->delete('Caja/{idCaja}','Caja\CajaController@deleteCaja');
    $app->get('Caja/Administrar', 'Caja\CajaController@totales');
    $app->post('Caja/Aperturar','Caja\CajaController@Aperturar');
    $app->patch('Caja/CerrarCaja','Caja\CajaController@CerrarCaja');
    $app->get('Caja/ValidarCaja','Caja\CajaController@ValidarCaja');
    $app->get('Caja/ObtenerSaldoInicial/{idCaja}','Caja\CajaController@ObtenerSaldoInicial');
    $app->post('Caja/GuardarCorteDiario','Caja\CajaController@GuardarCorteDiario');
    $app->post('Caja/GuardarCorteSemanal','Caja\CajaController@GuardarCorteSemanal');
    $app->get('Caja/SearXFechas','Caja\CajaController@SearhCortesXfechas');

    // Arqueo de caja
    $app->get('Caja/Arequeo/ObtenerTotalesArqueo','Caja\Arqueo\ArqueoController@ObtenerTotales');
    $app->post('Caja/Arequeo/GuardarArqueo','Caja\Arqueo\ArqueoController@GuardarArqueo');


});
