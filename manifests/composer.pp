# Install composer package manager
#
# === Parameters
#
# [*source*]
#   Holds URL to the Composer source file
#
# [*path*]
#   Holds path to the Composer executable
#
# [*channel*]
#   Holds the Update channel (stable|preview|snapshot|1|2)
#
# [*proxy_type*]
#    proxy server type (none|http|https|ftp)
#
# [*proxy_server*]
#   specify a proxy server, with port number if needed. ie: https://example.com:8080.
#
# [*auto_update*]
#   Defines if composer should be auto updated
#
# [*max_age*]
#   Defines the time in days after which an auto-update gets executed
#
# [*root_group*]
#   UNIX group of the root user
#
#Stdlib::Absolutepath $path           = $php::params::composer_path,
class php::composer (
  String $source                       = $php::params::composer_source,
  Stdlib::Absolutepath $path           = $php::params::composer_path,
  $proxy_type                          = undef,
  $proxy_server                        = undef,
  Php::ComposerChannel $channel        = 'stable',
  Boolean $auto_update                 = true,
  Boolean $bin_links                   = true,
  Integer $max_age                     = $php::params::composer_max_age,
  Variant[Integer, String] $root_group = $php::params::root_group,
) inherits php::params {
  assert_private()

  # turn "7.4" into "74" so that we can do symlinks in /usr/bin to 
  # keep composer happy
  $php_munged_version = regsubst($::php::globals::php_version, '\.', '', 'G')


  archive { $path:
    #target      => $path,
    url          => $source,
    proxy_server => $proxy_server,
    extract      => false,
    before       => File[$path],
    creates      => $path,
  }
  file { $path:
    mode    => '0555',
    owner   => root,
    group   => $root_group,
  }

  if $auto_update {
    class { 'php::composer::auto_update':
      max_age      => $max_age,
      source       => $source,
      path         => $path,
      channel      => $channel,
      proxy_type   => $proxy_type,
      proxy_server => $proxy_server,
    }
  }
  if $bin_links {
    file { '/usr/bin/pear':
      ensure => 'link',
      target => "/usr/bin/php${php_munged_version}-pear",
    }

    #file { "/usr/bin/pecl":
    #  ensure => 'link',
    #  target => "/usr/bin/php${php_munged_version}-pecl",
    #}

    file { "/usr/bin/php":
      ensure => 'link',
      target => "/usr/bin/php${php_munged_version}",
    }
  }
}
