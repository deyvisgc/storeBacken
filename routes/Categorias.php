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
    $app->get('select-categoria','Almacen\Clase\ClaseController@selectCategoria');
    $app->get('Almacen-clase','Almacen\Clase\ClaseController@Read');
    $app->get('obtener-categoria/{id}','Almacen\Clase\ClaseController@editCategory');
    $app->delete('delete/{id}'  ,'Almacen\Clase\ClaseController@delete');
    $app->post('search-categoria', 'Almacen\Clase\ClaseController@searchCategoria');
    $app->post('Almacen-clase','Almacen\Clase\ClaseController@create'); // este url es para crear y editar categoria y sub categoria
    $app->post('change-status-categoria','Almacen\Clase\ClaseController@changeStatus');
});
//subCategorias
$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('Almacen-edit-subCategorias','Almacen\Clase\ClaseController@editSubCategoria');
    $app->get('obtener-sub-categorias','Almacen\Clase\ClaseController@ObtenerSubCategorias');
    $app->delete('delete-sub-categoria/{id}'  ,'Almacen\Clase\ClaseController@deleteSubCategoria');
    $app->post('Almacen-sub-categorias-channgeStatus','Almacen\Clase\ClaseController@changeStatus');
    $app->post('search-sub-categoria', 'Almacen\Clase\ClaseController@searchSubCate');
});

