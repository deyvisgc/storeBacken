<?php

$router->group(['prefix'=>'api/v1/'], function ($app) {
    $app->post('crear-person', 'Persona\PersonaController@createPerson');
    $app->get('obtener-person', 'Persona\PersonaController@getPerson');
    $app->get('obtener-personById/{idPerson}', 'Persona\PersonaController@getPersonById');
    $app->get('search-person', 'Persona\PersonaController@searchPerson');
    $app->post('change-status-cliente', 'Persona\PersonaController@changeStatus');
    $app->delete('delete-cliente/{id}', 'Persona\PersonaController@deletePerson');
    $app->get('clientes-exportar', 'Persona\PersonaController@exportar');
    // ubigeo peru
    $app->get('seleccionar-departamento', 'Persona\PersonaController@getDepartamento');
    $app->get('seleccionar-provincia', 'Persona\PersonaController@getProvincia');
    $app->get('seleccionar-distrito', 'Persona\PersonaController@getDistrito');
    $app->post('search-departamento', 'Persona\PersonaController@searchDepartamento');
    $app->post('search-provincias', 'Persona\PersonaController@searchProvincia');
    $app->post('search-distrito', 'Persona\PersonaController@searchDistrito');
    // Tipo Cliente
    $app->get('obtener-tipo-cliente', 'Persona\TipoClienteController@getTipo');
    $app->get('obtener-tipo-cliente/{id}', 'Persona\TipoClienteController@getTipoXid');
    $app->post('crear-tipo-cliente', 'Persona\TipoClienteController@create');
    $app->delete('delete-tipo-cliente/{id}',  'Persona\TipoClienteController@delete');
    $app->post('change-status-tipo-cliente', 'Persona\TipoClienteController@changeStatus');

});
