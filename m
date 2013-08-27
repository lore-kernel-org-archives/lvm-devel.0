From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 27 Aug 2013 15:43:07 +0200
Subject: example [was Re: thinpool-block-device exists twice after renaming]
In-Reply-To: <521CAA85.5040003@mglug.de>
References: <521CA389.504@mglug.de> <521CAA85.5040003@mglug.de>
Message-ID: <521CACEB.1020607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.8.2013 15:32, Oliver Rath napsal(a):
> Here an example for recreating the situation:
>
>
> asterix:lvm2# lvcreate --name renametest -V 100M -T myvg/mythinpool
>    Logical volume "renametest" created
> asterix:lvm2# lvrename /dev/myvg/renametest renametest2
>    Renamed "renametest" to "renametest2" in volume group "myvg"
>    Unable to rename device node from 'myvg-renametest' to 'dmivg-renametest2'

Have you been changing this by hand ?
It's not clear from where  dmivg name could be taken ?



> asterix:lvm2# ls -l /dev/myvg/renametest2
> lrwxrwxrwx 1 root root 29 Aug 27 15:24 /dev/myvg/renametest2 ->
> /dev/mapper/dmivg-renametest2
> asterix:lvm2# ls -l /dev/mapper/myvg-renametest2
> brw------- 1 root root 252, 26 Aug 27 15:24 /dev/mapper/myvg-renametest2
> asterix:lvm2# ls -l /dev/dm-26
> brw-rw---- 1 root disk 252, 26 Aug 27 15:24 /dev/dm-26
>
> Now this device exist as /dev/dm-26 _and_ as /dev/mapper/myvg-renametest2
>


Please reproduce your problem with upstream build and post a full -vvvv trace.
(eventually open rhbz http://bugzilla.redhat.com/ with attachments).

Debian is unfortunately putting some non-upstream extensions and it's not 
quite clear how they are influencing things here. Since rename operations 
needs tight cooperation with udev.

Also check your lvm.conf for:

obtain_device_list_from_udev = 1
udev_sync = 1
udev_rules = 1
verify_udev_operations = 0

Zdenek


