From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 30 Aug 2013 11:09:20 +0200
Subject: lvrename changes link to direct /dev/dm-X
In-Reply-To: <521F1A5F.9040805@mglug.de>
References: <521F1A5F.9040805@mglug.de>
Message-ID: <52206140.7060204@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.8.2013 11:54, Oliver Rath napsal(a):
> Hi list,
>
> I was able to reproduze the renaming issue on a gentoo-machine with lvm-git:
>
> heimserver ~ # lvcreate --name myoriginal -V 10M -T dmivg/winthinpool
>    Rounding up size to full physical extent 12,00 MiB
>    Logical volume "myoriginal" created
> heimserver ~ # ls -l /dev/dmivg/myoriginal
> lrwxrwxrwx 1 root root 28 29. Aug 11:46 /dev/dmivg/myoriginal ->
> /dev/mapper/dmivg-myoriginal

So Gentoo has broken udev rules as well probably.
Links created by proper udev rules should be pointing directly to /dev/dm-x


Have you been compiling lvm2 yourself ?

Have you configured lvm2 package with --enable-udev_rules?
(it's not enabled by default)

Isn't there any udev falback running in this system ?

Isn't device activated without udev?

In pre-udev  era all dm nodes have been created in /dev/mapper subdir.
So lvm created links pointing to this place.

With  udev  all dm nodes are by default created as  /dev/dm-xx and all
the links in /dev/mapper & /dev/vgname/lvname  are pointing directly
to this node - but that require proper udev rules and properly configured 
system -  I'd recommend  to test with i.e. Fedora.

Unfortunately systems like Debian are using non-upstream udev rules
from maintainer which are reinventing them based on some unknown rules to us...


> heimserver ~ # lvrename /dev/dmivg/myoriginal myrenamedoriginal
>    Renamed "myoriginal" to "myrenamedoriginal" in volume group "dmivg"
> heimserver ~ # ls -l /dev/dmivg/myrenamedoriginal
> lrwxrwxrwx 1 root root 8 29. Aug 11:47 /dev/dmivg/myrenamedoriginal ->
> ../dm-13
> heimserver ~ # ls -l /dev/mapper/dmivg-myrenamedoriginal
> lrwxrwxrwx 1 root root 8 29. Aug 11:47
> /dev/mapper/dmivg-myrenamedoriginal -> ../dm-13
>
>
> It seems, that after renaming the link points directly to the /dev/dm-X
> device, before that he linked to the link in /dev/mapper/..

Well as long as the point to the proper device at the end - it's at least 
usable - but it's clear the udev dir has been probably touched by fallback 
rules (which are there for cases, udev is failing to do proper thing)


> root at asterisk:~# ls -l /dev/mapper/dmivg-myoriginal
> lrwxrwxrwx 1 root root 8 Aug 29 11:50 /dev/mapper/dmivg-myoriginal ->
> ../dm-55
> root at asterisk:~# lvrename /dev/dmivg/myoriginal myrenamedoriginal
>    Renamed "myoriginal" to "myrenamedoriginal" in volume group "dmivg"
>    Unable to rename device node from 'dmivg-myoriginal' to

Udev rules are not doing what they supposed to do....

> 'dmivg-myrenamedoriginal'
> root at asterisk:~# ls -l /dev/dmivg/myrenamedoriginal
> lrwxrwxrwx 1 root root 35 Aug 29 11:51 /dev/dmivg/myrenamedoriginal ->
> /dev/mapper/dmivg-myrenamedoriginal
> root at asterisk:~# ls -l /dev/mapper/dmivg-myrenamedoriginal
> brw------- 1 root root 252, 55 Aug 29 11:51
> /dev/mapper/dmivg-myrenamedoriginal
> root at asterisk:~#
>
> Here the device twice: in /dev/dm-55 _and_ in
> /dev/mapper/dmivg-myrenamedoriginal
>
> @Zdenek: if you need a -vvvv log, please tell me.

If you have been compiling lvm2 yourself - you could replace upstream rules 
with those placed in Debian.

I guess the only real solution here would be to build Debian package by some 
lvm2 team member since the package in Debian is probably broken.

Zdenek


