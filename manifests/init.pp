# Class: mockbuild
#
# This module manages the resources required to build packages on Enterprise
# Linux Systems.
#
# Jeff McCune <jeff@puppetlabs.com>
# 2011-03-17
#
# It manages the rpm-build, make, gcc, and redhat-rpm-config packages
# Configures the mockbuild user account and group.
# Configures the ~mockbuild/.rpmmacros file
#
# Models the configuration described at:
#
#  http://wiki.centos.org/HowTos/SetupRpmBuildEnvironment
#
# Parameters:
#
#   version => The version of the packages to install.  This should be
#              "present" or "latest".  Do not pass in a specific version.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#   class { 'mockbuild': version => latest }
#
class mockbuild(
  $version     = 'UNSPECIFIED',
  $autoupgrade = true,
  $uid         = '131',
  $gid         = '131'
) {

  # Validate autoupgrade parameter.  This will determine package latest or not.
  if ! $autoupgrade in [ true, false ] {
    fail('autoupgrade must be true or false')
  }
  # Set a local variable to be consistent.
  # This may not be necessary or desired.
  $autoupgrade_real = $autoupgrade

  if $version == 'UNSPECIFIED' {
    $version_real = $autoupgrade ? { true => latest, false => present }
  } else {
    $version_real = $version
  }

  if $uid =~ /[0-9]+/ {
    $uid_real = $uid
  } else {
    fail("uid must be a number matching /[0-9]+/ got ${uid}")
  }

  if $gid =~ /[0-9]+/ {
    $gid_real = $gid
  } else {
    fail("gid must be a number matching /[0-9]+/ got ${gid}")
  }

  $home = '/var/lib/mockbuild'

  File {
    owner => $uid_real,
    group => $gid_real,
    mode  => '0644',
  }

  group { 'mockbuild':
    ensure => present,
    gid    => $gid_real,
    before => File[$home],
  }
  ->
  user { 'mockbuild':
    ensure   => present,
    uid      => $uid_real,
    gid      => $gid_real,
    comment  => 'Mock Build',
    shell    => '/bin/bash',
    home     => $home,
    password => '!!',
    require  => Group['mockbuild'],
  }
  ->
  package { 'rpm-build':
    ensure => $version_real,
  }
  ->
  package { 'redhat-rpm-config':
    ensure => $version_real,
  }
  ->
  package { 'make':
    ensure => $version_real,
  }
  ->
  package { 'gcc':
    ensure => $version_real,
  }

  file { $home:
    ensure => directory,
  }
  file { "${home}/.ssh":
    ensure => directory,
    mode   => '0700',
  }
  file { "${home}/.ssh/authorized_keys":
    ensure => file,
  }
  file { "${home}/.rpmmacros":
    ensure  => file,
    content => "%_topdir ${home}/rpmbuild\n",
  }
  ->
  file { "${home}/rpmbuild":
    ensure => directory,
  }
  file { [ "${home}/rpmbuild/BUILD",
           "${home}/rpmbuild/RPMS",
           "${home}/rpmbuild/SOURCES",
           "${home}/rpmbuild/SPECS",
           "${home}/rpmbuild/SRPMS", ]:
    ensure => directory,
  }

}
