# == Class: cinder::quota
#
# Setup and configure Cinder quotas.
#
# === Parameters
#
# [*quota_volumes*]
#   (Optional) Number of volumes allowed per project.
#   Defaults to $::os_service_default
#
# [*quota_snapshots*]
#   (Optional) Number of volume snapshots allowed per project.
#   Defaults to $::os_service_default
#
# [*quota_gigabytes*]
#   (Optional) Number of volume gigabytes (snapshots are also included)
#   allowed per project.
#   Defaults to $::os_service_default.
#
# [*quota_backups*]
#   (Optional) Number of volume backups allowed per project.
#   Defaults to $::os_service_default.
#
# [*quota_backup_gigabytes*]
#   (Optional) Number of backup gigabytes allowed per project.
#   Defaults to $::os_service_default.
#
# [*quota_driver*]
#   (Optional) Default driver to use for quota checks.
#   Defaults to $::os_service_default.
#
# [*per_volume_size_limit*]
#   (Optional) Max size allowed per volume, in gigabytes
#   Defaults to $::os_service_default.
#
class cinder::quota (
  $quota_volumes          = $::os_service_default,
  $quota_snapshots        = $::os_service_default,
  $quota_gigabytes        = $::os_service_default,
  $quota_backups          = $::os_service_default,
  $quota_backup_gigabytes = $::os_service_default,
  $quota_driver           = $::os_service_default,
  $per_volume_size_limit  = $::os_service_default,
) {

  include cinder::deps

  cinder_config {
    'DEFAULT/quota_volumes':          value => $quota_volumes;
    'DEFAULT/quota_snapshots':        value => $quota_snapshots;
    'DEFAULT/quota_gigabytes':        value => $quota_gigabytes;
    'DEFAULT/quota_backups':          value => $quota_backups;
    'DEFAULT/quota_backup_gigabytes': value => $quota_backup_gigabytes;
    'DEFAULT/quota_driver':           value => $quota_driver;
    'DEFAULT/per_volume_size_limit':  value => $per_volume_size_limit;
  }
}
