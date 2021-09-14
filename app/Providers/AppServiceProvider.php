<?php

namespace App\Providers;

use App\Repository\Almacen\AlmacenRepository;
use App\Repository\Almacen\AlmacenRepositoryInterface;
use App\Repository\Almacen\Categorias\CategoriaRepository;
use App\Repository\Almacen\Categorias\CategoriaRepositoryInterface;
use App\Repository\Almacen\Lotes\LoteRepository;
use App\Repository\Almacen\Lotes\lotRepositoryInterface;
use App\Repository\Almacen\Productos\ProductoRepository;
use App\Repository\Almacen\Productos\ProductoRepositoryInterface;
use App\Repository\Compras\ComprasRepository;
use App\Repository\Compras\ComprasRepositoryInterface;
use App\Repository\Compras\Proveedor\ProveedorRepositoryInterface;
use App\Repository\Compras\Proveedor\TypePersonaRepository;
use App\Repository\Persona\Direccion\DireccionRepository;
use App\Repository\Persona\Direccion\DireccionRepositoryInterface;
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
        $this->app->bind(
            lotRepositoryInterface::class,
            LoteRepository::class
        );
        $this->app->bind(
            CategoriaRepositoryInterface::class,
            CategoriaRepository::class
        );
        $this->app->bind(
            AlmacenRepositoryInterface::class,
            AlmacenRepository::class
        );
        $this->app->bind(
            DireccionRepositoryInterface::class,
            DireccionRepository::class
        );
    }
}
