<?php
$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->post('LoginUser', 'Authentication\AuthenticationController@loginUser');
    $app->post('LogoutUser', 'Authentication\AuthenticationController@logoutUser');
});
