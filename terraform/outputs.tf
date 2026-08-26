# outputs.tf

output "created_vms" {
  value = {
    for name, vm in hyperv_machine_instance.vms : name => {
      id             = vm.id
      processor_count = vm.processor_count
      memory_startup = vm.memory_startup_bytes
      switch_name    = vm.network_adaptors[0].switch_name
      disk_path      = vm.hard_disk_drives[0].path
    }
  }
  description = "Параметры развернутых виртуальных машин в Hyper-V"
}
