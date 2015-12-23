class central_logging::client (
    $header_template      = $central_logging::params::client_header_template,
    $footer_template      = $central_logging::params::client_footer_template,
    $create_monitor_files = $central_logging::params::client_create_monitor_files,
    $logging_destinations = $central_logging::params::client_logging_destinations,
    ) inherits central_logging {

    validate_hash($create_monitor_files)

    create_resources('central_logging::client::monitor_files', $create_monitor_files)

    # Create the header (module loads) and footer (spooling etc definitions and central log server)
    file { 'client::20-mod-loads-client.conf':
        ensure  => present,
        path    => "${rsyslog_d}/20-mod-loads-client.conf",
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template($header_template),
        notify  => Service['rsyslog'],
    }

    file { 'client::99-centralise-client.conf':
        ensure  => present,
        path    => "${rsyslog_d}/99-centralise-client.conf",
        owner   => root,
        group   => root,
        mode    => '0644',
        content => template($footer_template),
        notify  => Service['rsyslog'],
    }
}
