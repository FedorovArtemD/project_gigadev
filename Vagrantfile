Vagrant.configure("2") do |config|
  # Отключаем проверку обновлений для ускорения запуска
  config.vm.box_check_update = false
  # Увеличиваем таймаут загрузки на всякий случай
  config.vm.boot_timeout = 600

  # ==========================================
  # VM 1: Backend + PostgreSQL (Ubuntu 22.04)
  # ==========================================
  config.vm.define "backend" do |backend|
    backend.vm.box = "ubuntu/jammy64"
    backend.vm.hostname = "backend-vm"
    backend.vm.network "private_network", ip: "192.168.56.10"
    
    backend.vm.provider "virtualbox" do |vb|
      vb.name = "giga-backend"
      vb.memory = 2048
      vb.cpus = 2
    end
  end

  # ==========================================
  # VM 2: Proxy + Redis (CentOS 9 Stream)
  # ==========================================
  config.vm.define "proxy" do |proxy|
    # <-- ВОТ ЭТОТ ОБРАЗ САМЫЙ СТАБИЛЬНЫЙ <--
    proxy.vm.box = "generic/centos9s" 
    proxy.vm.hostname = "proxy-vm"
    proxy.vm.network "private_network", ip: "192.168.56.11"
    
    proxy.vm.provider "virtualbox" do |vb|
      vb.name = "giga-proxy"
      vb.memory = 2048
      vb.cpus = 2
    end
  end
end