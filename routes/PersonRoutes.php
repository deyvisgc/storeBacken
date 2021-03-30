<?php

$router->group(['prefix'=>'api/v1/'], function ($app) {
   $app->get('Person', 'Persona\PersonaController@getPerson');
   $app->get('Person/{idPerson}', 'Persona\PersonaController@getPersonById');
   $app->put('Person', 'Persona\PersonaController@updatePerson');
   $app->delete('Person/{idPerson}', 'Persona\PersonaController@deletePerson');
   $app->post('Person', 'Persona\PersonaController@createPerson');
   $app->post('PersonUser', 'Persona\PersonaController@changeStatusPerson');
});
