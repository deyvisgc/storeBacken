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
    $app->get('obtener-categoria','Almacen\Clase\ClaseController@getCategoria');
    $app->get('obtener-categoria/{id}','Almacen\Clase\ClaseController@editCategory');
    $app->post('search-categoria', 'Almacen\Clase\ClaseController@searchCategoria');
    $app->get('Almacen-clase','Almacen\Clase\ClaseController@Read');
    $app->post('Almacen-clase','Almacen\Clase\ClaseController@store');
    $app->get('Almacen-edit-subCategorias','Almacen\Clase\ClaseController@editCategoria');
    $app->patch('Almacen-clase-changeStatusCate','Almacen\Clase\ClaseController@ChangeStatusCate');
});
//subCategorias
$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('obtener-sub-categorias','Almacen\Clase\ClaseController@ObtenerSubCategorias');
    $app->patch('Almacen-sub-categorias-channgeStatus','Almacen\Clase\ClaseController@ChangeStatusSubCate');
});

