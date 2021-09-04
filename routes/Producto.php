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
    $app->get('obtener-producto','Almacen\Producto\ProductoController@read');
    $app->get('obtener-select-producto','Almacen\Producto\ProductoController@selectProducto');
    $app->get('editar-producto/{id}','Almacen\Producto\ProductoController@Edit');
    $app->get('obtener-last-idProducto','Almacen\Producto\ProductoController@LastIdProducto');
    $app->get('generar-codigo-barra','Almacen\Producto\ProductoController@generarCodigo');
    $app->post('create-product','Almacen\Producto\ProductoController@Store');
    $app->get('obtener-sub-categoria/{id}', 'Almacen\Producto\ProductoController@getSubCategoria');
    $app->post('change-status-prouducto','Almacen\Producto\ProductoController@changeStatus');
    $app->delete('delete-producto/{id}','Almacen\Producto\ProductoController@delete');
    $app->get('productos-exportar','Almacen\Producto\ProductoController@Exportar');
    $app->post('search-producto','Almacen\Producto\ProductoController@Search');
    $app->post('ajustar-stock','Almacen\Producto\ProductoController@ajustarStock');
    $app->get('select-atributos-producto','Almacen\Producto\ProductoController@selectAtributos');
});


