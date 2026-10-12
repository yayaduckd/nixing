1. Partition with boot and nixs partitions
2. Place key in /var/lib/age/feather-key.txt
3. Install
```
parted /dev/sda -- mklabel gpt mkpart ESP fat32 1MiB 512MiB set 1 esp on mkpart primary ext4 512MiB 100%
mkfs.fat -F 32 -n boot /dev/sda1
mkfs.ext4 -L nixos /dev/sda2
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

mkdir -p /mnt/var/lib/age
cat > /mnt/var/lib/age/worker-identity.txt << 'EOF'
AGE-SECRET-KEY-1...<YOUR_PRIVATE_KEY_HERE>...
EOF
chmod 600 /mnt/var/lib/age/worker-identity.txt

nixos-install --flake github:<user>/<repo>#<hostname> --no-root-passwd
reboot
```
