checkversion() {
  version=$(grep -e '\s7' /etc/redhat-release -o | cut -c 2-)
}

fixnetwork() {
  sed -i "1s/.*/127.0.0.1   $(hostname).zacharyalexstern.com $(hostname) localhost localhost.localdomain localhost4 localhost4.localdomain4/" /etc/hosts
}

configure_repo() {
  if [ -e /etc/yum.repos.d/puppetlabs.repo ]; then
    echo "repo already configured, exiting..."
    exit 1
  fi

  echo "configuring yum repo."
  if [ $version -eq 7 ]; then
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
  elif [ $version -eq 6 ]; then
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
  else
    echo "sorry, os not supported"
    exit 1
  fi
}

install_puppet_master() {
  yum install -qy puppet-server
  puppet config set certname $(hostname -f) --section main
  puppet config set dns_alt_names $(hostname),$(hostname -f) --section main
  puppet config set server $(hostname -f) --section main
  systemctl start puppetmaster.service
}

checkversion
fixnetwork
configure_repo
install_puppet_master
