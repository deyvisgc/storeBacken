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
    $app->get('obtener-unidad-medida','Almacen\Unidad\UnidadMedidaController@Read');
    $app->post('search-unidad-medida', 'Almacen\Unidad\UnidadMedidaController@SearchUnidad');
});

//Lote
$router->get('api/v1/Almacen/Unidad','Almacen\Unidad\UnidadMedidaController@Read');
$router->post('api/v1/Almacen/Unidad','Almacen\Unidad\UnidadMedidaController@store');
$router->patch('api/v1/Almacen/Unidad','Almacen\Unidad\UnidadMedidaController@update');
$router->delete('api/v1/Almacen/Unidad/{id}','Almacen\Unidad\UnidadMedidaController@delete');
$router->patch('api/v1/Almacen/Unidad/ChangestatusUnidad','Almacen\Unidad\UnidadMedidaController@ChangestatusUnidad');
