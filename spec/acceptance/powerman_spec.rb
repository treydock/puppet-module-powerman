# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'powerman class:' do
  let(:user) do
    if fact('os.family') == 'Debian' && ['11', '22.04'].include?(fact('os.release.major'))
      'powerman'
    else
      'daemon'
    end
  end

  context 'with default parameters' do
    it 'runs successfully' do
      pp = <<-PP
      class { 'powerman': }
      powerman::device { 'bmc-compute01-ipmi':
        driver   => 'ipmipower',
        endpoint => 'ipmipower -u admin -p foo -h bmc-compute01 |&'
      }
      powerman::node { 'compute01':
        device => 'bmc-compute01-ipmi',
        port   => 'bmc-compute01',
      }
      PP

      apply_manifest(pp, catch_failures: true)
      on hosts, 'journalctl -u powerman -e --no-pager'
      apply_manifest(pp, catch_changes: true)
    end

    describe package('powerman') do
      it { is_expected.to be_installed }
    end

    describe service('powerman') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file('/etc/powerman/powerman.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 640 }
      it { is_expected.to be_owned_by user }
      it { is_expected.to be_grouped_into 'root' }
    end
  end
end
