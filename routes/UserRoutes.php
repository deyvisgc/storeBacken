<?php

$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('User', 'User\UserController@getUser');
    $app->get('User/{idUser}', 'User\UserController@getUserById');
    $app->put('User', 'User\UserController@updateUser');
    $app->delete('User/{idUser}', 'User\UserController@deleteUser');
    $app->post('User', 'User\UserController@createUser');
});
