require 'spec_helper'

describe 'powerman' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('powerman') }

      it do
        is_expected.to contain_package('powerman').only_with(ensure: 'present',
                                                             name: 'powerman')
      end

      it do
        is_expected.to contain_concat('/etc/powerman/powerman.conf').with(ensure: 'present',
                                                                          owner: 'root',
                                                                          group: 'daemon',
                                                                          mode: '0640',
                                                                          require: 'Package[powerman]')
      end

      it do
        is_expected.to contain_file('/var/run/powerman').with(ensure: 'directory',
                                                              owner: 'daemon',
                                                              group: 'daemon',
                                                              mode: '0755',
                                                              require: 'Package[powerman]',
                                                              before: 'Service[powerman]')
      end

      it do
        is_expected.to contain_service('powerman').only_with(ensure: 'running',
                                                             enable: 'true',
                                                             name: 'powerman',
                                                             hasstatus: 'true',
                                                             hasrestart: 'true',
                                                             subscribe: 'Concat[/etc/powerman/powerman.conf]')
      end

      context 'when server => false' do
        let(:params) { { server: false } }

        it { is_expected.to contain_package('powerman') }
        it { is_expected.not_to contain_concat('/etc/powerman/powerman.conf') }
        it { is_expected.not_to contain_file('/var/run/powerman') }
        it do
          is_expected.to contain_service('powerman').only_with(ensure: 'stopped',
                                                               enable: 'false',
                                                               name: 'powerman',
                                                               require: 'Package[powerman]')
        end
      end
    end # end context
  end # end on_supported_os loop
end # end describe
