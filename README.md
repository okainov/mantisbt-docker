
![CI](https://github.com/okainov/mantisbt-docker/workflows/CI/badge.svg?branch=master) ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/okainov/mantisbt) ![Docker Pulls](https://img.shields.io/docker/pulls/okainov/mantisbt)

# MantisBT bug tracker Docker image

Docker image for Mantis Bug Tracker https://www.mantisbt.org/

# Why this image?

There are some other alternative images exist already such as [vimagick/mantisbt](https://hub.docker.com/r/vimagick/mantisbt/), [xlrl/docker-mantisbt](https://github.com/xlrl/docker-mantisbt) and others. Why do we need yet another image?

The reason is to combine all the nice features each of them have and add some missing features. To list some:

- Always latest MantisBT version.
- Comes with the latest PHP version (7.4 as for today)
- Allows to easily configure presence of `admin` service folder
- Comes with built-in integration with Gitlab and Github [source plugins](https://github.com/mantisbt-plugins/source-integration)
- Example `docker-compose.yml` file provided for getting started in one click!
- Easy customization of the config files and custom plugins without destroying data from base image.


# Quick start

- Download `docker-compose.yml` from this repo: `wget https://raw.githubusercontent.com/okainov/mantisbt-docker/master/docker-compose.yaml`
- Check the environment variables (at least you need to set MASTER_SALT env variable, [doc](
https://www.mantisbt.org/docs/master/en-US/Admin_Guide/html-desktop/#admin.config.security))
- `docker-compose up -d`
- Open browser at `localhost:8989/admin/install.php` and follow installation instructions, default out-of-the-box values are good to use.
-- Ignore `Config File Exists but Database does not` warning and proceed installation
- Log in as `administrator`/`root` (default credentials) and confugre whatever you need (typically you want to create your own Admin user and disable built-in "administrator" first)
- Check MantisBT own's checks at `localhost:8989/admin/`. Note: several warnings are expected to be "WARN" due to issues in MantisBT, such as magic quotes warning ([#26964](https://www.mantisbt.org/bugs/view.php?id=26964) and "folder outside of web root" warnings ([#21584](https://mantisbt.org/bugs/view.php?id=21584)))
- When ready to move to production, either remove `MANTIS_ENABLE_ADMIN` env variable or set it to 0 - this will remove "admin" folder from the installation.

For further details refer to [official documentation](https://www.mantisbt.org/docs/master/en-US/Admin_Guide/html-desktop/#admin.install.new)


# Extensions

## Custom config settings

If you need to customize more options in config, create `config_inc_addon.php` file and mount it to `/var/www/html/config/config_inc_addon.php` in container. This fill will be added to default `config_inc.php`. Mounting it will allow you to see the changes instantly without rebuilding/restarting the container.

Some of the typical settings you might want to change:

```
$g_window_title = 'Title of your MantisBT instance';

// Default is useless 5 minutes
$g_reauthentication_expiry = 60 * 60;

// Enable anonymous access

$g_allow_anonymous_login = true;
$g_anonymous_account = 'anonymous';

```

## Email

There are following env variables supported:

- EMAIL_WEBMASTER - maps to `g_webmaster_email`
- EMAIL_FROM - maps to `g_from_email`
- EMAIL_RETURN_PATH - maps to `g_return_path_email`

Those are good enough to start with. Going further, to configure SMTP you might need to create custom config (as described above) with the values like:
```
$g_phpMailer_method = PHPMAILER_METHOD_SMTP;
$g_smtp_host = 'mail.domain.com';
$g_smtp_username = 'mail@domain.com';
$g_smtp_password = 'FILLME';
```

More details are available in [official documentation](https://www.mantisbt.org/docs/master/en-US/Admin_Guide/html-desktop/#admin.config.email)

## Custom plugins

In order to add your own custom plugins into the image, either create your own Dockerfile and copy extra plugins to `/var/www/html/plugins/` or add volume in docker-compose to mount extra plugin directly inside existing image `./custom_plugin/:/var/www/html/plugins/custom_plugin/`