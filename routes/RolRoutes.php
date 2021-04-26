<?php

$router->group(['prefix'=>'api/v1/'], function ($app){
   $app->get('getRol', 'Rol\RolController@listRol');
   $app->post('CreateRol', 'Rol\RolController@createRol');
   $app->post('Rol/Status', 'Rol\RolController@changeStatus');
   $app->put('Rol', 'Rol\RolController@updateRol');
   $app->delete('Rol/{idRol}', 'Rol\RolController@deleteRol');
});
