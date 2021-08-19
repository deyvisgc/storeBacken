<?php

namespace App\Providers;

use App\Repository\Almacen\Productos\ProductoRepository;
use App\Repository\Almacen\Productos\ProductoRepositoryInterface;
use App\Repository\Compras\ComprasRepository;
use App\Repository\Compras\ComprasRepositoryInterface;
use App\Repository\Compras\Proveedor\ProveedorRepositoryInterface;
use App\Repository\Compras\Proveedor\TypePersonaRepository;
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
            ProveedorRepositoryInterface::class,
            TypePersonaRepository::class
        );
        $this->app->bind(
            ComprasRepositoryInterface::class,
            ComprasRepository::class
        );
        $this->app->bind(
            ProductoRepositoryInterface::class,
            ProductoRepository::class
        );
    }
}
