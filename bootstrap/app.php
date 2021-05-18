<?php

require_once __DIR__.'/../vendor/autoload.php';

(new Laravel\Lumen\Bootstrap\LoadEnvironmentVariables(
    dirname(__DIR__)
))->bootstrap();

date_default_timezone_set(env('APP_TIMEZONE', 'UTC'));

/*
|--------------------------------------------------------------------------
| Create The Application
|--------------------------------------------------------------------------
|
| Here we will load the environment and create the Application instance
| that serves as the central piece of this framework. We'll use this
| Application as an "IoC" container and router for this framework.
|
*/

$app = new Laravel\Lumen\Application(
    dirname(__DIR__)
);

$app->withFacades();

$app->withEloquent();

/*
|--------------------------------------------------------------------------
| Register Container Bindings
|--------------------------------------------------------------------------
|
| Now we will register a few bindings in the service container. We will
| register the exception handler and the console kernel. You may add
| your own bindings here if you like or you can make another file.
|
*/

$app->singleton(
    Illuminate\Contracts\Debug\ExceptionHandler::class,
    App\Exceptions\Handler::class
);

$app->singleton(
    Illuminate\Contracts\Console\Kernel::class,
    App\Console\Kernel::class
);

/*
|--------------------------------------------------------------------------
| Register Config Files
|--------------------------------------------------------------------------
|
| Now we will register the "app" configuration file. If the file exists in
| your configuration directory it will be loaded; otherwise, we'll load
| the default version. You may register other files below as needed.
|
*/

$app->configure('app');

/*
|--------------------------------------------------------------------------
| Register Middleware
|--------------------------------------------------------------------------
|
| Next, we will register the middleware with the Application. These can
| be global middleware that run before and after each request into a
| route or middleware that'll be assigned to some specific routes.
|
*/

 $app->middleware([
     App\Http\Middleware\ExampleMiddleware::class,
     'Vluzrmos\LumenCors\CorsMiddleware'
 ]);

 $app->routeMiddleware([
     'auth' => App\Http\Middleware\Authenticate::class,
 ]);

/*
|--------------------------------------------------------------------------
| Register Service Providers
|--------------------------------------------------------------------------
|
| Here we will register all of the Application's service providers which
| are used to bind services into the container. Service providers are
| totally optional, so you are not required to uncomment this line.
|
*/

 $app->register(App\Providers\AppServiceProvider::class);
 $app->register(App\Providers\AuthServiceProvider::class);
 $app->register(App\Providers\EventServiceProvider::class);
 $app->register(Flipbox\LumenGenerator\LumenGeneratorServiceProvider::class);
 $app->register(Maatwebsite\Excel\ExcelServiceProvider::class);
$app->register(\Barryvdh\DomPDF\ServiceProvider::class);
$app->configure('dompdf');
/*
|--------------------------------------------------------------------------
| Load The Application Routes
|--------------------------------------------------------------------------
|
| Next we will include the routes file so that they can all be added to
| the Application. This will provide all of the URLs the Application
| can respond to, as well as the controllers that may handle them.
|
*/
$app->configure('database');

$app->router->group([
    'namespace' => 'App\Http\Controllers',
], function ($router) {
    require __DIR__.'/../routes/web.php';
    require __DIR__.'/../routes/PrivilegesRoutes.php';
    require __DIR__.'/../routes/RolRoutes.php';
    require __DIR__.'/../routes/CajaRoutes.php';
    require __DIR__.'/../routes/RegistroSanitario.php';
    require __DIR__.'/../routes/Almacen.php';
    require __DIR__.'/../routes/PersonRoutes.php';
    require __DIR__.'/../routes/UserRoutes.php';
    require __DIR__.'/../routes/AuthenticationRoutes.php';
    require __DIR__.'/../routes/SangriaRoutes.php';
    require __DIR__.'/../routes/HistorialCajaRoutes.php';
    require __DIR__.'/../routes/Compras.php';
    require __DIR__.'/../routes/Reportes.php';
    require __DIR__.'/../routes/Permisos.php';
    require __DIR__.'/../routes/Categorias.php';
    require __DIR__.'/../routes/Lotes.php';
    require __DIR__.'/../routes/UnidadMedida.php';
    require __DIR__.'/../routes/Producto.php';
});

return $app;
