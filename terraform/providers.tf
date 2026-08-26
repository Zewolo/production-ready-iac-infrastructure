# providers.tf

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.0.4"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

provider "hyperv" {
  user            = var.hyperv_user
  password        = var.hyperv_password
  host            = var.hyperv_host
  port            = var.hyperv_port
  https           = var.hyperv_https
  insecure        = true # Разрешаем самоподписанный SSL-сертификат localhost
  use_ntlm        = true # КРИТИЧЕСКИ ВАЖНО: использовать Windows NTLM-авторизацию
}

