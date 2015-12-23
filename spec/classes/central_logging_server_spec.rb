require 'spec_helper'

def_rsyslog_d = "/etc/rsyslog.d"

describe 'central_logging::server', :type => 'class' do
  let(:facts) do
    {
      :osfamily => 'RedHat'
    }
  end
  context "Should install logrotate package and create config files" do

    it do
      should contain_package('logrotate').with(
        'ensure' => 'present',
        )
    end

    it do
      ['client::20-mod-loads-server.conf', 'client::99-centralise-server.conf', '/etc/logrotate.d/central-hosts'].each do |file|
        should contain_file(file).with(
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          )
      end
      ['client::20-mod-loads-server.conf', 'client::99-centralise-server.conf'].each do |file|
        should contain_file(file).with(
          'notify'  => 'Service[rsyslog]',
          )
      end

      should contain_file('client::99-centralise-server.conf').with(
        'path' => "#{def_rsyslog_d}/99-centralise-server.conf",
        )
    end
  end

  context "checking content with default params" do
    it do
      should contain_file('client::20-mod-loads-server.conf')
        .with_content(/\$ModLoad omrelp.so/)
        .with_content(/\$ModLoad imrelp.so/)
        .with_content(/\$InputRELPServerRun 2514/)
        .with_content(/\$WorkDirectory\s*\/var\/spool\/rsyslog/)
        .with_content(/\$MainMsgQueueFileName main_msg_queue/)
        .with_content(/\$MainMsgQueueType LinkedList/)
        .with_content(/\$MainMsgQueueSaveOnShutdown on/)
        .with_content(/\$MainMsgQueueMaxDiskSpace 1g/)
        .with_content(/\$MainMsgQueueSize 150000/)
    end

    it do
      should contain_file('client::99-centralise-server.conf')
        .with_content(/ActionQueueFileName\s*fwdRule1/)
        .with_content(/\$ActionQueueMaxDiskSpace\s*1g/)
        .with_content(/\$ActionQueueSaveOnShutdown\s*on/)
        .with_content(/\$ActionQueueType\s*LinkedList/)
        .with_content(/\$ActionResumeRetryCount\s*-1/)
        .with_content(/\$template DynaFile/)
    end

    it do
      should contain_file('/etc/logrotate.d/central-hosts')
        .with_content(/daily/)
        .with_content(/rotate 90/)
        .with_content(/compress/)
        .with_content(/missingok/)
        .with_content(/notifempty/)
        .with_content(/sharedscripts/)
        .with_content(/postrotate/)
    end

  end

end
