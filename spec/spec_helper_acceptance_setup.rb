# Hack to work around issues with recent systemd and docker and running services as non-root
if fact('os.family') == 'RedHat' && fact('os.release.major').to_i >= 7
  service_hack = <<-EOS
[Service]
Type=simple
User=root
Group=root
ExecStart=
ExecStart=/usr/sbin/powermand -f
EOS

  on hosts, 'mkdir -p /etc/systemd/system/powerman.service.d'
  create_remote_file(hosts, '/etc/systemd/system/powerman.service.d/hack.conf', service_hack)
end
