<?php

$router->group(['prefix'=> 'api/v1/'], function ($app) {
    $app->get('Privilegios', 'ModulosInfraestructura\Privilegios\PrivilegiosController@listPrivileges');
});
