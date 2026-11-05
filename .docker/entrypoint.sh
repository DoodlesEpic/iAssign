#!/usr/bin/env bash
set -euo pipefail

MOODLE_DIR="/var/www/html"
DB_HOST="${MOODLE_DB_HOST:-db}"
DB_PORT="${MOODLE_DB_PORT:-5432}"
DB_NAME="${MOODLE_DB_NAME:-moodle}"
DB_USER="${MOODLE_DB_USER:-moodle}"
DB_PASS="${MOODLE_DB_PASS:-m@0dl3ing}"
WWWROOT="${MOODLE_WWWROOT:-http://localhost:8000}"
ADMIN_USER="${MOODLE_ADMIN_USER:-admin}"
ADMIN_PASS="${MOODLE_ADMIN_PASS:-Admin123!}"
ADMIN_EMAIL="${MOODLE_ADMIN_EMAIL:-admin@example.com}"

mkdir -p /var/www/moodledata
chown -R www-data:www-data /var/www/moodledata

echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."
until php -r "\$fp = @fsockopen('${DB_HOST}', ${DB_PORT}, \$errno, \$errstr, 2); if (!\$fp) exit(1); fclose(\$fp);"; do
  sleep 2
done

if ! php -r "define('CLI_SCRIPT', true); require('${MOODLE_DIR}/config.php'); exit(\$DB->get_manager()->table_exists('config') ? 0 : 1);" >/dev/null 2>&1; then
  echo "Installing Moodle 5.3 + mod_iassign database..."
  php "${MOODLE_DIR}/admin/cli/install_database.php" \
    --agree-license \
    --fullname="MoodleDev iAssign" \
    --shortname="iAssignDev" \
    --summary="iAssign Development Environment" \
    --adminuser="${ADMIN_USER}" \
    --adminpass="${ADMIN_PASS}" \
    --adminemail="${ADMIN_EMAIL}"

  echo "Creating demo course IASSIGN101..."
  php -r "
    define('CLI_SCRIPT', true);
    require('${MOODLE_DIR}/config.php');
    require_once(\$CFG->dirroot . '/course/lib.php');
    \core\session\manager::set_user(get_admin());
    if (!\$DB->record_exists('course', ['shortname' => 'IASSIGN101'])) {
      create_course((object)[
        'category' => 1,
        'shortname' => 'IASSIGN101',
        'fullname' => 'iAssign Test Course',
        'summary' => 'mod_iassign test environment on Moodle 5.3 + PHP 8.4',
        'format' => 'topics',
        'visible' => 1,
      ]);
    }
  "
else
  echo "Checking pending Moodle / mod_iassign upgrades..."
  php "${MOODLE_DIR}/admin/cli/upgrade.php" --non-interactive
fi

echo "Moodle ready at ${WWWROOT} (user: ${ADMIN_USER} / password: ${ADMIN_PASS})"
exec apache2-foreground "$@"

