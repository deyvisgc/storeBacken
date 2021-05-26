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
    $app->get('obtener-last-idProducto','Almacen\Producto\ProductoController@LastIdProducto');
    $app->post('create-product','Almacen\Producto\ProductoController@Store');
    $app->patch('update-producto','Almacen\Producto\ProductoController@Update');
    $app->patch('ChangeStatus-proudcto','Almacen\Producto\ProductoController@changestatus');
    $app->delete('delete-producto/{id}','Almacen\Producto\ProductoController@delete');

});


