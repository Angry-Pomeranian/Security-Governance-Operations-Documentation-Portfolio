# Windows Server 2022 Medium Template (OpenShift Virtualization)

## Overview
This OpenShift Virtualization (CNV/KubeVirt) template defines a **Microsoft Windows Server 2022** virtual machine with a "medium" flavor (4 GiB RAM, 1 vCPU, 60 GiB disk).  
It is designed to **clone from a pre-built golden image DataSource** so new VMs can be created quickly without manual OS installation.

**Key features:**
- Preconfigured with EFI firmware and Secure Boot
- Includes TPM (Trusted Platform Module) persistence
- SATA root disk (can be changed to VirtIO once VirtIO drivers are in the golden image)
- E1000e network interface (safe default for initial boot)
- Validation rules to ensure supported device buses and memory requirements

---

## Prerequisites
1. **OpenShift Virtualization enabled** (CNV operators installed)
2. **Containerized Data Importer (CDI)** enabled
3. A **golden image DataSource** for Windows Server 2022:
   - Example:
     - Name: `win2k22`
     - Namespace: `openshift-virtualization-os-images`
   - Backed by a sysprepped Windows Server 2022 PVC
4. **StorageClass** with enough capacity (60 GiB or more)
5. User permissions to create VMs and clone DataVolumes

---

## Parameters
The template exposes the following parameters:

| Name | Description | Default |
|------|-------------|---------|
| `NAME` | VM name | Auto-generated: `windows2022-[a-z0-9]{6}` |
| `DATA_SOURCE_NAME` | Name of the DataSource to clone | `win2k22` |
| `DATA_SOURCE_NAMESPACE` | Namespace of the DataSource | `openshift-virtualization-os-images` |

---

## Editing for Your Environment
If you created your own golden image DataSource in **Path B** of the runbook:
- Set `DATA_SOURCE_NAME` to the golden DataSource name
- Set `DATA_SOURCE_NAMESPACE` to the namespace where your golden is stored
- (Optional) Update the root disk bus to `virtio` if the golden image contains VirtIO drivers:
  ```yaml
  disks:
    - disk:
        bus: virtio
      name: rootdisk
````

---

## Deployment Steps

1. **Verify the DataSource exists:**

   ```bash
   oc -n <DATA_SOURCE_NAMESPACE> get datasource <DATA_SOURCE_NAME>
   ```

2. **Process the template:**

   ```bash
   oc process -f windows2k22-server-medium.yaml \
     -p NAME=my-winvm \
     -p DATA_SOURCE_NAME=win2k22 \
     -p DATA_SOURCE_NAMESPACE=openshift-virtualization-os-images \
     | oc apply -f -
   ```

3. **Start the VM:**

   ```bash
   virtctl start my-winvm
   ```

4. **Access the console:**

   ```bash
   virtctl console my-winvm
   ```

---

## Validation Rules

This template includes built-in checks:

* Minimum memory requirement: ≥ 512 MiB (default is 4 GiB)
* Disk bus must be `virtio`, `sata`, or `scsi`
* CD-ROM bus must be `sata`
* Warns if not using `virtio` for the disk bus

---

## Example Use Case

* After completing **Path B** in the Windows VM Runbook, point this template at your new `win2k22` DataSource.
* All new VMs will be cloned from the golden image and ready to configure without a manual install process.

---

## References

* [OpenShift Virtualization Documentation](https://docs.openshift.com/container-platform/latest/virt/virt-overview.html)
* [KubeVirt Documentation](https://kubevirt.io/user-guide/)
* [Containerized Data Importer (CDI)](https://github.com/kubevirt/containerized-data-importer)

```
