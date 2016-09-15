# qpid-portage-overlay
This overlay contains Portage ebuild files for the Qpid projects: qpid-proton, qpid-cpp (broker), qpid-dispatch (router), qpid-python, qpid-qmf and qpid-tools (python)

# Usage method 1 - /etc/portage/repos.conf directory.
This method uses the updated Portage configuration in which /etc/portage/repos.conf is a directory. If repos.conf is a file, either update the portage configuration or use layman as described below.
Place a repo description file in the /etc/portage/repos.conf directory containing the following:
```ini
[Apache-Qpid]
sync-type=git
sync-uri=https://github.com/fourceu/qpid-portage-overlay.git
location=/var/lib/portage-repos/Apache-Qpid
```
An emerge --sync will now include this repository.

# Useage method 2 - layman

How to use layman: http://wiki.gentoo.org/wiki/Layman
Essentially, install layman:
```Shell
sudo emerge --ask app-portage/layman # One-off installation
echo "source /var/lib/layman/make.conf" | sudo tee -a /etc/portage/make.conf > /dev/null # One-off configuration
```
Since this repo is not (yet) in the layman repositories, either use the "layman-overlay-maker" utility to configure the overlay or manually create a file eg: /etc/layman/overlays/qpid-manual.xml containing:
```xml
<?xml version="1.0" ?>
<repositories version="1.0">
    <repo priority="50" quality="experimental" status="unofficial">
        <name>Apache-Qpid</name>
        <description>Qpid ebuilds</description>
        <homepage>https://github.com/fourceu/qpid-portage-overlay</homepage>
        <owner>
            <email>info@fourc.eu</email>
        </owner>
        <source type="git">https://github.com/fourceu/qpid-portage-overlay.git</source>
    </repo>
</repositories>
```
and finally, update layman and add the overlay:
```Shell
sudo layman -S
sudo layman -a qpid-manual
```

That completes configuration. Packages can now be installed as normal via emerge.

NB: In addition to running emerge --sync periodically, it is necessary to run layman -S to perform the same task for layman repositories. Alternatively, add the following content to /etc/portage/postsync.d/layman-sync and ensure the file is executable:
```Shell
#!/bin/bash
[ -x /usr/bin/layman ] && /usr/bin/layman -S
```

