<?php
$router->group(['prefix'=> 'api/v1/'],function ($app) {
    $app->get('HistorialCaja', 'HistorialCaja\HistorialCajaController@listHistorialCaja');
    $app->post('HistorialCaja','HistorialCaja\HistorialCajaController@createHistorialCaja');
    $app->put('HistorialCaja','HistorialCaja\HistorialCajaController@updateHistorial');
    $app->delete('HistorialCaja/{idCajaHistory}','HistorialCaja\HistorialCajaController@deleteHistorialCaja');
});
