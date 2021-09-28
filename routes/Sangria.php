<?php

$router->group(['prefix'=> 'api/v1/'],function ($app) {
    $app->get('Sangria', 'Sangria\SangriaController@listSangria');
    $app->post('Sangria','Sangria\SangriaController@createSangria');
    $app->put('Sangria','Sangria\SangriaController@updateSangria');
    $app->delete('Sangria/{idSangria}','Sangria\SangriaController@deleteSangria');
});
