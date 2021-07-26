<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any Application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->bind(
            'App\Repository\Compras\ComprasRepositoryInterface',
            'App\Repository\Compras\TypePersonaRepository'
        );
    }
}
