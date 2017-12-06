class central_logging::server (
    $header_template      = $central_logging::params::server_header_template,
    $footer_template      = $central_logging::params::server_footer_template,
    $logrotate_template   = $central_logging::params::server_logrotate_template,
    $logstash             = $central_logging::params::server_logstash,
    $semanage_package     = $central_logging::params::semanage_package,
    $logging_sources      = $central_logging::params::server_logging_sources,
    $rotate_logs_period   = $central_logging::params::server_rotate_logs_period,
    $rotate_logs_compress = $central_logging::params::server_rotate_logs_compress,
    $rotate_logs_keep     = $central_logging::params::server_rotate_logs_keep,
    ) inherits central_logging {

    # convert possible 'string booleans' to true boolean
    $real_logstash = str2bool($logstash)

    if str2bool($::selinux) {
      # set correct selinux context on the central_syslog_port
      exec {'set_logstash_relp_port_selinux_context':
          command   => "semanage port -a -t syslogd_port_t -p tcp ${logstash_relp_port}",
          logoutput => on_failure,
          unless    => ["semanage port -l | grep 'syslogd_port_t.* ${logstash_relp_port}[$,]'"],
          require   => Package[$semanage_package]
      }
    }

    # Create the header (module loads) and footer (spooling etc definitions and central log server)
    file { 'client::20-mod-loads-server.conf':
        ensure  => present,
        path    => "${rsyslog_d}/20-mod-loads-server.conf",
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template($header_template),
        notify  => Service['rsyslog'],
    }

    file { 'client::99-centralise-server.conf':
        ensure  => present,
        path    => "${rsyslog_d}/99-centralise-server.conf",
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template($footer_template),
        notify  => Service['rsyslog'],
    }

    file { '/etc/logrotate.d/central-hosts':
        ensure  => 'present',
        content => template($logrotate_template),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

    package { 'logrotate':
        ensure => 'present',
    }
}
