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
    $app->post('search-categoria', 'Almacen\Clase\ClaseController@searchCategoria');
});
//subCategorias
$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('obtener-sub-categorias','Almacen\Clase\ClaseController@ObtenerSubCategorias');
});

//Clase
$router->get('api/v1/Almacen/Clase','Almacen\Clase\ClaseController@Read');
$router->post('api/v1/Almacen/Clase','Almacen\Clase\ClaseController@store');
$router->get('api/v1/Almacen/Clase/superior','Almacen\Clase\ClaseController@getclasesuperior');
$router->get('api/v1/Almacen/Clase/recursiveChildren','Almacen\Clase\ClaseController@recursiveChildren');
$router->get('api/v1/Almacen/Clase/ObtenerclasPadreYhijo/{idpadre}','Almacen\Clase\ClaseController@Obtenerclasexid');
$router->patch('api/v1/Almacen/Clase/ActualizarclasPadreYhijo','Almacen\Clase\ClaseController@update');
$router->get('api/v1/Almacen/Clase/viewchild/{idpadre}','Almacen\Clase\ClaseController@viewchild');
$router->patch('api/v1/Almacen/Clase/Actualizarcate','Almacen\Clase\ClaseController@Actualizarcate');
$router->patch('api/v1/Almacen/Clase/Changestatuscate','Almacen\Clase\ClaseController@Changestatuscate');
$router->patch('api/v1/Almacen/Clase/ChangestatusCateRecursiva','Almacen\Clase\ClaseController@ChangestatusCateRecursiva');
$router->get('api/v1/Almacen/Clase/filtrarxclasepadre/{idpadre}','Almacen\Clase\ClaseController@filtrarxclasepadre');



