# To learn more about Custom Resources, see https://docs.chef.io/custom_resources.html

#
# Cookbook:: hashi
# Resource:: install
#
# Copyright:: 2018, Steve Clark
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
property :install_path, String, default: lazy { |r| "/opt/hashicorp/#{r.name}_#{r.version.tr('.', '_')}" }
property :zip_uri, String, default: lazy { |r| "https://releases.hashicorp.com/#{r.name}/#{r.version}/#{r.name}_#{r.version}_linux_amd64.zip" }, desired_state: false
property :zip_path, String, default: lazy { |r| "#{Chef::Config['file_cache_path']}/#{r.name}_#{r.version}_linux_amd64.zip" }, desired_state: false

action :install do
  # some RHEL systems lack tar in their minimal install

  directory "#{new_resource.name} install dir" do
    mode '0755'
    path new_resource.install_path
    recursive true
    owner 'root'
    group 'root'
  end

  remote_file "Downloading: #{new_resource.name} Version: #{new_resource.version}" do
    source new_resource.zip_uri
    path new_resource.zip_path
    notifies :run, "execute[Install_#{new_resource.name}]", :immediately
    # not_if { ::File.exist?("#{Chef::Config['file_cache_path']}/#{new_resource.name}_#{new_resource.version}_linux_amd64.zip") }
    not_if { ::File.exist?("#{new_resource.install_path}/#{new_resource.name}") }
  end

  # make sure the instance's user owns the instance install dir
  execute "Install_#{new_resource.name}" do
    command "unzip #{new_resource.zip_path} -d #{new_resource.install_path}"
    action :nothing
  end

  # create a link that points to the latest version of the instance
  link "/usr/local/bin/#{new_resource.name}" do
    to "#{new_resource.install_path}/#{new_resource.name}"
  end

end

action_class do
  def whyrun_supported?
    true
  end

  def zip_filename
    arch =
      case node['kernel']['machine']
      when 'x86_64', 'amd64' then 'amd64'
      when /i\d86/ then '386'
      else node['kernel']['machine']
      end
    "#{new_resource.program}_#{new_resource.version}_#{node['os']}_#{arch}.zip"
  end

  def unzip_dir
    if new_resource.use_symlink
      ::File.join(new_resource.dir, "#{new_resource.program}-#{new_resource.version}")
    else
      new_resource.dir
    end
  end
end
