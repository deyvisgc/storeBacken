<?php

$router->group(['prefix'=>'api/v1/'], function ($app){
   $app->post('Guardar', 'Permisos\PermisosController@AddPermisos');
   $app->get('ListPermisos', 'Permisos\PermisosController@ListPermisos');
    $app->post('deletePermisos', 'Permisos\PermisosController@deletePermisos');
});
