From: Oliver Rath <rath@mglug.de>
Date: Tue, 27 Aug 2013 15:35:20 +0200
Subject: example [was Re: thinpool-block-device exists twice after renaming]
In-Reply-To: <521CA389.504@mglug.de>
References: <521CA389.504@mglug.de>
Message-ID: <521CAB18.8020205@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Here an example for recreating the situation:


asterix:lvm2# lvcreate --name renametest -V 100M -T myvg/mythinpool
  Logical volume "renametest" created
asterix:lvm2# lvrename /dev/myvg/renametest renametest2
  Renamed "renametest" to "renametest2" in volume group "myvg"
  Unable to rename device node from 'myvg-renametest' to 'dmivg-renametest2'
asterix:lvm2# ls -l /dev/myvg/renametest2
lrwxrwxrwx 1 root root 29 Aug 27 15:24 /dev/myvg/renametest2 ->
/dev/mapper/myvg-renametest2
asterix:lvm2# ls -l /dev/mapper/myvg-renametest2
brw------- 1 root root 252, 26 Aug 27 15:24 /dev/mapper/myvg-renametest2
asterix:lvm2# ls -l /dev/dm-26
brw-rw---- 1 root disk 252, 26 Aug 27 15:24 /dev/dm-26

Now this device exist as /dev/dm-26 _and_ as /dev/mapper/myvg-renametest2

Tfh!
Oliver

Am 27.08.2013 15:03, schrieb Oliver Rath:
> Hi list,
> 
> Im using here lvm2 (2.02.99) with Ubuntu 12.04 wiht LTS-Kernel-Stack
> (3.8er Kernel).
> 
> I ecreated a volume group an in this volume group a thinpool. Then i
> created thinpool devices from this pool. So far, so fine
> 
> The thinpool devices are links in /dev/myvg/tp-device-1 ->
> /dev/mapper/myvg-tp-device-1.
> 
> These were also links to /dev/dm-X devices.
> 
> NOW i rename a tp-device. The result is en error "cannot rename ..", BUT
> in /dev/myvg/ the links are renamed and pointing - which looks strange
> to me - to block-devices in /dev/mapper/ instead of links.
> 
> These block-devices have the same maior/minor-ids at hte /dev/dm-X
> devices, so now the renamed block-device exists twice.
> 
> Any ideas to solve this?
> 
> Regards
> Oliver
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 

--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel


