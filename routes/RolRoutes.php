<?php

$router->group(['prefix'=>'api/v1/'], function ($app){
   $app->get('Rol', 'Rol\RolController@listRol');
   $app->get('Rol/{idRol}', 'Rol\RolController@listRolById');
   $app->post('Rol', 'Rol\RolController@createRol');
   $app->put('Rol', 'Rol\RolController@updateRol');
   $app->delete('Rol/{idRol}', 'Rol\RolController@deleteRol');
});
