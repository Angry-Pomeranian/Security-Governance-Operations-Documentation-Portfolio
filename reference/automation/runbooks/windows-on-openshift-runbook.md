# Windows on OpenShift: Path A → Path B Runbook

## 0) Prereqs & Variables

You’ll need:

- OpenShift Virtualization (CNV), CDI, `virtctl`
- A reachable CDI upload proxy Route
- A Windows Server 2022 ISO (optionally “no-prompt” EFI variant)

Set these variables in your shell (adjust names to your standards):

- OS image/catalogue namespace (shared): `<OS_IMAGE_NAMESPACE>` (commonly `openshift-virtualization-os-images`)
- Work/project namespace (where you’ll build & run the VM): `<WORK_NS>`
- StorageClass for images/system disks: `<STORAGE_CLASS>`

Example variables (for notes only):

- ISO DV name: `win2k22-installer-iso`
- First VM/system disk DV name: `win2k22-sysdisk-build`
- Temporary installer VM name: `win2k22-buildvm`
- Golden PVC name: `win2k22-golden-pvc`
- DataSource name (catalogue): `win2k22`

---

# PATH A — Install Windows Once Using the ISO

## 1) (Optional) Build a “No-Prompt” EFI ISO Locally

If you already have one, skip.

- Mount → copy → swap `efisys_noprompt.bin` → re-ISO (your earlier steps)
- Resulting file: `/tmp/win2022-noprompt.iso`

## 2) Upload the Installer ISO Into the Catalogue (CDI DataVolume)

This creates a **DV/PVC** holding the ISO that any project can mount as a CD-ROM.

```bash
virtctl image-upload dv <ISO_DV_NAME> \
  --namespace <OS_IMAGE_NAMESPACE> \
  --size 6Gi \
  --uploadproxy-url https://<UPLOADPROXY_ROUTE>/ \
  --image-path "/tmp/win2022-noprompt.iso" \
  --insecure \
  --storage-class "<STORAGE_CLASS>" \
  --access-mode ReadWriteOnce
````

**Notes:**

* For `<UPLOADPROXY_ROUTE>`, use the `cdi-uploadproxy` route hostname.
* If you prefer TLS-validated uploads, drop `--insecure` and trust the CA.

## 3) Create a Blank System Disk (DataVolume) in Your Work Namespace

This is where Windows will be installed (60 Gi is a common baseline).

```yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: win2k22-sysdisk-build
  namespace: <WORK_NS>
spec:
  storage:
    storageClassName: <STORAGE_CLASS>
    resources:
      requests:
        storage: 60Gi
  source:
    blank: {}
```

Apply:

```bash
oc apply -f sysdisk-dv.yaml
```

## 4) Create a Temporary “Installer” VM

* CD-ROM from the ISO PVC/DV in the **image namespace**
* Root disk from the blank DV in **your work namespace**
* Defaults: SATA disk + e1000e NIC + EFI SecureBoot on

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: win2k22-buildvm
  namespace: <WORK_NS>
spec:
  runStrategy: Always
  template:
    metadata:
      labels:
        kubevirt.io/domain: win2k22-buildvm
    spec:
      domain:
        cpu:
          cores: 2
        memory:
          guest: 8Gi
        firmware:
          bootloader:
            efi:
              persistent: true
              secureBoot: true
        features:
          acpi: {}
          smm: {}
        devices:
          disks:
            - name: sysdisk
              disk:
                bus: sata
            - name: winiso
              cdrom:
                bus: sata
            - name: virtiocontainer
              cdrom:
                bus: sata
          interfaces:
            - name: default
              model: e1000e
              masquerade: {}
          tpm:
            persistent: true
      networks:
        - name: default
          pod: {}
      volumes:
        - name: sysdisk
          dataVolume:
            name: win2k22-sysdisk-build
        - name: winiso
          persistentVolumeClaim:
            claimName: <ISO_DV_NAME>
        - name: virtiocontainer
          containerDisk:
            image: quay.io/kubevirt/virtio-container-disk:latest
```

**Important:** You can’t directly mount a PVC from another namespace.
Instead, clone it into your work namespace:

**(A) DataSource in `<OS_IMAGE_NAMESPACE>`:**

```yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataSource
metadata:
  name: win2k22-installer-iso-ds
  namespace: <OS_IMAGE_NAMESPACE>
spec:
  source:
    pvc:
      name: <ISO_DV_NAME>
      namespace: <OS_IMAGE_NAMESPACE>
```

**(B) DataVolume in `<WORK_NS>` cloning from that DataSource:**

```yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: win2k22-installer-iso-clone
  namespace: <WORK_NS>
spec:
  sourceRef:
    kind: DataSource
    name: win2k22-installer-iso-ds
    namespace: <OS_IMAGE_NAMESPACE>
  storage:
    storageClassName: <STORAGE_CLASS>
    resources:
      requests:
        storage: 6Gi
    volumeMode: Filesystem
    accessModes:
      - ReadWriteOnce
```

In the VM spec, replace the PVC reference with:

```yaml
- name: winiso
  dataVolume:
    name: win2k22-installer-iso-clone
```

Apply and start:

```bash
oc apply -f iso-ds.yaml
oc apply -f iso-clone-dv.yaml
oc apply -f buildvm.yaml
virtctl start -n <WORK_NS> win2k22-buildvm
virtctl console -n <WORK_NS> win2k22-buildvm
```

## 5) Install Windows Normally

Inside the VM console:

* Select the blank disk (`sysdisk`) and install.
* For VirtIO later, load virtio drivers from `virtiocontainer` (D:\ in VM).
* After install: optional RDP, updates, base tools.

---

# PATH B — Create a Golden DataSource

## 6) Prepare the VM for Imaging (Inside Windows)

* Remove temp files/junk
* Install VirtIO drivers (recommended)
* Run:

```powershell
sysprep /generalize /oobe /shutdown
```

## 7) Stop the VM in OpenShift

```bash
oc -n <WORK_NS> stop vm/win2k22-buildvm || true
```

## 8) Identify the System Disk PVC

```bash
oc -n <WORK_NS> get pvc
```

Find the PVC for `win2k22-sysdisk-build` → `<SYSDISK_PVC_NAME>`.

## 9) Clone the System Disk PVC to a Golden PVC

```yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: win2k22-golden-pvc
  namespace: <OS_IMAGE_NAMESPACE>
spec:
  source:
    pvc:
      name: <SYSDISK_PVC_NAME>
      namespace: <WORK_NS>
  storage:
    storageClassName: <STORAGE_CLASS>
    resources:
      requests:
        storage: 60Gi
    accessModes:
      - ReadWriteOnce
```

Apply and wait:

```bash
oc apply -f golden-clone-dv.yaml
oc -n <OS_IMAGE_NAMESPACE> wait dv/win2k22-golden-pvc --for=condition=Succeeded --timeout=30m
```

## 10) Create the Golden DataSource

```yaml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataSource
metadata:
  name: win2k22
  namespace: <OS_IMAGE_NAMESPACE>
spec:
  source:
    pvc:
      name: win2k22-golden-pvc
      namespace: <OS_IMAGE_NAMESPACE>
```

```bash
oc apply -f datasource-golden.yaml
```

Your templates can now:

```yaml
sourceRef:
  kind: DataSource
  name: win2k22
  namespace: <OS_IMAGE_NAMESPACE>
```

## 11) (Optional) Update Templates for Performance

* Disk bus: `virtio`
* NIC model: `virtio`
* Keep EFI + SecureBoot + TPM

---

# Quick Lifecycle Summary

1. Upload ISO (once) → build one VM (Path A)
2. Sysprep & shut down → clone to golden PVC (once)
3. Publish DataSource → point templates at it (Path B)
4. Refresh golden after patching (new PVC, update DataSource)

---

## Assumptions

* CDI upload proxy reachable, `<WORK_NS>` can create DVs/VMs
* StorageClass supports PVC cloning
* UEFI + SecureBoot used

## Pitfalls

* Cross-namespace PVC mount not allowed → use clone method
* Secure Boot vs unsigned drivers
* Install VirtIO drivers early
* Golden namespace must have storage quota
* Always sysprep before cloning

## Verification

* Snapshot before cloning
* Test VM from new DataSource
* Script steps 9–10 for monthly golden refresh

```
