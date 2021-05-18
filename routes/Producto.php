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
    $app->get('obtener-producto','Almacen\Producto\ProductoController@Read');
    $app->get('edit-producto','Almacen\Producto\ProductoController@Edit');
    $app->patch('update-producto','Almacen\Producto\ProductoController@Update');
    $app->delete('delete-producto/{id}','Almacen\Producto\ProductoController@delete');
    $app->patch('ChangeStatus-proudcto','Almacen\Producto\ProductoController@changestatus');





});
$router->post('api/v1/Almacen/Producto','Almacen\Producto\ProductoController@Store');
$router->get('api/v1/Almacen/LastIdProducto','Almacen\Producto\ProductoController@LastIdProducto');

