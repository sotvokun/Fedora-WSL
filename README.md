Fedora-WSL
----------------------

Fedora is a popular Linux distribution.

This repository offers a "recipe" to allow WSL(Windows Subsystem for Linux) user get the Fedora experience.

## Goal

This repository aims at creating a minimum, usable, clean Fedora distribution on WSL environment.

## Requirements

- WSL version >= 1.1.0
- Network connect with Internet

## Recipe

### 1. Download the Fedora Container Base build

The first thing is to download the rootfs file of Fedora Container Base edition. We can get it at the [Fedora Build System](https://koji.fedoraproject.org/koji/builds?order=-build_id).

Find the the package named `Fedora-Container-Base-<version>-<date>`. If you like rolling release, you can choose the `rawhide` version, otherwise the numeric version is a good choice.

In the detail page, there have 4 different files we can download under _Image Archives_ > _xz_. Download the file with the same architecture as your computer.

### 2. Extract the file to get rootfs tarball

After download, we need extract the .tar.xz to get the real rootfs file. The file tree in the .tar.xz file looks like:
```
 - Fedora-Container-Base-Rawhide-20230425.n.0.x86_64.tar.xz
   |
   `- Fedora-Container-Base-Rawhide-20230425.n.0.x86_64.tar
      |
      |- <a directory named with a hash string>
      |  |
      |  |- json
      |  |- VERSION
      |  `- layer.tar (** THE ROOTFS FILE **)
      |
      |- <hash>.json
      |- manifest.json
      `- repositories
```

Extracting the `layer.tar` file into the place as you like.

### 3. Import into WSL

Now we need to run `wsl --import` command to install Fedora. The usage of this command is:

**NOTE: Only the WSL2 supports the full features of Linux, make sure your WSL default version is 2, or add the `--version 2` flag when you run import command**

`wsl --import <distribution-name> <install-location> <rootfs-file-path>`

When the operation is completed, we can run Fedora with `wsl -d <distribution-name>`, or you can set it as default with `wsl -s <distribution-name>`.

### 4. Run commands to make it useful

The container based edition is minimum, but it is not usable for us. There no systemd, no manual, even no clear command. To achive the goal of this repository, we just need run some commands to install the necessary packages.

You can run the script in the repository named `init-fedora-wsl.sh`.

```sh
# Step 1. Setup dnf
# 1. disable the `nodocs` flag, to allow dnf download document of package
# 2. let dnf choose fastest mirror (this option will improve experience if you have bad network)
sed -i '/^tsflags=nodocs$/d' /etc/dnf/dnf.conf
echo 'fastestmirror=1' >> /etc/dnf/dnf.conf

# Step 2. Downloads and caches metadata of the packages
dnf makecache

# Step 3. Install `man` and `man-pages`
dnf install -y man man-pages

# Step 4. Reinstall all packages to get document/manual
for pkg in $(dnf repoquery --installed --qf "%{name}"); do dnf reinstall -qy $pkg; done

# Step 5. Install `systemd`
dnf install -y systemd

# Step 6. Install `ncurses` to get the `clear` command
dnf install -y ncurses

# Step 7. Remove the files for container in the root folder (they are not useful for WSL)
rm -f /root/anaconda-*
rm -f /root/original-ks.cfg
```

### 5. (Optional) Exporting a clean distribution

After we done the commands. We will get a minimum, usable, clean Fedora distribution for WSL. We can export it to a tar file:

```sh
# Step 1. Clean all caches
dnf clean all

# Step 2. Remove the bash history of root user
rm -f /root/.bash_history

# Step 3. Exit WSL
```

Then will go back to the Windows Command Prompt (or PowerShell), do the following command to generate a clean Fedora distribution:

```
wsl --export <distribution-name> <tar-file-name>
```

## See Also
## Some missing packages

The container-base edition of Fedora does not have some necessary packages, you should install them by yourself.

### passwd support

```
dnf install -y cracklib-dicts passwd
```

### Fedora Remix for WSL
If the recipe is hard for you, I recommend to use [Fedora Remix for WSL](https://github.com/WhitewaterFoundry/Fedora-Remix-for-WSL). You can download it on the Microsoft Store.
