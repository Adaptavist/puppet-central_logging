require 'spec_helper'

def_rsyslog_d = "/etc/rsyslog.d"
custom_destination = ['*.* :omrelp:log-server1.example.com:2514;LongTagForwardFormat','*.* :omrelp:log-server2.example.com:2514;LongTagForwardFormat']

describe 'central_logging::client', :type => 'class' do
  let(:facts) do
    {
      :osfamily => 'RedHat'
    }
  end
  context "Should create config files" do

    it do
      ['client::20-mod-loads-client.conf', 'client::99-centralise-client.conf'].each do |file|
        should contain_file(file).with(
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'notify'  => 'Service[rsyslog]',
          )
      end

      should contain_file('client::99-centralise-client.conf').with(
        'path' => "#{def_rsyslog_d}/99-centralise-client.conf",
        )
      should contain_file('client::20-mod-loads-client.conf').with(
        'path' => "#{def_rsyslog_d}/20-mod-loads-client.conf",
        )
    end
  end

  context "checking content with default params" do
    it do
      should contain_file('client::20-mod-loads-client.conf')
        .with_content(/\$ModLoad omrelp.so/)
        .with_content(/\$ModLoad imfile.so/)
        .with_content(/\$MainMsgQueueFileName main_msg_queue/)
        .with_content(/\$MainMsgQueueType LinkedList/)
        .with_content(/\$MainMsgQueueSaveOnShutdown on/)
        .with_content(/\$MainMsgQueueMaxDiskSpace 1g/)
        .with_content(/\$MainMsgQueueSize 15000/)
    end

    it do
      should contain_file('client::99-centralise-client.conf')
        .with_content(/ActionQueueFileName\s*fwdRule1/)
        .with_content(/\$ActionQueueMaxDiskSpace\s*1g/)
        .with_content(/\$ActionQueueSaveOnShutdown\s*on/)
        .with_content(/\$ActionQueueType\s*LinkedList/)
        .with_content(/\$ActionResumeRetryCount\s*-1/)
        .with_content(/\$template LongTagForwardFormat/)
        .with_content(/:omrelp:loghost:2514;LongTagForwardFormat/)
    end

  end

  context "checking content with multiple rsyslog  destinations" do
    let(:params) { {:logging_destinations => custom_destination} }

    it do
      should contain_file('client::20-mod-loads-client.conf')
        .with_content(/\$ModLoad omrelp.so/)
        .with_content(/\$ModLoad imfile.so/)
        .with_content(/\$MainMsgQueueFileName main_msg_queue/)
        .with_content(/\$MainMsgQueueType LinkedList/)
        .with_content(/\$MainMsgQueueSaveOnShutdown on/)
        .with_content(/\$MainMsgQueueMaxDiskSpace 1g/)
        .with_content(/\$MainMsgQueueSize 15000/)
    end

    it do
      should contain_file('client::99-centralise-client.conf')
        .with_content(/ActionQueueFileName\s*fwdRule1/)
        .with_content(/\$ActionQueueMaxDiskSpace\s*1g/)
        .with_content(/\$ActionQueueSaveOnShutdown\s*on/)
        .with_content(/\$ActionQueueType\s*LinkedList/)
        .with_content(/\$ActionResumeRetryCount\s*-1/)
        .with_content(/\$template LongTagForwardFormat/)
        .with_content(/:omrelp:log-server1.example.com:2514;LongTagForwardFormat/)
        .with_content(/:omrelp:log-server2.example.com:2514;LongTagForwardFormat/)
    end

  end

end
