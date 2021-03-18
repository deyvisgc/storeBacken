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
//Search
$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('Compras/Proveedor', 'Compras\ComprasController@Proveedor');
    $app->post('Compras/Addcar','Compras\ComprasController@Addcar');
    $app->get('Compras/ListarCarr/{idPersona}','Compras\ComprasController@ListarCarr');
    $app->patch('Compras/UpdateCantidad','Compras\ComprasController@UpdateCantidad');
    $app->post('Compras/Delete','Compras\ComprasController@Delete');
    $app->post('Compras/Pagar','Compras\ComprasController@Pagar');
});
$router->get('api/v1/Almacen/Clase','Almacen\Clase\ClaseController@Read');


