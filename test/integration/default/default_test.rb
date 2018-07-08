# # encoding: utf-8

# Inspec test for recipe hashi::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/


describe user('consul') do
  it { should exist }
end

describe group('consul') do
  it { should exist }
end

describe service('consul') do
  it { should be_installed }
end

describe file('/etc/systemd/system/consul.service') do
  its('content') do
    should eql <<-EOS
[Unit]
Description=consul
Wants=network.target
After=network.target

[Service]
Environment=
ExecStart=/usr/local/bin/consul agent -dev
ExecReload=/bin/kill -SIGHUP $MAINPID
KillSignal=SIGTERM
User=consul
Restart=on-failure

[Install]
WantedBy=multi-user.target
    EOS
  end
end
