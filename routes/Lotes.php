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
    $app->get('obtener-lotes','Almacen\Lote\LoteController@getLotes');
    $app->post('search-lotes', 'Almacen\Lote\LoteController@SearchLotes');
});

//Lote
$router->get('api/v1/Almacen/Lote','Almacen\Lote\LoteController@Read');
$router->post('api/v1/Almacen/Lote','Almacen\Lote\LoteController@store');
$router->patch('api/v1/Almacen/Lote','Almacen\Lote\LoteController@update');
$router->delete('api/v1/Almacen/Lote/{id}','Almacen\Lote\LoteController@delete');
$router->patch('api/v1/Almacen/Lote/ChangestatusLote','Almacen\Lote\LoteController@ChangestatusLote');
