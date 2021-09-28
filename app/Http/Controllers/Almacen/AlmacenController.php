<?php


namespace App\Http\Controllers\Almacen;


use App\Exports\Excel\Almacen\ExportProduct;
use App\Http\Controllers\Controller;
use App\Repository\Almacen\AlmacenRepositoryInterface;
use App\Repository\RepositoryInterface;
use Barryvdh\DomPDF\Facade as PDF;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;

class AlmacenController extends Controller
{
    /**
     * @var RepositoryInterface
     */
    private RepositoryInterface $repository;

    /**
     * AlmacenController constructor.
     * @param RepositoryInterface $repository
     */
    public function __construct(AlmacenRepositoryInterface $repository)
     {
         $this->repository = $repository;
         $this->middleware('auth');
     }
     public function read(Request $request) {
       return response()->json($this->repository->all($request));
     }
}
