packer {
  required_plugins {
    hyperv = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

# Описание источника (Builder) для Hyper-V
source "hyperv-iso" "debian" {
  # Команда автоматического запуска инсталлятора с файлом ответов Preseed
  boot_command     = [
    "<esc><wait>",
    "install ",
    "auto=true ",
    "priority=critical ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "<enter>"
  ]
  boot_wait             = "10s"

  # Аппаратные характеристики временной ВМ (Динамическая память для снижения нагрузки)
  disk_size             = 15360 # 15 GB
  disk_block_size       = "1"
  enable_dynamic_memory = true
  generation            = 2
  guest_additions_mode  = "disable"

  # Сетевые настройки (используем стандартный коммутатор Windows)
  switch_name           = "Default Switch"

  # Локальный веб-сервер Packer для отдачи preseed.cfg
  http_directory        = "http"

  # ISO-образ и проверка целостности (SHA-256)
  iso_url               = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso"
  iso_checksum          = "sha256:2f6d2f347781b0a701986e661eb7fc873b9e4a3cb983e29f8f20387e35b0b2e3"

  # Доступ для provisioner-скрипта после установки ОС
  ssh_username          = "ansible"
  ssh_password          = "temporary_secure_password_123" # Временный пароль для этапа сборки
  ssh_timeout           = "30m"

  # Команда корректного выключения ВМ после настройки
  shutdown_command      = "echo 'temporary_secure_password_123' | sudo -S shutdown -P now"
  vm_name               = "debian-12-golden-image"
}

# Описание этапа сборки (Provisioning & Hardening)
build {
  sources = ["source.hyperv-iso.debian"]

  # Первичный системный Hardening ОС на этапе "выпекания" образа
  provisioner "shell" {
    inline = [
      "echo '==> Запуск базового Hardening операционной системы...'",

      # 1. SSH Hardening (запрет паролей и root намертво) [24, 47, 53]
      "sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config",
      "sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config",

      # 2. Очистка следов (Sysprep для Linux) перед сохранением шаблона
      "echo '==> Очистка сетевых идентификаторов и логов...'",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo find /var/log -type f -exec sudo truncate -s 0 {} \\\\;",
      "sudo rm -rf /root/.ssh /home/ansible/.ssh/id_*"
    ]
  }
}
