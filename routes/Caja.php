<?php

$router->group(['prefix'=> 'api/v1/'],function ($app) {
    $app->get('Caja', 'Caja\CajaController@listCaja');
    $app->post('Caja','Caja\CajaController@createCaja');
    $app->put('Caja','Caja\CajaController@updateCaja');
    $app->delete('Caja/{idCaja}','Caja\CajaController@deleteCaja');
    //Administrar Caja
    $app->get('Caja/Administrar', 'Caja\CajaController@totales');
    $app->post('Caja/Aperturar','Caja\CajaController@Aperturar');
    $app->patch('Caja/CerrarCaja','Caja\CajaController@CerrarCaja');
    $app->get('Caja/ValidarCaja','Caja\CajaController@ValidarCaja');
     //Corte Caja
    $app->get('Caja/ObtenerSaldoInicial/{idCaja}','Caja\Cortes\CorteController@ObtenerSaldoInicial');
    $app->get('Caja/corte/ObtenerCorte','Caja\CortesController@ddd');
    $app->post('Caja/corte/GuardarCorteDiario','Caja\Cortes\CorteController@GuardarCorteDiario');
    $app->post('Caja/corte/GuardarCorteSemanal','Caja\Cortes\CorteController@GuardarCorteSemanal');
    $app->get('Caja/corte/SearXFechas','Caja\Cortes\CorteController@SearhCortesXfechas');


    // Arqueo de caja
    $app->get('Caja/Arqueo/ObtenerTotalesArqueo','Caja\Arqueo\ArqueoController@ObtenerTotales');
    $app->post('Caja/Arqueo/GuardarArqueo','Caja\Arqueo\ArqueoController@GuardarArqueo');


});
