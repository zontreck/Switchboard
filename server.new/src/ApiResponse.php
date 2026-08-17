<?php

declare(strict_types=1);

namespace App;

final class ApiResponse
{
    public function __construct(
        public readonly bool $status,
        public readonly array $data = null,
        public readonly array $headers = [],
    ) {
    }
}