# https://collectd.org/wiki/index.php/Plugin:MD
class collectd::plugin::md (
  Array $mds              = [],
  $ensure                 = 'present',
  Boolean $ignoreselected = false,
  $interval               = undef,
) {

  include collectd

  collectd::plugin { 'md':
    ensure   => $ensure,
    content  => template('collectd/plugin/md.conf.erb'),
    interval => $interval,
  }
}
