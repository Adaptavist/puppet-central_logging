class central_logging::params {
    # central_logging params
    $rsyslog_d             = '/etc/rsyslog.d'
    $rsyslog_spool_dir     = '/var/spool/rsyslog'
    $logstash_host         = 'localhost'
    $logstash_relp_port    = '5514'
    $central_syslog_server = 'loghost'
    $central_syslog_port   = '2514'
    $rsyslog_yum_repo      = true
    $rsyslog_yum_repo_url  = 'http://rpms.adiscon.com/v7-stable/epel-$releasever/$basearch'

    $semanage_package = $::osfamily ? {
        'RedHat' => 'policycoreutils-python',
        'Debian' => 'policycoreutils',
    }

    # central_logging::server params
    $server_header_template      = "${module_name}/server-header.erb"
    $server_footer_template      = "${module_name}/server-footer.erb"
    $server_logrotate_template   = "${module_name}/logrotate.conf.erb"
    $server_logstash             = true
    $server_logging_sources      = []
    $server_rotate_logs_period   = 'daily'
    $server_rotate_logs_compress = true
    $server_rotate_logs_keep     = '90'

    # central_logging::client params
    $client_header_template      = "${module_name}/client-header.erb"
    $client_footer_template      = "${module_name}/client-footer.erb"
    $client_create_monitor_files = {}
    $client_logging_destinations = []
}
