<?php

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = getenv('MOODLE_DB_TYPE') ?: 'pgsql';
$CFG->dblibrary = 'native';
$CFG->dbhost    = getenv('MOODLE_DB_HOST') ?: 'db';
$CFG->dbname    = getenv('MOODLE_DB_NAME') ?: 'moodle';
$CFG->dbuser    = getenv('MOODLE_DB_USER') ?: 'moodle';
$CFG->dbpass    = getenv('MOODLE_DB_PASS') ?: 'm@0dl3ing';
$CFG->prefix    = 'm_';
$CFG->dboptions = [
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => getenv('MOODLE_DB_PORT') ?: 5432,
];

$CFG->wwwroot   = getenv('MOODLE_WWWROOT') ?: 'http://localhost:8000';
$CFG->dataroot  = '/var/www/moodledata';
$CFG->admin     = 'admin';
$CFG->directorypermissions = 02777;

if (getenv('MOODLE_SSLPROXY') === 'true') {
    $CFG->sslproxy = true;
}

$CFG->debug = (E_ALL);
$CFG->debugdisplay = 1;
$CFG->passwordpolicy = 0;
$CFG->pathtophp = '/usr/local/bin/php';

require_once(__DIR__ . '/lib/setup.php');
