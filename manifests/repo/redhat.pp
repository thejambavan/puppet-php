# Configure a yum repo for RedHat-based systems
#
# === Parameters
#
# [*yum_repo*]
#   Class name of the repo under ::yum::repo
#

class php::repo::redhat (
  $yum_repo = $::php::globals::php_version,
) {

  case $facts['os']['name'] {
    /(?i:Amazon)/: {
      $releasever = '6'
      $distro = 'enterprise'
      $keyname = 'RPM-GPG-KEY-remi'
    }
    'Fedora': {
      $releasever = '$releasever'
      $distro = 'fedora'
      $keyname = $facts['os']['release']['major'] ? {
        '32'      => 'RPM-GPG-KEY-remi2020',
        /(30|31)/ => 'RPM-GPG-KEY-remi2019',
        /(28|29)/ => 'RPM-GPG-KEY-remi2018',
        /(26|27)/ => 'RPM-GPG-KEY-remi2017',
        default   => 'RPM-GPG-KEY-remi'
      }
    }
    default: {
      $releasever = '$releasever'
      $distro = 'enterprise'
      $keyname = $facts['os']['release']['major'] ? {
        '8'     => 'RPM-GPG-KEY-remi2018',
        default => 'RPM-GPG-KEY-remi'
      }
    }
  }

  yumrepo { "remi-${yum_repo}":
    descr      => "Remi's ${yum_repo} RPM repository for Enterprise Linux $releasever - $basearch",
    mirrorlist => "http://cdn.remirepo.net/${distro}/${releasever}/${yum_repo}/mirror",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => "https://rpms.remirepo.net/${keyname}",
    priority   => 1,
  }

  yumrepo { 'remi-safe':
    descr      => 'Safe Remi\'s RPM repository for Enterprise Linux $releasever - $basearch',
    mirrorlist => "http://cdn.remirepo.net/${distro}/${releasever}/safe/mirror",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => "https://rpms.remirepo.net/${keyname}",
    priority   => 1,
  }
}
