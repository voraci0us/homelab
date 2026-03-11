Note that to use two different CSI drivers (ZFS zvol and ZFS dataset) the Helm chart must be installed twice, with two different release names (a single install of the chart supports multiple storageClasses, but they must use the same CSI driver).

Before installing the charts, first I manually created the encrypted ZFS parent datasets:
```
head -c 32 /dev/urandom | sudo tee /root/keys/zfs-fast.key > /dev/null
chmod 600 /root/keys/zfs-fast.key
zfs create -o encryption=on -o keyformat=raw -o keylocation=file:///root/keys/zfs-fast.key fast/k8s
zfs create -o encryption=on -o keyformat=raw -o keylocation=file:///root/keys/zfs-fast.key fast/vm
```
Then the child datasets:
```
zfs create fast/k8s/vols
zfs create fast/k8s/snaps
zfs create fast/vm/vols
zfs create fast/vm/snaps
```