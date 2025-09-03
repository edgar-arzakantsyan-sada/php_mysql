# Setting up a Website with Simple Front-End, PHP Back-End, and MySQL Database

This documentation provides a step-by-step guide to setting up a basic web application consisting of a static HTML front-end, a PHP back-end for processing form data, and a MySQL database for storing the information.

## Overview

The goal of this project is to create a contact form that allows users to submit their name, message, priority, and type of inquiry. This data will then be securely stored in a MySQL database.

## Prerequisites

Before proceeding, ensure you have a Debian-based system (like Ubuntu) where you can install the necessary services.

## Installation of Necessary Services

First, update your package lists and install the required services:

``` bash
sudo apt update
sudo apt install mysql-server
sudo apt install nginx -y
sudo apt install php-fpm
sudo apt install php8.1-mysqli

```

## Nginx Configuration

The following Nginx configuration sets up a web server that listens on both HTTP (port 80) and HTTPS (port 443). It redirects all HTTP traffic to HTTPS for secure communication and configures PHP processing.

**Note:** For this setup, a self-signed SSL certificate is used for demonstration purposes. In a production environment, you should use a trusted SSL certificate.

``` nginx
server {
    listen 80;
    server_name edgar.am;

    # Redirect all requests to https
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name edgar.am;

    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;

    root /var/www/html;
    index index.html process-form.php;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock; # Adjust version if needed
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}

```

## HTML Front-End (`index.html`)

The front-end is a simple HTML contact form. It utilizes the `water.css` framework for basic styling. The form submits data to `process-form.php` using the POST method.

``` html
<!DOCTYPE html>
<html>
    <head>
        <title>Contact</title>
        <meta charset="UTF-8">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.min.css">
    </head>
    <body>
        <h1>Contact</h1>
        <form action="process-form.php" method="post">
            <label for="name">Name</label>
            <input type="text" id="name" name="name">

            <label for="message">Message</label>
            <textarea id="message" name="message"></textarea>

            <label for="priority">Priority</label>
            <select id="priority" name="priority">
                <option value="1">Low</option>
                <option value="2" selected>Medium</option>
                <option value="3">High</option>
            </select>
            <fieldset>
                <legend>Type</legend>      
                <label>
                    <input type="radio" name="type" value="1" checked>
                    Complaint  
                </label>  
                <br>  
                <label>
                    <input type="radio" name="type" value="2">
                    Suggestion  
                </label>  
            </fieldset>  
            <label>
                <input type="checkbox" name="terms">
                I agree to the terms and conditions   
            </label>  
            <br>  
            <button>Submit</button>  
        </form>  
    </body>  
</html>

```

## PHP Back-End (`process-form.php`)

This PHP script handles the form submission, validates the input, and inserts the data into the MySQL database.

  - `$_POST` is a superglobal array containing all POST request data.
  - `filter_input()` safely retrieves and validates form data.
      - `INPUT_POST` specifies we're getting POST data.
      - `FILTER_VALIDATE_INT` ensures the value is a valid integer (returns false if not).
      - `FILTER_VALIDATE_BOOL` converts checkbox values to boolean (true if checked, false if not).
  - `die()` stops script execution and displays an error message. This is used to prevent form submission if terms are not accepted.
  - `localhost` means the database is on the same server.
  - `message_db` is your database name.
  - `root` is the MySQL username.
  - An empty password is used for simplicity; in a production environment, always use a strong password.
  - `mysqli_connect_errno()` returns an error number if connection failed (0 if successful).
  - `mysqli_connect_error()` returns the error message.
  - The SQL `INSERT` statement uses `?` as placeholders for actual values to prevent SQL injection.
  - `mysqli_stmt_init()` initializes a statement object.
  - `mysqli_stmt_prepare()` prepares an SQL statement for execution.
  - `mysqli_stmt_bind_param()` binds variables to a prepared statement as parameters. The "ssii" string indicates the data types: string, string, integer, integer.
  - `mysqli_stmt_execute()` executes a prepared statement.

<!-- end list -->

``` php
<?php

$name = $_POST["name"];
$message = $_POST["message"];
$priority = filter_input(INPUT_POST, "priority", FILTER_VALIDATE_INT);
$type = filter_input(INPUT_POST, "type", FILTER_VALIDATE_INT);
$terms = filter_input(INPUT_POST, "terms", FILTER_VALIDATE_BOOL);

if (!$terms){
    die("Terms must be accepted");
}

$host = "localhost";
$dbname = "message_db";
$username = "root";
$password = "";

$conn = mysqli_connect(hostname: $host,
                       username: $username,
                       password: $password,
                       database: $dbname);

if (mysqli_connect_errno()){
    die("Connection error: ". mysqli_connect_error());
}

$sql = "INSERT INTO message (name, body, priority, type)
        VALUES (?,?,?,?)";

$stmt = mysqli_stmt_init($conn);

if ( ! mysqli_stmt_prepare($stmt, $sql)){
    die(mysqli_error($conn));
}

mysqli_stmt_bind_param($stmt, "ssii",
                       $name,
                       $message,
                       $priority,
                       $type);

mysqli_stmt_execute($stmt);

?>

```

## MySQL Database Structure

A database named `message_db` and a table named `message` are required for this application. The `message` table has the following columns:

  - `id`: `AUTO_INCREMENT` `INT` `PRIMARY KEY`
  - `name`: `VARCHAR(128)`
  - `body`: `TEXT`
  - `priority`: `INT`
  - `type`: `INT`

You can create this table using the following SQL command in your MySQL client:

``` sql
CREATE TABLE message (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(128),
    body TEXT,
    priority INT,
    type INT
);

```

**Important Note:** By default, MySQL is configured to listen only on `localhost` (port 3306), meaning it is not accessible from outside the server where it's running. This is a common and secure default for web applications where the database and web server reside on the same machine. If you need to access the MySQL server from a different host, you would need to modify its configuration (e.g., `bind-address` in `my.cnf`) and adjust firewall rules, which is generally not recommended for security reasons in a typical web application setup.
