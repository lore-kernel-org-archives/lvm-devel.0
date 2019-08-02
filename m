From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Fri, 2 Aug 2019 19:15:44 +0530
Subject: lvmcache lv destroy with no flush
In-Reply-To: <99f6e920-d920-4ec4-813a-48c5f22ae7f6@redhat.com>
References: <5d426f7f.1c69fb81.24900.f111@mx.google.com>
	<99f6e920-d920-4ec4-813a-48c5f22ae7f6@redhat.com>
Message-ID: <5d443e89.1c69fb81.d73bc.00df@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,
Thank you for your email.

? If you know you are going to destroy whole VG - you can simply make sure,
? there is no running  LV - and just recreate  PV/VG from scratch - certainly
? faster them removing i.e.  thousand of LVs individually one-by-one which
? is what will happen with lvremove/vgremove command ATM.

I tried to follow you for accelerated removal? did I interpret you correctly? I though hit the cache sync stuck issue. Please clarify what needs to change below. I see still cache flush happens while removing the vg.

myhome$ sudo vgcreate pxtest /dev/sdc /dev/nvme0n1
  Volume group "pxtest" successfully created
myhome$
myhome$ sudo lvcreate -n cache --type cache-pool -l 100%pvs pxtest /dev/nvme0n1
  Logical volume "cache" created.
myhome$ sudo lvcreate -n pool --type cache --cachepool pxtest/cache -l 100%pvs pxtest /dev/sdc
  Logical volume "pool" created.
Myhome$

myhome$ sudo lvs pxtest
  LV   VG     Attr       LSize  Pool    Origin       Data%  Meta%  Move Log Cpy%Sync Convert
  pool pxtest Cwi---C--- 10.00g [cache] [pool_corig]
myhome$

myhome$ sudo vgchange -an pxtest
  0 logical volume(s) in volume group "pxtest" now active
myhome$ sudo vgremove -ff pxtest
  4096 blocks must still be flushed.
  4096 blocks must still be flushed.
  4096 blocks must still be flushed.
  4096 blocks must still be flushed.
^C
Myhome$

myhome$ sudo dmsetup status pxtest-pool
0 20963328 cache 8 40/2048 2048 4096/10220 28 58 0 0 0 0 4096 1 writethrough 2 migration_threshold 2048 cleaner 0 rw -
myhome$

myhome$ uname -r
4.4.0-131-generic
myhome$ sudo lvm version
  LVM version:     2.02.133(2) (2015-10-30)
  Library version: 1.02.110 (2015-10-30)
  Driver version:  4.34.0
myhome$

Regards
LN
Sent from Mail for Windows 10

From: Zdenek Kabelac
Sent: Friday, August 2, 2019 6:14 PM
To: LVM2 development; Lakshmi Narasimhan Sundararajan
Subject: Re: [lvm-devel] lvmcache lv destroy with no flush

Dne 01. 08. 19 v 6:50 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> 
> A very good day to you all.
> 
> Lets say, there exists a LVM cache LV in writeback mode with lots of dirty blocks.
> 
> How can I destroy this LV without waiting for data sync to finish? This is a 
> tear down operation and there is no necessity for data sync to complete.
> 
> Any operation like lvremove, vgremove etc. all of it wait for the cache sync 
> to complete before tearing down the lv/vg.
> 
> Please let me know if there is a way to accomplish my requirement.


Currently this is not supported on lvm2 side - we usually want to flush cache 
first - since we try to keep logic that lvm2 should be reversible for 1-step back.

So we tend to keep things flushed first.

On the other hand - we do have some 'long wanted' feature - like some smart 
and fast 'accelerated' removal.

i.e. when removing all thin + thin-pool -  skip removing individual thins,
and similar would apply to cache.

These operation would be irreversible - but certainly much faster.....

On the other hand there is usually way quicker workaround -

If you know you are going to destroy whole VG - you can simply make sure,
there is no running  LV - and just recreate  PV/VG from scratch - certainly
faster them removing i.e.  thousand of LVs individually one-by-one which
is what will happen with lvremove/vgremove command ATM.


2nd. though - when the cache-pool is broken/missing - you can always remove 
any LV with  'lvremove -ff'

Regards

Zdenek

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190802/77fa1f79/attachment.htm>
