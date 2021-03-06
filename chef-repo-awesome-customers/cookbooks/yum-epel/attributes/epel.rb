default['yum']['epel']['repositoryid'] = 'epel'
default['yum']['epel']['description'] = 'Extra Packages for $releasever - $basearch'
case node['kernel']['machine']
when 's390x'
  default['yum']['epel']['baseurl'] = 'https://kojipkgs.fedoraproject.org/rhel/rc/7/Server/s390x/os/'
  default['yum']['epel']['gpgkey'] = 'https://kojipkgs.fedoraproject.org/rhel/rc/7/Server/s390x/os/RPM-GPG-KEY-redhat-release'
else
  case node['platform']
  when 'amazon'
    default['yum']['epel']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
    default['yum']['epel']['gpgkey'] = 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
  else
    default['yum']['epel']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-$releasever&arch=$basearch'
    default['yum']['epel']['gpgkey'] = 'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-$releasever'
  end
end
default['yum']['epel']['failovermethod'] = 'priority'
default['yum']['epel']['gpgcheck'] = true
default['yum']['epel']['enabled'] = true
default['yum']['epel']['managed'] = true
default['yum']['epel']['make_cache'] = true
