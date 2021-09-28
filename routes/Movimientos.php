<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an Application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return $router->app->version();
});
$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('obtener-reposicion-producto', 'Inventario\Movimientos\MovimientosController@getRepocision');
    $app->get('reposicion-productos-exportar', 'Inventario\Movimientos\MovimientosController@exportar');
    $app->get('inventario-getMovimiento', 'Inventario\Movimientos\MovimientosController@getMovimiento');
    $app->post('ajustar-stock','Inventario\Movimientos\MovimientosController@ajustarStock');
});