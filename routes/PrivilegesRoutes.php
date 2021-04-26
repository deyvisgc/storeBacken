<?php

$router->group(['prefix'=> 'api/v1/'], function ($app) {
    $app->get('Privilegios', 'Privileges\PrivilegesController@listPrivileges');
    $app->get('PrivilegiosRol', 'Privileges\PrivilegesController@listPrivilegesByRol');
    // grupos
    $app->post('AddGrupos', 'Privileges\PrivilegesController@AddGrupos');
    $app->get('GetGrupo', 'Privileges\PrivilegesController@GetGrupo');
    $app->get('GetIcon', 'Privileges\PrivilegesController@listIcon');
    $app->get('GetGrupoDetalle/{idPrivilegio}', 'Privileges\PrivilegesController@GetGrupoDetalle');
    $app->post('DeletePrivilegioGrupo', 'Privileges\PrivilegesController@DeletePrivilegioGrupo');

    //Privilegios
    $app->get('GetPrivilegios', 'Privileges\PrivilegesController@GetPrivilegios');

    $app->patch('UpdatePrivilegios', 'Privileges\PrivilegesController@UpdatePrivilegios');
    $app->patch('ChangeStatus', 'Privileges\PrivilegesController@ChangeStatus');

});
