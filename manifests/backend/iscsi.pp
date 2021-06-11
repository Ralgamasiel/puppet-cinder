#
# Define: cinder::backend::iscsi
#
# === Parameters:
#
# [*target_ip_address*]
#   (optional) The IP address that the iSCSI daemon is listening on.
#   Defaults to undef.
#
# [*volume_backend_name*]
#   (optional) Allows for the volume_backend_name to be separate of $name.
#   Defaults to: $name
#
# [*backend_availability_zone*]
#   (Optional) Availability zone for this volume backend.
#   If not set, the storage_availability_zone option value
#   is used as the default for all backends.
#   Defaults to $::os_service_default.
#
# [*volume_driver*]
#   (Optional) Driver to use for volume creation
#   Defaults to 'cinder.volume.drivers.lvm.LVMVolumeDriver'.
#
# [*volume_group*]
#   (Optional) Name for the VG that will contain exported volumes
#   Defaults to $::os_service_default
#
# [*volumes_dir*]
#   (Optional) Volume configuration file storage directory
#   Defaults to '/var/lib/cinder/volumes'.
#
# [*target_helper*]
#   (Optional) iSCSI target user-land tool to use.
#   Defaults to '$::cinder::params::target_helper'.
#
# [*target_protocol*]
#   (Optional) Protocol to use as iSCSI driver
#   Defaults to $::os_service_default.
#
# [*manage_volume_type*]
#   (Optional) Whether or not manage Cinder Volume type.
#   If set to true, a Cinder Volume type will be created
#   with volume_backend_name=$volume_backend_name key/value.
#   Defaults to false.
#
# [*extra_options*]
#   (optional) Hash of extra options to pass to the backend stanza
#   Defaults to: {}
#   Example :
#     { 'iscsi_backend/param1' => { 'value' => value1 } }
#
define cinder::backend::iscsi (
  $target_ip_address         = undef,
  $volume_backend_name       = $name,
  $backend_availability_zone = $::os_service_default,
  $volume_driver             = 'cinder.volume.drivers.lvm.LVMVolumeDriver',
  $volume_group              = $::os_service_default,
  $volumes_dir               = '/var/lib/cinder/volumes',
  $target_helper             = $::cinder::params::target_helper,
  $target_protocol           = $::os_service_default,
  $manage_volume_type        = false,
  $extra_options             = {},
) {

  include cinder::deps
  include cinder::params

  # NOTE(mnaser): Cinder requires /usr/sbin/thin_check to create volumes which
  #               does not get installed with Cinder (see LP#1615134).
  if $::osfamily == 'Debian' {
    if ! defined(Package['thin-provisioning-tools']) {
      package { 'thin-provisioning-tools':
        ensure => present,
        tag    => 'cinder-support-package',
      }
    }
  }

  cinder_config {
    "${name}/volume_backend_name":        value => $volume_backend_name;
    "${name}/backend_availability_zone":  value => $backend_availability_zone;
    "${name}/volume_driver":              value => $volume_driver;
    "${name}/target_ip_address":          value => $target_ip_address;
    "${name}/target_helper":              value => $target_helper;
    "${name}/volume_group":               value => $volume_group;
    "${name}/volumes_dir":                value => $volumes_dir;
    "${name}/target_protocol":            value => $target_protocol;
  }

  if $manage_volume_type {
    cinder_type { $volume_backend_name:
      ensure     => present,
      properties => ["volume_backend_name=${volume_backend_name}"],
    }
  }

  create_resources('cinder_config', $extra_options)

  case $target_helper {
    'tgtadm': {
      if ! defined(Package['tgt']) {
        package { 'tgt':
          ensure => present,
          name   => $::cinder::params::tgt_package_name,
          tag    => 'cinder-support-package',
        }
      }

      if($::osfamily == 'RedHat') {
        file_line { 'cinder include':
          path    => '/etc/tgt/targets.conf',
          line    => "include ${volumes_dir}/*",
          match   => '#?include /',
          require => Anchor['cinder::install::end'],
          notify  => Anchor['cinder::service::begin'],
        }
      }

      if ! defined(Service['tgtd']) {
        service { 'tgtd':
          ensure => running,
          name   => $::cinder::params::tgt_service_name,
          enable => true,
          tag    => 'cinder-support-service',
        }
      }
    }

    'lioadm': {
      if ! defined(Service['target']) {
        service { 'target':
          ensure => running,
          enable => true,
          tag    => 'cinder-support-service',
        }
      }

      if ! defined(Package['targetcli']) {
        package { 'targetcli':
          ensure => present,
          name   => $::cinder::params::lio_package_name,
          tag    => 'cinder-support-package',
        }
      }
    }

    default: {
      fail("Unsupported target helper: ${target_helper}.")
    }
  }

}
