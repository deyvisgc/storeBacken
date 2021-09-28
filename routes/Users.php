<?php

$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('User', 'User\UserController@getUser');
    $app->get('getUserByIdPerson/{id}', 'User\UserController@getUserByIdPerson');
    $app->get('User/{idUser}', 'User\UserController@getUserById');
    $app->put('ChangeUser', 'User\UserController@updateUser');
    $app->put('ChangePassword', 'User\UserController@UpdateContraseña');
    $app->put('ChangeStatus', 'User\UserController@ChangeStatus');
    $app->put('RecuperarPassword', 'User\UserController@RecuperarPassword');
    $app->post('DeleteUsersandPerson', 'User\UserController@DeleteUsersandPerson');
    $app->post('UserCreate', 'User\UserController@createUser');
    $app->post('GetPerfil', 'User\UserController@createUser');
    $app->post('SearchUsuario', 'User\UserController@SearchUsuario');
});
