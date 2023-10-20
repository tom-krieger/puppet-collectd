# frozen_string_literal: true

require 'spec_helper'

describe 'collectd::plugin::sensors', type: :class do
  let :pre_condition do
    'include collectd'
  end
  ######################################################################
  # Default param validation, compilation succeeds
  let :facts do
    {
      osfamily: 'RedHat',
      collectd_version: '4.8.0',
      operatingsystemmajrelease: '7',
      python_dir: '/usr/local/lib/python2.7/dist-packages'
    }
  end

  context ':ensure => present, default params' do
    let :facts do
      {
        osfamily: 'RedHat',
        collectd_version: '5.4',
        operatingsystemmajrelease: '7',
        python_dir: '/usr/local/lib/python2.7/dist-packages'
      }
    end

    it 'Will create /etc/collectd.d/10-sensors.conf' do
      is_expected.to contain_file('sensors.load').with(ensure: 'present', path: '/etc/collectd.d/10-sensors.conf', content: '#\ Generated by Puppet\n<LoadPlugin sensors>\n  Globals false\n</LoadPlugin>\n\n<Plugin "sensors">\n</Plugin>\n\n')
    end
  end

  ######################################################################
  # Remaining parameter validation, compilation fails

  context ':sensors param is not an array' do
    let :facts do
      {
        osfamily: 'RedHat',
        collectd_version: '5.4',
        operatingsystemmajrelease: '7',
        python_dir: '/usr/local/lib/python2.7/dist-packages'
      }
    end

    let :params do
      { sensors: true }
    end

    it 'Will raise an error about :sensors not being an array' do
      is_expected.to compile.and_raise_error(%r{array})
    end
  end

  context ':ignore_selected is not a bool' do
    let :facts do
      {
        osfamily: 'RedHat',
        collectd_version: '5.4',
        operatingsystemmajrelease: '7',
        python_dir: '/usr/local/lib/python2.7/dist-packages'
      }
    end
    let :params do
      { ignoreselected: 'true' }
    end

    it 'Will raise an error about :ignore_selected not being a boolean' do
      is_expected.to compile.and_raise_error(%r{"true" is not a boolean.  It looks to be a String})
    end
  end

  context ':interval is not default and is an integer' do
    let :facts do
      {
        osfamily: 'RedHat',
        collectd_version: '5.4',
        operatingsystemmajrelease: '7'
      }
    end
    let :params do
      { interval: 15 }
    end

    it 'Will create /etc/collectd.d/10-sensors.conf' do
      is_expected.to contain_file('sensors.load').with(ensure: 'present', path: '/etc/collectd.d/10-sensors.conf', content: %r{^  Interval 15})
    end
  end

  context ':ensure => absent' do
    let :facts do
      {
        osfamily: 'RedHat',
        collectd_version: '5.4',
        operatingsystemmajrelease: '7',
        python_dir: '/usr/local/lib/python2.7/dist-packages'
      }
    end
    let :params do
      { ensure: 'absent' }
    end

    it 'Will not create /etc/collectd.d/10-sensors.conf' do
      is_expected.to contain_file('sensors.load').with(ensure: 'absent',
                                                       path: '/etc/collectd.d/10-sensors.conf')
    end
  end

  context ':install_options install package with install options' do
    let :facts do
      {
        osfamily: 'RedHat',
        collectd_version: '5.4',
        operatingsystemmajrelease: '7',
        python_dir: '/usr/local/lib/python2.7/dist-packages'
      }
    end
    let :params do
      { ensure: 'present',
        install_options: ['--enablerepo=mycollectd-repo'] }
    end

    it 'Will install the package with install options' do
      is_expected.to contain_package('collectd-sensors').with(
        ensure: 'present',
        install_options: ['--enablerepo=mycollectd-repo']
      )
    end
  end
end
