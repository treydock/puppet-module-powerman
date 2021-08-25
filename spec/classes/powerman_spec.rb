require 'spec_helper'

describe 'powerman' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:user) do
        case facts[:os]['family']
        when 'Debian'
          'powerman'
        when 'RedHat'
          'daemon'
        end
      end

      let(:group) do
        case facts[:os]['family']
        when 'Debian'
          'root'
        when 'RedHat'
          'daemon'
        end
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('powerman') }

      it do
        is_expected.to contain_package('powerman').only_with(
          ensure: 'present',
          name: 'powerman',
        )
      end

      it do
        is_expected.to contain_concat('/etc/powerman/powerman.conf').with(
          ensure: 'present',
          owner: user,
          group: 'root',
          mode: '0640',
          require: 'Package[powerman]',
          notify: 'Service[powerman]',
        )
      end

      it do
        is_expected.to contain_concat__fragment('powerman.conf.header').with(
          target: '/etc/powerman/powerman.conf',
          order: '01',
        )
      end

      it do
        is_expected.to contain_file('/var/run/powerman').with(
          ensure: 'directory',
          owner: user,
          group: group,
          mode: '0755',
          require: 'Package[powerman]',
          before: 'Service[powerman]',
        )
      end

      it do
        is_expected.to contain_service('powerman').only_with(
          ensure: 'running',
          enable: 'true',
          name: 'powerman',
          hasstatus: 'true',
          hasrestart: 'true',
          require: 'Package[powerman]',
        )
      end

      it { is_expected.to contain_file('/etc/profile.d/powerman.sh').with_ensure('absent') }
      it { is_expected.to contain_file('/etc/profile.d/powerman.csh').with_ensure('absent') }

      context 'when server => false' do
        let(:params) { { server: false } }

        it { is_expected.to contain_package('powerman') }
        it { is_expected.not_to contain_concat('/etc/powerman/powerman.conf') }
        it { is_expected.not_to contain_concat__fragment('powerman.conf.header') }
        it { is_expected.not_to contain_file('/var/run/powerman') }
        it do
          is_expected.to contain_service('powerman').only_with(
            ensure: 'stopped',
            enable: 'false',
            name: 'powerman',
            hasstatus: 'true',
            hasrestart: 'true',
            require: 'Package[powerman]',
          )
        end
        it { is_expected.to contain_file('/etc/profile.d/powerman.sh').with_ensure('file') }
        it { is_expected.to contain_file('/etc/profile.d/powerman.csh').with_ensure('file') }
      end
    end # end context
  end # end on_supported_os loop
end # end describe
