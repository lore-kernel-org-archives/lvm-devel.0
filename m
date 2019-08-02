From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Fri, 2 Aug 2019 19:54:03 +0530
Subject: lvmcache lv destroy with no flush
In-Reply-To: <93895828-a482-7729-bf7e-132afd4bf767@redhat.com>
References: <5d426f7f.1c69fb81.24900.f111@mx.google.com>
	<99f6e920-d920-4ec4-813a-48c5f22ae7f6@redhat.com>
	<5d443e89.1c69fb81.d73bc.00df@mx.google.com>
	<93895828-a482-7729-bf7e-132afd4bf767@redhat.com>
Message-ID: <5d444783.1c69fb81.96e35.3a01@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


? 1.) remove devices from DM table
? dmsetup remove_all
? (or just some selected device - whatever fits...)
? 
? 2.) remove disk singatures of VG
? wipefs -a /dev/sdc
? wipefs -a /dev/nvme0n1
? (or pvremove -ff /dev/sdc /dev/nvme0n1)
? 
? 3.) recreate empty VG from scratch
? vgcreate pxtest /dev/sdc /dev/nvme0n1


myhome$ sudo dmsetup status --target cache
pxtest-pool: 0 20963328 cache 8 40/2048 2048 4096/10220 28 58 0 0 0 0 4096 1 writethrough 2 migration_threshold 2048 cleaner 0 rw -
myhome$ sudo dmsetup remove pxtest-pool
myhome$
myhome$ sudo vgchange -an pxtest
  0 logical volume(s) in volume group "pxtest" now active
myhome$ sudo pvremove -ff /dev/sdc /dev/nvme0n1
Really WIPE LABELS from physical volume "/dev/sdc" of volume group "pxtest" [y/n]? y
  WARNING: Wiping physical volume label from /dev/sdc of volume group "pxtest"
  Can't open /dev/sdc exclusively - not removing. Mounted filesystem?
Really WIPE LABELS from physical volume "/dev/nvme0n1" of volume group "pxtest" [y/n]? y
  WARNING: Wiping physical volume label from /dev/nvme0n1 of volume group "pxtest"
  Can't open /dev/nvme0n1 exclusively - not removing. Mounted filesystem?
myhome$
myhome$ sudo wipefs -a /dev/sdc /dev/nvme0n1
wipefs: error: /dev/sdc: probing initialization failed: Device or resource busy
myhome$


Doesn?t seem to work, there are still exclusive references on the drive held by lvm!
Any other way out?

LN

Sent from Mail for Windows 10

From: Zdenek Kabelac
Sent: Friday, August 2, 2019 7:21 PM
To: Lakshmi Narasimhan Sundararajan; LVM2 development
Subject: Re: [lvm-devel] lvmcache lv destroy with no flush

Dne 02. 08. 19 v 15:45 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Zdenek,
> 
> Thank you for your email.
> 
>   * If you know you are going to destroy whole VG - you can simply make sure,
>   * there is no running? LV - and just recreate? PV/VG from scratch - certainly
>   * faster them removing i.e.? thousand of LVs individually one-by-one which
>   * is what will happen with lvremove/vgremove command ATM.
> 
> I tried to follow you for accelerated removal? did I interpret you correctly? 
> I though hit the cache sync stuck issue. Please clarify what needs to change 
> below. I see still cache flush happens while removing the vg.
> 
> myhome$ sudo vgcreate pxtest /dev/sdc /dev/nvme0n1
> 
>  ? Volume group "pxtest" successfully created
> 
> myhome$
> 
> myhome$ sudo lvcreate -n cache --type cache-pool -l 100%pvs pxtest /dev/nvme0n1
> 
>  ? Logical volume "cache" created.
> 
> myhome$ sudo lvcreate -n pool --type cache --cachepool pxtest/cache -l 100%pvs 
> pxtest /dev/sdc
> 
>  ? Logical volume "pool" created.
> 
> Myhome$
> 
> myhome$ sudo lvs pxtest
> 
>  ? LV?? VG???? Attr?????? LSize? Pool??? Origin?????? Data%? Meta%? Move Log 
> Cpy%Sync Convert
> 
>  ? pool pxtest Cwi---C--- 10.00g [cache] [pool_corig]
> 
> myhome$
> 
> myhome$ sudo vgchange -an pxtest
> 
>  ? 0 logical volume(s) in volume group "pxtest" now active
> 
> myhome$ sudo vgremove -ff pxtest
> 
>  ? 4096 blocks must still be flushed.
> 
>  ? 4096 blocks must still be flushed.
> 
>  ? 4096 blocks must still be flushed.
> 
>  ? 4096 blocks must still be flushed.
> 
> ^C
> 

1.) remove devices from DM table
dmsetup remove_all
(or just some selected device - whatever fits...)

2.) remove disk singatures of VG
wipefs -a /dev/sdc
wipefs -a /dev/nvme0n1
(or pvremove -ff /dev/sdc /dev/nvme0n1)

3.) recreate empty VG from scratch
vgcreate pxtest /dev/sdc /dev/nvme0n1


Although I'm not quite sure this is what you really want :) - it's more or 
less idea for quicker testing - not something for presering data.


Regards

Zdenek

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190802/22a6c56d/attachment.htm>
