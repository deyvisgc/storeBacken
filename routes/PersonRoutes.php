<?php

$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('obtener-person', 'Persona\PersonaController@getPerson');
    $app->get('Person/{idPerson}', 'Persona\PersonaController@getPersonById');
    $app->put('Person', 'Persona\PersonaController@updatePerson');
    $app->delete('Person/{idPerson}', 'Persona\PersonaController@deletePerson');
    $app->post('crear-person', 'Persona\PersonaController@createPerson');
    $app->post('PersonUser', 'Persona\PersonaController@changeStatusPerson');
});
