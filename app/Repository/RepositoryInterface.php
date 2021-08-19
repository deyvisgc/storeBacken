<?php


namespace App\Repository;


interface RepositoryInterface
{
    public function all($params);

    public function create($params);

    public function update(array $data, int $id);

    public function delete(int $id);

    public function find($params);

    public function show(int $id);
}
