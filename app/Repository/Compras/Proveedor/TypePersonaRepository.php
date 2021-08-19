<?php


namespace App\Repository\Compras\Proveedor;;
use App\Http\Excepciones\Exepciones;
use Carbon\Carbon;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\BadResponseException;
use Illuminate\Support\Facades\DB;

class TypePersonaRepository implements ProveedorRepositoryInterface
{
    // VARIABLES INSTANCES
    private $client;
    public function __construct(Client $client)
    {
        $this->client = $client;
    }
    public function all($params)
    {
        // TODO: Implement all() method.
    }

    public function create($params)
    {
        try {
            $found = DB::table('persona')->where('per_numero_documento', $params['docNumber'])->exists();
            if ($found) {
                $exepciones = new Exepciones(false,'El proveedor ya existe',403,[]);
                return $exepciones->SendStatus();
            } else {
                $status = DB::table('persona')
                    ->insert([
                        'per_razon_social' => $params['per_razon_social'],
                        'per_tipo_documento' => $params['typeDocument'],
                        'per_numero_documento' => $params['docNumber'],
                        'per_celular' => $params['phone'],
                        'per_tipo' => $params['typePerson'],
                        'per_status' => 'active',
                        'per_direccion' =>$params['address'],
                        'per_email' => $params['email'],
                        'per_nombre' => $params['name']
                    ]);
                if ($status) {
                    $exepciones = new Exepciones(true,'Proveedor registrado correctamente',200,[]);
                } else {
                    $exepciones = new Exepciones(false,'Error al registrar proveedor',403,[]);
                }
                return $exepciones->SendStatus();
            }

        } catch (\Exception $exception) {
            $exepciones = new Exepciones(false,$exception->getMessage(),$exception->getCode(),[]);
            return $exepciones->SendStatus();
        }
    }

    public function update(array $data, $id)
    {
        // TODO: Implement update() method.
    }

    public function delete($id)
    {
        // TODO: Implement delete() method.
    }

    public function find($params)
    {
        try {
            $url = $params['typeSearch'];
            $numberDoc = $params['numeroDocumento'];
            $list = DB::table('persona')->where('per_numero_documento', $numberDoc)->first();
            if ($list) {
                $exepeciones = new Exepciones(true, 'Proveedor Encontrado', 200, $list);
               return $exepeciones->SendStatus();
            } else {
                return  $this->getAPi($url, $numberDoc);
            }
        } catch (\Exception $exception) {
            $exepeciones = new Exepciones(false, $exception->getMessage(), $exception->getCode(), []);
            return $exepeciones->SendStatus();
        }
    }
    function getAPi($url, $number) {
        try {
            $response = $this->client->request('get', "$url/". $number);
            $res = json_decode($response->getBody()->getContents());
            if ($url === 'dni') {
                $lista =  [
                    'per_nombre' => $res->nombres.' '.$res->apellidoPaterno. ' '. $res->apellidoMaterno,
                    'dni' => $res->dni
                ];
            } else {
                $lista = [
                    'per_razon_social' => $res->razonSocial,
                    'ruc' => $res->ruc
                ];
            }
            $exepeciones = new Exepciones(true, 'Proveedor Encontrado', 200, $lista);
            return $exepeciones->SendStatus();

        } catch (BadResponseException $e) {
            $exepeciones = new Exepciones(false, $e->getResponse()->getBody()->getContents(), $e->getCode(), []);
            return $exepeciones->SendStatus();

        }
    }

    public function show(int $id)
    {
        // TODO: Implement show() method.
    }
}
