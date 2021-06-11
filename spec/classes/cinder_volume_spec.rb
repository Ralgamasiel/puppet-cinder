require 'spec_helper'

describe 'cinder::volume' do
  let :pre_condition do
    "class { 'cinder::db':
       database_connection => 'mysql://a:b@c/d'
     }"
  end

  shared_examples 'cinder::volume' do
    it { is_expected.to contain_service('cinder-volume').with(
      :hasstatus => true,
      :tag       => 'cinder-service',
    )}

    it { is_expected.to contain_cinder_config('DEFAULT/cluster').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_cinder_config('DEFAULT/volume_clear').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_cinder_config('DEFAULT/volume_clear_size').with_value('<SERVICE DEFAULT>') }
    it { is_expected.to contain_cinder_config('DEFAULT/volume_clear_ionice').with_value('<SERVICE DEFAULT>') }

    context 'with manage_service false' do
      let :params do
        {
          :manage_service => false
        }
      end

      it { is_expected.to contain_service('cinder-volume').without_ensure }
    end

    context 'with volume_clear parameters' do
      let :params do
        {
          :volume_clear        => 'none',
          :volume_clear_size   => '10',
          :volume_clear_ionice => '-c3',
        }
      end

      it {
        is_expected.to contain_cinder_config('DEFAULT/volume_clear').with_value('none')
        is_expected.to contain_cinder_config('DEFAULT/volume_clear_size').with_value('10')
        is_expected.to contain_cinder_config('DEFAULT/volume_clear_ionice').with_value('-c3')
      }
    end

    context 'with cluster parameter' do
      let :params do
        {
          :cluster => 'my_cluster',
        }
      end

      it {
        is_expected.to contain_cinder_config('DEFAULT/cluster').with_value('my_cluster')
      }
    end
  end

  shared_examples 'cinder::volume on Debian' do
    it { is_expected.to contain_package('cinder-volume').with_ensure('present') }
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'cinder::volume'

      if facts[:osfamily] == 'Debian'
        it_behaves_like 'cinder::volume on Debian'
      end
    end
  end
end
