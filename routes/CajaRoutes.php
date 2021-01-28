<?php

$router->group(['prefix'=> 'api/v1/'],function ($app) {
    $app->get('Caja', 'Caja\CajaController@listCaja');
    $app->post('Caja','Caja\CajaController@createCaja');
    $app->put('Caja','Caja\CajaController@updateCaja');
    $app->delete('Caja/{idCaja}','Caja\CajaController@deleteCaja');
});
