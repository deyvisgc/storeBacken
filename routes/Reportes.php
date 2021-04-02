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
    $app->get('Reportes/Inventario','Reportes\InventarioController@Inventario');
    $app->get('Reportes/Pdf','Reportes\InventarioController@Pdf');
    $app->get('Reportes/Exprotar/Inventario','Reportes\InventarioController@ExportarInventario');
    $app->get('Reportes/probar','Reportes\InventarioController@probar');
    $app->post('Reportes/AddSangria','Reportes\Sangria\SangriaController@AddSangria');
    $app->get('Reportes/GetSangria','Reportes\Sangria\SangriaController@GetSangria');
    $app->post('Reportes/DeleteSangria','Reportes\Sangria\SangriaController@DeleteSangria');
    $app->get('Reportes/Exprotar/Sangria','Reportes\Sangria\SangriaController@excel');



});


