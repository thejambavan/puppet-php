# Configure a yum repo for RedHat-based systems
#
# === Parameters
#
# [*yum_repo*]
#   Class name of the repo under ::yum::repo
#

class php::repo::redhat (
  $yum_repo = 'remi_php71',
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

  yumrepo { 'remi':
    descr      => 'Remi\'s RPM repository for Enterprise Linux $releasever - $basearch',
    mirrorlist => "https://rpms.remirepo.net/${distro}/${releasever}/remi/mirror",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => "https://rpms.remirepo.net/${keyname}",
    priority   => 1,
  }

  if $facts['os']['name'] != 'Fedora' { # PHP 5 has not been supported on Fedora for a long time
    yumrepo { 'remi-php56':
      descr      => 'Remi\'s PHP 5.6 RPM repository for Enterprise Linux $releasever - $basearch',
      mirrorlist => "https://rpms.remirepo.net/${distro}/${releasever}/php56/mirror",
      enabled    => 1,
      gpgcheck   => 1,
      gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi',
      priority   => 1,
    }
  }
}
