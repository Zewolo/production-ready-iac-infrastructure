# main.tf

# 1. Шаг клонирования дисков: для каждой ВМ создаем свою папку и копируем туда наш Золотой Образ
resource "null_resource" "clone_os_disks" {
  for_each = var.vms_config

  triggers = {
    # Ресурс пересоздастся только если изменится путь к базовому образу
    golden_image = var.golden_image_path
  }

  provisioner "local-exec" {
    # Вызываем нативный PowerShell Windows для мгновенного копирования VHDX-диска
    command     = "New-Item -ItemType Directory -Force -Path '${var.vms_destination_dir}/${each.key}'; Copy-Item -Path '${var.golden_image_path}' -Destination '${var.vms_destination_dir}/${each.key}/os_disk.vhdx' -Force"
    interpreter = ["PowerShell", "-Command"]
  }
}

# 2. Шаг создания виртуальных машин в Hyper-V
resource "hyperv_machine_instance" "vms" {
  for_each = var.vms_config

  name            = each.key
  generation      = 2 # Генерация 2 (UEFI), соответствующая нашему образу Packer
  processor_count = each.value.cpu_cores

# Настройка динамической памяти (Исправлено: убрали static_memory для исключения конфликта схемы)
  dynamic_memory       = true
  memory_startup_bytes = each.value.startup_memory
  memory_minimum_bytes = each.value.min_memory
  memory_maximum_bytes = each.value.max_memory

  # Интеграционные службы Hyper-V для корректного выключения и синхронизации
  integration_services = {
    "Shutdown" = true
    "Time Synchronization" = true
  }

  # Сетевой адаптер
  network_adaptors {
    name        = "wan"
    switch_name = var.switch_name
  }

  # Подключение жесткого диска (Исправлено: добавлены обязательные параметры SCSI-контроллера)
  hard_disk_drives {
    path                = "${var.vms_destination_dir}/${each.key}/os_disk.vhdx"
    controller_number   = 0  # Подключаем к первому SCSI-контроллеру (0)
    controller_location = 0  # На свободное место (0)
  }

  # КРИТИЧЕСКИ ВАЖНО: Машина должна создаваться ТОЛЬКО после того, как диск скопировался на шаге 1!
  depends_on = [null_resource.clone_os_disks]
}