From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 2 Aug 2019 14:44:12 +0200
Subject: lvmcache lv destroy with no flush
In-Reply-To: <5d426f7f.1c69fb81.24900.f111@mx.google.com>
References: <5d426f7f.1c69fb81.24900.f111@mx.google.com>
Message-ID: <99f6e920-d920-4ec4-813a-48c5f22ae7f6@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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


