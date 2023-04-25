# Step 1. Setup dnf
# 1. disable the `nodocs` flag, to allow dnf download document of package
# 2. let dnf choose fastest mirror (this option will improve experience if you have bad network)
sed -i '/^tsflags=nodocs$/d' /etc/dnf/dnf.conf
echo 'fastestmirror=1' >> /etc/dnf/dnf.conf

# Step 2. Downloads and caches metadata of the packages
dnf makecache

# Step 3. Install `man`
dnf install -y man

# Step 4. Reinstall all packages to get document/manual
for pkg in $(dnf repoquery --installed --qf "%{name}"); do dnf reinstall -qy $pkg; done

# Step 5. Install `systemd`
dnf install -y systemd

# Step 6. Install `ncurses` to get the `clear` command
dnf install -y ncurses

# Step 7. Remove the files for container in the root folder (they are not useful for WSL)
rm -f /root/anaconda-*
rm -f /root/original-ks.cfg

# Step 8. Clean up
dnf clean all
rm -f /root/.bash_history

exit && exit
