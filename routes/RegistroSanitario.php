<?php


$router->group(['prefix'=> 'api/v1/'],function ($app) {
    $app->get('RegistroSanitario', 'RegistroSanitario\RegistroSanitarioController@listarRegistroSanitario');
});

