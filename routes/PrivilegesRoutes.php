<?php

$router->group(['prefix'=> 'api/v1/'], function ($app) {
    $app->get('Privilegios', 'Privileges\PrivilegesController@listPrivileges');
    $app->post('PrivilegiosRol', 'Privileges\PrivilegesController@listPrivilegesByRol');
});
