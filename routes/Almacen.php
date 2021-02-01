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
//Producto
$router->post('api/v1/Almacen/Producto','Almacen\Producto\ProductoController@Store');
$router->patch('api/v1/Almacen/Producto','Almacen\Producto\ProductoController@Update');
$router->get('api/v1/Almacen/Producto','Almacen\Producto\ProductoController@Read');
$router->get('api/v1/Almacen/Producto/{id}','Almacen\Producto\ProductoController@Readxid');
$router->delete('api/v1/Almacen/Producto/{id}','Almacen\Producto\ProductoController@delete');

//SEARCHTRAITS
$router->post('api/v1/Almacen/Producto/SearchxType','Almacen\Producto\ProductoController@SearchxType');

//Lote
$router->get('api/v1/Almacen/Lote','Almacen\Lote\LoteController@Read');

//Unidad Medida
$router->get('api/v1/Almacen/Clase','Almacen\Clase\ClaseController@Read');

//Clase
$router->get('api/v1/Almacen/Unidad','Almacen\Unidad\UnidadMedidaController@Read');
