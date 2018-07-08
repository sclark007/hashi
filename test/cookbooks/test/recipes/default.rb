#
# Cookbook:: test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package 'unzip'

hashi_install 'consul' do
  version '1.2.0'
end

hashi_install 'nomad' do
  version '0.8.4'
end

hashi_install 'terraform' do
  version '0.11.7'
end

hashi_install 'vault' do
  version '0.10.3'
end

hashi_terraform_provider 'archive' do
  version '1.0.3'
end

hashi_service 'consul' do
  user 'consul'
  command '/usr/local/bin/consul agent -dev'
end
