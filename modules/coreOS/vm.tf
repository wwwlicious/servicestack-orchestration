
# Create CoreOS base image

resource "azurerm_virtual_machine" "coreos_vm" {
    name                    = "${var.azure_vm_name}"
    location                = "${var.azure_region}"
    resource_group_name     = "${var.azure_resource_group_name}"
    network_interface_ids   = ["${var.azure_virtual_network_id}"]
    vm_size                 = "${var.azure_image_vm_size}"

    storage_image_reference {
        publisher           = "${var.azure_image_publisher}"
        offer               = "${var.azure_image_offer}"
        sku                 = "${var.azure_image_sku}"
        version             = "${var.azure_image_version}"
    }

    storage_os_disk {
        name                = "osdisk"
        vhd_uri             = "${var.azure_vm_os_vhd_url}"
        caching             = "ReadWrite"
        create_option       = "FromImage"
    }

    os_profile {
        computer_name       = "${var.azure_vm_name}"
        admin_username      = "${var.azure_vm_admin_name}"
        admin_password      = "${var.azure_vm_admin_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags {
        environment = "${var.azure_vm_tag_environment}"
    }
}