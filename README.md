# qpid-portage-overlay
Portage ebuild files for the Qpid projects: qpid-proton, qpid-cpp (broker), qpid-dispatch (router), qpid-python, qpid-qmf and qpid-tools (python)

How to use layman: http://wiki.gentoo.org/wiki/Layman
Essentially, install layman:
```Shell
sudo emerge --ask app-portage/layman # One-off installation
echo "source /var/lib/layman/make.conf" | sudo tee -a /etc/portage/make.conf > /dev/null # One-off configuration
```
Since this repo is not (yet) in the layman repositories, either use the "layman-overlay-maker" utility to configure the overlay or manually create a file eg: /var/lib/layman/qpid-manual.xml containing:
```xml
<?xml version="1.0" ?>
<repositories version="1.0">
    <repo priority="50" quality="experimental" status="unofficial">
        <name>qpid-manual</name>
        <description>Qpid custom ebuilds</description>
        <homepage>https://github.com/fourceu/qpid-portage-overlay</homepage>
        <owner>
            <email>info@fourc.eu</email>
        </owner>
        <source type="git">https://github.com/fourceu/qpid-portage-overlay.git</source>
    </repo>
</repositories>
```
and finallay add the overly to layman:
```Shell
sudo layman -a qpid-manual
```

That completes configuration. Packages can now be installed as normal via emerge.

NB: In addition to running emerge --sync periodically, it is necessary to run layman -S to perform the same task for layman repositories.
