<?php

namespace App\Providers;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * Register any Application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Boot the Authentication services for the Application.
     *
     * @return void
     */
    public function boot()
    {
        // Here you may define how you wish users to be authenticated for your Lumen
        // Application. The callback which receives the incoming request instance
        // should return either a User instance or null. You're free to obtain
        // the User instance via an API token or any other method necessary.

        $this->app['auth']->viaRequest('api', function ($request) {
            if ($request->header('Authorization')) {
                $key = explode(' ', $request->header('Authorization'));
                $user = DB::table('users')->where('us_token', $key[1])->first();
                if (!empty($user)) {
                    $request->request->add(['userid' => $user->id_user]);
                }
                return $user;
            }
            return null;
        });
    }
}
