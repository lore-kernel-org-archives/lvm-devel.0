From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 2 Aug 2019 15:50:56 +0200
Subject: lvmcache lv destroy with no flush
In-Reply-To: <5d443e89.1c69fb81.d73bc.00df@mx.google.com>
References: <5d426f7f.1c69fb81.24900.f111@mx.google.com>
	<99f6e920-d920-4ec4-813a-48c5f22ae7f6@redhat.com>
	<5d443e89.1c69fb81.d73bc.00df@mx.google.com>
Message-ID: <93895828-a482-7729-bf7e-132afd4bf767@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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


