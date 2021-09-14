<?php

$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->get('obtener-person', 'Persona\PersonaController@getPerson');
    $app->get('obtener-personById/{idPerson}', 'Persona\PersonaController@getPersonById');
    $app->put('update-person', 'Persona\PersonaController@updatePerson');
    $app->put('update-status', 'Persona\PersonaController@updateStatusPerson');
    $app->post('delete-person', 'Persona\PersonaController@deletePerson');
    $app->post('crear-person', 'Persona\TipoPersonaController@createPerson');
    $app->get('search-person', 'Persona\TipoPersonaController@find');
    // ubigeo peru
    $app->get('seleccionar-departamento', 'Persona\PersonaController@getDepartamento');
    $app->get('seleccionar-provincia', 'Persona\PersonaController@getProvincia');
    $app->get('seleccionar-distrito', 'Persona\PersonaController@getDistrito');
    $app->post('search-departamento', 'Persona\PersonaController@searchDepartamento');
    $app->post('search-provincias', 'Persona\PersonaController@searchProvincia');
    $app->post('search-distrito', 'Persona\PersonaController@searchDistrito');
});
