<?php

// This module describes, and creates the database migration service.

function runMigrations(mysqli $conn, string $dir = __DIR__ . '/migrations'): void
{
    if (!is_dir($dir)) {
        throw new Exception("Migration directory not found: $dir");
    }

    // Get migration files
    $files = array_filter(scandir($dir), function ($file) {
        return pathinfo($file, PATHINFO_EXTENSION) === 'php';
    });

    sort($files);

    // Check if migrations table exists
    $migrationsTableExists = false;
    $result = $conn->query("SHOW TABLES LIKE 'migrations'");
    if ($result && $result->num_rows > 0) {
        $migrationsTableExists = true;
    }

    // Load applied migrations
    $applied = [];

    if ($migrationsTableExists) {
        $result = $conn->query("SELECT migration FROM migrations");
        while ($row = $result->fetch_assoc()) {
            $applied[$row['migration']] = true;
        }
    }

    foreach ($files as $file) {
        $name = pathinfo($file, PATHINFO_FILENAME);
        $path = $dir . '/' . $file;


        // Skip if already applied
        if (isset($applied[$name])) {
            //echo "Skipping already applied migration: $name\n";
            continue;
        }

        // Bootstrap migrations table if needed
        if (!$migrationsTableExists) {
            //echo "Bootstrapping migrations table using: $file\n";

            $migration = require $path;

            if (is_callable($migration)) {
                $migration($conn);
            }

            $migrationsTableExists = true;

            // Mark this migration as applied
            $stmt = $conn->prepare("INSERT INTO migrations (migration) VALUES (?)");
            $stmt->bind_param("s", $name);
            $stmt->execute();
            $stmt->close();

            //echo "Migrations table created.\n";
            continue;
        }

        // Skip already applied
        if (isset($applied[$name])) {
            continue;
        }

        //echo "Applying migration: $name\n";

        try {
            $conn->begin_transaction();

            $migration = require $path;

            if (is_callable($migration)) {
                $migration($conn);
            }

            // Record migration
            $stmt = $conn->prepare("INSERT INTO migrations (migration) VALUES (?)");
            $stmt->bind_param("s", $name);
            $stmt->execute();
            $stmt->close();

            $conn->commit();

            //echo "Applied: $name\n";

        } catch (Throwable $e) {
            $conn->rollback();
            //echo "Failed: $name\n";
            throw $e;
        }
    }

    //echo "All migrations complete.\n";
}


?>