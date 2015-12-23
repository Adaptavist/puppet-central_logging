# CentralLogging Module

## Overview

The **CentralLogging** module configures **rsyslog** on client puppet machines.

The following is an overview of the module functionality with reference to the puppet types defined by this module and described in later sections of this file. The basic architechture is as follows:

	client (rsyslog) --RELP--> central_server (rsyslog) --RELP--> central_server (logstash)
	
Client machines collect log input from various sources, in particular application log files that are not managed by rsyslog. This is configured using the `monitor_files` type.

The client machines are then configured by the `client` type to send the log file input they are processing to the central logging machine using the RELP[^1] protocol. The `client` type is used to enable this functionality.

Finally, the `server` type configures the central logging machine to send the log data it collects to the central Logstash daemon, again via the RELP protocol.
	
## Puppet Types

A number of reusable puppet types are defined in the `central_logging` module. They are discussed in this section.

### Monitor_Files

The `monitor_files` type is used to declare a file for an rsyslog daemon to monitor on the same machine. It uses the `imfile`[^2] module in rsyslog. It creates a config file under `/etc/rsyslog.d/`. It takes the following parameters.

* `input` the application log file to monitor. This is the value for `$InputFileName` in the rsyslogd configuraiton file.
	* type: `string, file path`
* `rtag` the tag to apply for this input. This is used as the value for `$InputFileTag` in the rsyslogd configuration file. A colon `:` is always appended to this value in the configuration file.
	* type: `string, identifier`
* `state` the state file to create under the rsyslog spool directory. This tracks what input has and has not been processed from the input file by rsyslog. The given value is used for `$InputFileStateFile` parameter in the rsyslogd configuration file.
	* type: `string, file name`
* `priority` priority number for the file generated under `/etc/rsyslog.d`.
	* type: `integer, non-negative priorty value`
	* default value: 80
* `syslog_facility` the optional syslog facility that messages in the monitored file should be assigned
	* type: `string, syslog facility`
	* default value: false (meaning no facility will be set in the config file)
	* possible values:
	  * `kern`, `user` `mail`, `daemon`, `auth`, `syslog`, `lpr`, `news`, `uucp`, `authpriv`, `ftp`, `cron`
      * `local0`, `local1`, `local`, `local3`, `local4`, `local5`, `local6`, `local7`
* `file_read_mode` determines the multiline detection method to use
  * type: `integer, non-negative value`
  * default value: 2
  * possible values:
    * `0`- line based (Each line is a new message)
    * `1` - paragraph (There is a blank line between log messages)
    * `2` - indented (New log messages start at the beginning of a line. If a line starts with a space it is part of the log message before it)

Files can be created via create_monitor_files hash passed to client.

### Client

The `client` type has no parameters. If a node must send log data to the central server all that is required is to `include` the class in that nodes puppet configuration.

### Server

The `server` type has no parameters.  This type enables the aggregation log data from different 'client' hosts for subsequent transmission to a logstash server. It is sufficent to `include` this class in a node configuraiton to activate it. 

## Configuration

This module is configured via the following Hiera keys, prefixed with
"central_logging::"

* `rsyslog_spool_dir`: The spool directory for the local rsyslog daemon.
	* type: `string, path`
	* default value: `/var/spppl/rsyslog`
* `logstash_host`: The hostname of the logstash server.
 	* type: `string, hostname`
	* default value: `localhost`
* `logstash_relp_port`: The RELP[^1] port of the logstash server.
	* type: `integer, portnumber`
	* default value: `5514`
* `central_syslog_server`: The hostname of central rsyslogd server.
	* type: `string, hostname`
	* default value: `loghost`
* `central_syslog_port`: The port number of the central rsyslogd server.
	* type: `integer, portnumber`
	* default value: `2514`


## Dependencies

This module requires the following modules to work:

* LogServer

Although there are no explicit dependencies on puppet types from other modules, it still needs the `logserver` module to work. The reason for stating specifically that the dependency is implicit is that if somehow the `logserver` module where not present errors might only be shown by observing the behaviour of rsyslog and not from the output of puppet itself.

## References

[^1]: http://www.rsyslog.com/doc/omrelp.html
[^2]: http://www.rsyslog.com/doc/imfile.html
