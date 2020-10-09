# Laravel Homestead environment in Docker

## Overview

The setup is composed of the following images:

- **workspace** This is the main container of the Homestead-like workspace to run your commands such as `artisan`, `composer` and `npm`. It is build with PHP-CLI, Composer, NPM, Yarn, Laravel installer, Symfony installer.
- **nginx** as the web server.
- **php{72|73|74}** With PHP-FPM, Xdebug, based on images `php-fpm`
- **mysql** version 5.7

To avoid clashes with other projects that might be running on localhost, it's running on its own local network with subnet `10.10.10.0/16`. Each container has a dedicated IP:

- **nginx** `10.10.10.80` (because of port 80) this is the IP that will be mapped to project domains
- **php** `10.10.10.{74|73|72}` (because PHP version)
- **mysql** `10.10.10.57` (because MySQL version 5.7)
- **workspace** `10.10.10.100` (just because)

IPs can be changed in the `.env` file

## Installation

Clone this repo wherever you'd like, then create another folder where you are going to keep all your projects (can be inside or outside this repo, it doesn't matter).

First copy `.env.example` file to `.env`, then edit `WORKSPACE_PHP_VERSION` to the one you want to use as CLI, and `CODE_PATH` for the folder of all your projects.

Copy `docker-compose.original.yaml` to `docker-compose.yaml` run `docker-compose build` to build the images. It's a one time thing, but it should take 5 to 10 minutes, more or less.

## Project setup

Inside `nginx/sites` folder, copy the  `laravel.conf.example` to `example.conf` (or whichever project-related name) then change `${PROJECT_PATH}` to the path of the project relative to your `${CODE_PATH}`, `${SERVER_NAME}` (say, `example.wip`) to the domain you want to use and `${PHP_VERSION}` to the version you want the project to run on (with the dot in-between).

In you local `/etc/hosts` file add that doamain with the IP of the nginx container:
```
10.10.10.80 example.wip
```
If for some reason you can't have a running local network for Docker, or don't want to, you can still use the containers on localhost through the `NGINX_PORT`. Just add your domain to localhost in your hosts file
```
127.0.0.1 example.wip
```
and your project will be available on `example.wip:1080`. You can edit the `NGINX_PORT` in  `.env` file. Of course, you can use `NGINX_PORT=80` if you have nothing running on it already.

In the `.env` file of the project, change some variables for mysql connection for the following ones

```
DB_HOST=mysql
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=root
```

For connecting to that mysql instance throught an external client on your machine, such as phpMyAdmin or MySQL Workbench, you need to set your connection as follow
- host: `10.10.10.57` or `127.0.0.1` if you are using localhost
- port: `3306` or `1057` if you are using localhost (you can edit `MYSQL_PORT` is in `.env` file)
- username: `root`
- password: `root`

Once the build of the images are done, run `docker-compose up -d` to start your containers. You can assert they are up by running `docker-compose ps` to list the currently running containers from your docker-compose file (whereas `docker ps` will list **all** the containers running on your machine)

Once all containers are up, ssh into the workspace by running `docker-compose -u dockstead workspace bash` (pretty long command, we will remedy to that). Inside of the container, you should be in folder `~/code` which is directly mapped to the `${CODE_PATH}` you set up for where your projects are. You can then list your project folders by running `ll` to checkk if you mapped it correctly.

If you `cd` into one of your projects, you can then use the usual `artisan`, `composer`, `npm` and such. You can also check `php -v` for the `WORKSPACE_PHP_VERSION` you put.

## Aliases

Because docker commands are a bit long and inconvenient to memorize, I strongly suggest adding some aliases to make your life easier.

Here are the ones I am currently using:

- `dcu` => `docker-compose up -d` for starting your containers
- `dcdockstead` => `docker-compose exec -udockstead workspace` so you can then just do `dcdockstead bash` to ssh into the workspace container
- `dcd` => `docker-compose down` to stop your containers
- `dcps` => `docker-compose ps` to list the containers from docker-compose currently running

but of course you can tweak them to whatever you like.

### Seting up aliases for Linux

The usual file to add aliases in linux is `~/.bashrc`. Edit the file by adding your aliases at the end as follow

```
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dcps="docker-compose ps"
alias dcdockstead="docker-compose exec -udockstead workspace"
```
Once done, run `source ~/.bashrc`

### Setting up aliases for Windows

Until someone using Windows can help me with it, I can only refer to this artice:
https://winaero.com/blog/how-to-set-aliases-for-the-command-prompt-in-windows/

## Xdebug

In `php` folder, copy then rename `xdebug.ini.example` to `xdebug.ini`. Unless you are on MacOS, you shouldn't have to edit it.

### Xdebug in VsCode

In your project folder, create `.vscode/launch.json` and add the following configuration (don't forget to change `/absolute/path/to/your/project/folder` to your actual absolute path on your machine):
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "log": true,
            "name": "XDebug for dockstead",
            "type": "php",
            "request": "launch",
            "port": 9001,
            "pathMappings": {
                "/var/www/your/project/folder": "/absolute/path/to/your/project/folder",
            },
            "ignore": [
                "**/vendor/**/*.php"
            ]
        }
    ]
}
```
