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
    $app->get('obtener-almacen','Almacen\AlmacenController@read');
});

//SEARCHTRAITS
$router->post('api/v1/Almacen/Producto/SearchxType','Almacen\Producto\ProductoController@SearchxType');
