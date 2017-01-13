require 'spec_helper'

def_rsyslog_d             = "/etc/rsyslog.d"
def_rsyslog_spool_dir     = "/var/spool/rsyslog"
def_logstash_host         = 'localhost'
def_logstash_relp_port    = '5514'
def_central_syslog_server = 'loghost'
def_central_syslog_port   = '2514'
def_rsyslog_yum_repo      = true
def_rsyslog_yum_repo_url  = 'http://rpms.adiscon.com/v7-stable/epel-$releasever/$basearch'


def check_with_parameters(rsyslog_spool_dir, rsyslog_yum_repo_url, rsyslog_yum_repo)
  it do
      should contain_file(rsyslog_spool_dir).with(
        'ensure' => 'directory',
        'notify' => 'Service[rsyslog]',
        )
    end

    it do
      ['rsyslog', 'rsyslog-relp'].each do |package|
        should contain_package(package).with_ensure('latest').with(
          'notify' => 'Service[rsyslog]',
        )
      end
    end

    it do
      should contain_service('rsyslog').with(
        'ensure' => 'running',
        'enable' => true,
        )
    end

    if rsyslog_yum_repo
      it do
        should contain_yum__managed_yumrepo('rsyslog_v7').with(
          'descr'      => 'Adiscon CentOS-$releasever - local packages for $basearch',
          'baseurl'    => rsyslog_yum_repo_url,
          'enabled'    => 1,
          'gpgcheck'   => 0,
          'gpgkey'     => 'http://rpms.adiscon.com/RPM-GPG-KEY-Adiscon',
          'priority'   => 1,
          'before'     => 'Package[rsyslog]'
          )
      end
    else
      it do
        should_not contain_yum__managed_yumrepo('rsyslog_v7')
      end
    end
end

describe 'central_logging', :type => 'class' do
  let(:facts) do
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7'
    }
  end

  context "Should install package, config file, yumrepo, and run rsyslog service with default params" do
    check_with_parameters(def_rsyslog_spool_dir, def_rsyslog_yum_repo_url, def_rsyslog_yum_repo)
  end

  context "Should install package, config file, not yumrepo, and run rsyslog service with default params" do
    let(:params) { {:rsyslog_yum_repo => false} }
    check_with_parameters(def_rsyslog_spool_dir, def_rsyslog_yum_repo_url, false)
  end

  context "Should install package, config file, not yumrepo, and run rsyslog service with passed params" do
    rsyslog_spool_dir = "/var/spool/rsyslog"
    rsyslog_yum_repo_url  = 'http://rpms.adiscon.com/v77-stable/epel-$releasever/$basearch'

    let(:params) { {
        :rsyslog_yum_repo => true,
        :rsyslog_spool_dir => rsyslog_spool_dir,
        :rsyslog_yum_repo_url => rsyslog_yum_repo_url,
      } }
    check_with_parameters(rsyslog_spool_dir, rsyslog_yum_repo_url, true)
  end

end
