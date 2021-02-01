<?php


$router->group(['prefix'=> 'api/v1/'],function ($app) {
    $app->get('RegistroSanitario', 'RegistroSanitario\RegistroSanitarioController@listarRegistroSanitario');
    $app->post('RegistroSanitario','RegistroSanitario\RegistroSanitarioController@createRegistro');
    $app->put('RegistroSanitario','RegistroSanitario\RegistroSanitarioController@updateRegistro');
    $app->delete('RegistroSanitario/{idRegistroSanitario}','RegistroSanitario\RegistroSanitarioController@deleteRegistro');
});

