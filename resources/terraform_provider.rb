# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

#
# Cookbook:: hashi
# Resource:: terraform_plugins
#
# Copyright:: 2018, Steve Clark
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
property :name, String, name_property: true
property :version, String, default: ''
property :install_path, String, default: '/usr/local/bin/'
property :zip_uri, String, default: lazy { |r| "https://releases.hashicorp.com/terraform-provider-#{r.name}/#{r.version}/terraform-provider-#{r.name}_#{r.version}_linux_amd64.zip" }, desired_state: false
property :zip_path, String, default: lazy { |r| "#{Chef::Config['file_cache_path']}/#{r.name}_#{r.version}_linux_amd64.zip" }, desired_state: false

action :install do

  remote_file "Downloading: terraform-provider-#{new_resource.name} Version: #{new_resource.version}" do
    source new_resource.zip_uri
    path new_resource.zip_path
    notifies :run, "execute[Install_#{new_resource.name}]", :immediately
    not_if { ::File.exist?("#{new_resource.install_path}/#{new_resource.name}") }
  end

  # make sure the instance's user owns the instance install dir
  execute "Install_#{new_resource.name}" do
    command "unzip #{new_resource.zip_path} -d #{new_resource.install_path}"
    action :nothing
  end

end
