# debian.pkr.hcl

packer {
  required_plugins {
    hyperv = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

# Источник сборки (Builder)
source "hyperv-iso" "debian" {
  iso_url      = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-${var.os_version}-amd64-netinst.iso"
  iso_checksum = var.iso_checksum

  # Аппаратные характеристики временной ВМ из переменных
  disk_size             = var.disk_size
  disk_block_size       = "1"
  enable_dynamic_memory = true
  generation            = 2
  guest_additions_mode  = "disable"
  vm_name               = var.vm_name

  # Сетевые настройки гипервизора
  switch_name           = "Default Switch"
  http_directory        = "http"
  boot_wait             = "10s"

  # Автоматический UEFI GRUB запуск инсталлятора с передачей preseed.cfg
  boot_command     = [
    "c<wait>",
    "linux /install.amd/vmlinuz auto=true priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg --- <enter>",
    "initrd /install.amd/initrd.gz<enter>",
    "boot<enter>"
  ]

  # Параметры авторизации для выполнения Hardening-скриптов
  ssh_username          = var.ssh_username
  ssh_password          = var.ssh_password
  ssh_timeout           = "30m"

  # Безопасное выключение
  shutdown_command      = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
}

# Этап постобработки и системного Hardening
build {
  sources = ["source.hyperv-iso.debian"]

  # Скрипт первичной защиты ОС на этапе выпекания (Bake)
  provisioner "shell" {
    inline = [
      "echo '==> Шаг 1: Запуск Hardening конфигурации SSH-демона...'",
      "sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config",
      "sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config",

      "echo '==> Шаг 2: Системная очистка (Sysprep) золотого образа...'",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo find /var/log -type f -exec truncate -s 0 {} +",
      "sudo rm -rf /root/.ssh /home/${var.ssh_username}/.ssh/id_*"
    ]
  }
}