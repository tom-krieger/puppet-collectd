# Class: collectd::plugin::iscdhcp
#
# @see https://pypi.python.org/pypi/collectd-iscdhcp
#
#  Configures iscdhcp metrics collection. Optionally installs the required plugin packages
#
# @param ensure Passed to package and collectd::plugin resources (both)
# @param manage_package Toggles installation of plugin
# @param package_name Name of plugin package to install
# @param package_provider Passed to package resource
# @param provider_proxy Proxy for provider
class collectd::plugin::iscdhcp (
  Enum['present', 'absent'] $ensure     = 'present',
  Optional[Boolean] $manage_package     = undef,
  String[1] $package_name               = 'collectd-iscdhcp',
  Optional[String[1]] $package_provider = undef,
  Optional[String[1]] $provider_proxy   = undef,
) {
  include collectd

  $_manage_package = pick($manage_package, $collectd::manage_package)

  if ($facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '8') or ($facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['major'] == '20.04') {
    $_python_pip_package = 'python3-pip'
    if $package_provider =~ Undef {
      $_package_provider = 'pip3'
    }
    else {
      $_package_provider = $package_provider
    }
  } else {
    $_python_pip_package = 'python-pip'
    if $package_provider =~ Undef {
      $_package_provider = 'pip'
    }
    else {
      $_package_provider = $package_provider
    }
  }

  if ($_manage_package) {
    if (!defined(Package[$_python_pip_package])) {
      package { $_python_pip_package: ensure => 'present', }

      Package[$package_name] {
        require => Package[$_python_pip_package],
      }

      if $facts['os']['family'] == 'RedHat' {
        # Epel is installed in install.pp if manage_repo is true
        # python-pip doesn't exist in base for RedHat. Need epel installed first
        if (defined(Class['epel'])) {
          Package[$_python_pip_package] {
            require => Class['epel'],
          }
        }
      }
    }
  }

  if ($_manage_package) and ($provider_proxy) {
    $install_options = [{ '--proxy' => $provider_proxy }]
  } else {
    $install_options = undef
  }

  package { $package_name:
    ensure          => $ensure,
    provider        => $_package_provider,
    install_options => $install_options,
  }

  collectd::plugin::python::module { 'collectd_iscdhcp.collectd_plugin':
    ensure => $ensure,
  }
}
