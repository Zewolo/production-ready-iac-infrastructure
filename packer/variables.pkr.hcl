# variables.pkr.hcl

variable "os_version" {
  type        = string
  description = "Актуальная мажорная/минорная версия дистрибутива Debian"
  default     = "13.6.0"
}

variable "iso_checksum" {
  type        = string
  description = "SHA-256 контрольная сумма скачиваемого netinst ISO-образа"
}

variable "vm_name" {
  type        = string
  description = "Имя результирующей виртуальной машины шаблона в Hyper-V"
  default     = "debian-13-golden-image"
}

variable "disk_size" {
  type        = number
  description = "Размер жесткого диска создаваемой ВМ (в мегабайтах)"
  default     = 15360 # 15 GB
}

variable "ssh_username" {
  type        = string
  description = "Имя административного пользователя для этапа автоматизации"
  default     = "ansible"
}

variable "ssh_password" {
  type        = string
  description = "Временный пароль для подключения Packer по SSH на этапе сборки"
  sensitive   = true # Скрывает пароль в логах сборки Packer
}