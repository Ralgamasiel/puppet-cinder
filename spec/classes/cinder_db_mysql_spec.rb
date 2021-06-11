require 'spec_helper'

describe 'cinder::db::mysql' do
  let :req_params do
    {
      :password => 'cinderpass',
    }
  end

  let :pre_condition do
    'include mysql::server'
  end

  shared_examples 'cinder::db::mysql' do
    context 'with only required params' do
      let :params do
        req_params
      end

      it { is_expected.to contain_class('cinder::deps') }

      it { is_expected.to contain_openstacklib__db__mysql('cinder').with(
        :user     => 'cinder',
        :password => 'cinderpass',
        :host     => '127.0.0.1',
        :charset  => 'utf8',
        :collate  => 'utf8_general_ci',
      )}
    end

    context "overriding allowed_hosts param to array" do
      let :params do
        {
          :password      => 'cinderpass',
          :allowed_hosts => ['127.0.0.1','%']
        }
      end

      it { is_expected.to contain_openstacklib__db__mysql('cinder').with(
        :user          => 'cinder',
        :password      => 'cinderpass',
        :host          => '127.0.0.1',
        :charset       => 'utf8',
        :collate       => 'utf8_general_ci',
        :allowed_hosts => ['127.0.0.1', '%']
      )}
    end

    context "overriding allowed_hosts param to string" do
      let :params do
        {
          :password      => 'cinderpass2',
          :allowed_hosts => '192.168.1.1'
        }
      end

      it { is_expected.to contain_openstacklib__db__mysql('cinder').with(
        :user          => 'cinder',
        :password      => 'cinderpass2',
        :host          => '127.0.0.1',
        :charset       => 'utf8',
        :collate       => 'utf8_general_ci',
        :allowed_hosts => '192.168.1.1',
      )}
    end

    context "overriding allowed_hosts param equals to host param " do
      let :params do
        {
          :password       => 'cinderpass2',
          :allowed_hosts  => '127.0.0.1'
        }
      end

      it { is_expected.to contain_openstacklib__db__mysql('cinder').with(
        :user          => 'cinder',
        :password      => 'cinderpass2',
        :host          => '127.0.0.1',
        :charset       => 'utf8',
        :collate       => 'utf8_general_ci',
        :allowed_hosts => '127.0.0.1',
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'cinder::db::mysql'
    end
  end
end
