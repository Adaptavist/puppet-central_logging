define central_logging::client::monitor_files (
    $input,
    $rtag,
    $state,
    $priority        = 80,
    $template        = "${module_name}/file.monitor.erb",
    $syslog_facility = false,
    $file_read_mode  = 2
    ) {
    include central_logging::client
    validate_string( $input, $rtag, $state )
    validate_re($file_read_mode, ['^0$', '^1$','^2$'])

    # work out if we are using a specific syslog facility
    if ($syslog_facility != 'false' and $syslog_facility != false) {
        validate_re($syslog_facility,
            ['^kern$', '^user$', '^mail$', '^daemon$', '^auth$',
            '^syslog$','^lpr$', '^news$', '^uucp$', '^authpriv$',
            '^ftp$', '^cron$', '^local0$', '^local1$', '^local2$',
            '^local3$', '^local4$', '^local5$', '^local6$', '^local7$',])
        $real_syslog_facility = $syslog_facility
    } else {
        $real_syslog_facility = undef
    }

    file { "${priority}-${name}.conf":
        ensure  => present,
        path    => "${central_logging::rsyslog_d}/${priority}-${name}.conf",
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template($template),
        notify  => Service['rsyslog'],
    }
}
