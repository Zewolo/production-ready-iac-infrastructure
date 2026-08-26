# variables.tf

# variables.tf

variable "hyperv_user" {
  type        = string
  description = "Имя административного пользователя Windows"
  default     = "vovap" # Твой текущий пользователь Windows
}

variable "hyperv_password" {
  type        = string
  description = "Пароль твоей учетной записи Windows (для WinRM-авторизации)"
  sensitive   = true # Скрывает пароль в выводах консоли
}

variable "hyperv_host" {
  type        = string
  description = "Адрес WinRM-хоста (localhost)"
  default     = "127.0.0.1"
}

variable "hyperv_port" {
  type        = number
  description = "Порт WinRM HTTPS"
  default     = 5986
}

variable "hyperv_https" {
  type        = bool
  description = "Использовать ли безопасный HTTPS"
  default     = true
}

variable "golden_image_path" {
  type        = string
  description = "Абсолютный путь к нашему Золотому Образу VHDX, созданному в Packer"
  default     = "C:/Users/vovap/Documents/projects/production-ready-iac-infrastructure/packer/output-debian/Virtual Hard Disks/debian-13-golden-image.vhdx"
}

variable "vms_destination_dir" {
  type        = string
  description = "Папка на диске хоста, куда будут складываться скопированные диски и файлы конфигурации ВМ"
  default     = "C:/Users/vovap/Documents/projects/production-ready-iac-infrastructure/terraform/vms"
}

variable "switch_name" {
  type        = string
  description = "Имя виртуального коммутатора Hyper-V, к которому подключаются ВМ"
  default     = "Default Switch"
}

variable "vms_config" {
  type = map(object({
    cpu_cores      = number
    startup_memory = number # в байтах (например, 2 ГБ = 2147483648)
    min_memory     = number # Минимальный порог динамической памяти (512 МБ = 536870912)
    max_memory     = number # Максимальный порог динамической памяти (4 ГБ = 4294967296)
  }))
  description = "Словарь с конфигурациями наших виртуальных машин"
}
