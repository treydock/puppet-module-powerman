require 'spec_helper'

describe 'powerman' do
  on_supported_os({
    :supported_os => [
      {
        "operatingsystem" => "RedHat",
        "operatingsystemrelease" => ["6", "7"],
      }
    ]
  }).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('powerman') }
      it { is_expected.to contain_class('powerman::params') }

      it do
        is_expected.to contain_package('powerman').only_with({
          :ensure => 'present',
          :name   => 'powerman',
        })
      end

      it do
        is_expected.to contain_concat('/etc/powerman/powerman.conf').with({
          :ensure  => 'present',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :require => 'Package[powerman]'
        })
      end

      it do
        is_expected.to contain_service('powerman').only_with({
          :ensure      => 'running',
          :enable      => 'true',
          :name        => 'powerman',
          :hasstatus   => 'true',
          :hasrestart  => 'true',
          :subscribe   => 'Concat[/etc/powerman/powerman.conf]',
        })
      end

      context 'when server => false' do
        let(:params) {{ :server => false }}

        it { is_expected.to contain_package('powerman') }
        it { is_expected.not_to contain_concat('/etc/powerman/powerman.conf') }
        it do
          is_expected.to contain_service('powerman').only_with({
            :ensure  => 'stopped',
            :enable  => 'false',
            :name    => 'powerman',
            :require => 'Package[powerman]',
          })
        end
      end

    end # end context
  end # end on_supported_os loop
end # end describe
