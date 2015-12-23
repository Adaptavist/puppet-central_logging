include stdlib

class central_logging (
    $rsyslog_d             = $central_logging::params::rsyslog_d,
    $rsyslog_spool_dir     = $central_logging::params::rsyslog_spool_dir,
    $logstash_host         = $central_logging::params::logstash_host,
    $logstash_relp_port    = $central_logging::params::logstash_relp_port,
    $central_syslog_server = $central_logging::params::central_syslog_server,
    $central_syslog_port   = $central_logging::params::central_syslog_port,
    $rsyslog_yum_repo      = $central_logging::params::rsyslog_yum_repo,
    $rsyslog_yum_repo_url  = $central_logging::params::rsyslog_yum_repo_url,
    $semanage_package      = $central_logging::params::semanage_package,
) inherits central_logging::params {

  file { $rsyslog_spool_dir:
    ensure => directory,
    notify => Service['rsyslog'],
  }

  if str2bool($::selinux) {
      # make sure the package containing semanage is installed
      ensure_packages([$semanage_package])
      # set correct selinux context on the rsyslog spool directory
      exec {'set_rsyslogd_spool_selinux_context':
          command   => "semanage fcontext -a -t syslogd_var_lib_t \"${rsyslog_spool_dir}(/.*)?\" && restorecon -R -v ${rsyslog_spool_dir}",
          logoutput => on_failure,
          require   => [Package[$semanage_package],File[$rsyslog_spool_dir]]
      }
      # set correct selinux context on the central_syslog_port
      exec {'set_central_syslog_port_selinux_context':
          command   => "semanage port -a -t syslogd_port_t -p tcp ${central_syslog_port}",
          logoutput => on_failure,
          require   => [Package[$semanage_package],File[$rsyslog_spool_dir]],
          unless    => ["semanage port -l | grep 'syslogd_port_t.* ${central_syslog_port}[$,]'"],
      }
  }

  if $rsyslog_yum_repo {
      yum::managed_yumrepo { 'rsyslog_v7':
          descr    => 'Adiscon CentOS-$releasever - local packages for $basearch',
          baseurl  => $rsyslog_yum_repo_url,
          enabled  => 1,
          gpgcheck => 0,
          gpgkey   => 'http://rpms.adiscon.com/RPM-GPG-KEY-Adiscon',
          priority => 1,
          before   => Package['rsyslog']
    }
  }

  package { ['rsyslog', 'rsyslog-relp']:
      ensure => latest,
      notify => Service['rsyslog'],
  }
  if (!defined(Service['rsyslog'])) {
      service { 'rsyslog':
          ensure => 'running',
          enable => true,
      }
  }
}
