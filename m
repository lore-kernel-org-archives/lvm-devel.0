From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 18 Sep 2013 19:40:42 -0400 (EDT)
Subject: [PATCH] dm-snapshot: fix performance degradation due to small hash size (was: Snapshotted device gets slow)
In-Reply-To: <kk5txhi7ss8.fsf@brer.local.valinux.co.jp>
References: <kk5txhi7ss8.fsf@brer.local.valinux.co.jp>
Message-ID: <alpine.LRH.2.02.1309181938330.2927@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Wed, 18 Sep 2013, MINOURA Makoto / ?? ? wrote:

> 
> (I'm not on this list; please Cc me)
> 
> We are observing a problem that writes to a (thick) snapshot origin
> device get way slooower on RHEL 6.3 than on EL 6.2 as the cow device
> is consumed.  I tracked down the problem and found that the cause was
> the commit f1aabd5c60ad721609e5d781e45c234ba62fe355 (Set delay_resume_
> if_new on deptree snapshot origin.).
> 
> Here's detailed description.
> 
> On 6.3 the size of the exception hashes are too small; the lower bound
> 64 for both completed and pending.
> 
> # lvcreate -n test -L 240g tank
>   Logical volume "test" created
> # lvcreate -s -n snap -l 100%FREE tank/test
>   Logical volume "snap" created
> # lvs /dev/tank
>   LV   VG   Attr     LSize   Pool Origin Data%  Move Log Copy%  Convert
>   snap tank swi-a-s- 207.13g      test     0.00                        
>   test tank owi-a-s- 240.00g
> # dmsetup ls | grep tank
> tank-snap-cow	(253:6)
> tank-snap	(253:4)
> tank-test	(253:3)
> tank-test-real	(253:5)
> # crash
> ....
> (crash) print _origins[5]
> $3 = {
>   next = 0xffff880297977c08, 
>   prev = 0xffff880297977c08
> }
> crash> struct -ox origin.hash_list
> struct origin {
>    [0x8] struct list_head hash_list;
> }
> crash> print *(struct origin*)0xffff880297977c00
> $4 = {
>   bdev = 0xffff880297519c80, 
>   hash_list = {
>     next = 0xffff880293c1b050, 
>     prev = 0xffff880293c1b050
>   }, 
>   snapshots = {
>     next = 0xffff880293456a40, 
>     prev = 0xffff880293456a40
>   }
> }
> crash> struct -ox dm_snapshot.list
> struct dm_snapshot {
>    [0x40] struct list_head list;
> }
> crash> print ((struct dm_snapshot*)0xffff880293456a00)->origin->name
> $5 = "253:5\000\000\000\002\000\000\000st-a"
> crash> print ((struct dm_snapshot*)0xffff880293456a00)->complete
> $6 = {
>   hash_mask = 63,				<=== !!
>   hash_shift = 8, 
>   table = 0xffffc900033ea000
> }
> crash> print ((struct dm_snapshot*)0xffff880293456a00)->pending
> $7 = {
>   hash_mask = 63,				<=== !!
>   hash_shift = 0, 
>   table = 0xffffc900033ed000
> }
> 
> hash_mask+1 is the size of the hash. On EL6.2 they are 131072 and
> 16384 respectively.
> 
> They are initialized at dm_ctl_ioctl()=>table_load()=>snapshot_ctr()
> =>init_hash_tables() from the size of the cow device or the origin
> device:
> 
> static int init_hash_tables(struct dm_snapshot *s)
> {
> 	[snip]
> 
> 	hash_size = min(origin_dev_size, cow_dev_size) >> s->store->chunk_shift;
> 	hash_size = min(hash_size, max_buckets);
> 
> 	if (hash_size < 64)
> 		hash_size = 64;
> 	hash_size = rounddown_pow_of_two(hash_size);
> 
> Here, the origin device is not resumed yet (by that commit) and it's
> size is 0.  Thus the hash_size is 0 and clipped at the lower bound 64.
> 
> 
> I'm not familiar with the device-mapper code and am not sure
> that reverting the patch is the right thing to do, but I
> think the current situation is not intended.
> 
> Thanks,
> 
> -- 
> Minoura Makoto <minoura@valinux.co.jp>
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 

I'd fix it with this.

Mikulas

---

dm-snapshot: fix performance degradation due to small hash size

LVM, since version 2.02.96, creates origin with zero size, then loads the
snapshot driver and then loads the origin. Consequently, the snapshot
driver sees the origin size zero and sets the hash size to the lower bound
64. Such small hash table causes performance degradation.

This patch changes it so that the hash size is determined by the size of
snapshot volume, not minimum of origin and snapshot size. It doesn't make
sense to set the snapshot size significantly larger than the origin size,
so we do not need to take origin size into account when calculating the
hash size.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Cc: stable at kernel.org

---
 drivers/md/dm-snap.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Index: linux-3.10.12-fast/drivers/md/dm-snap.c
===================================================================
--- linux-3.10.12-fast.orig/drivers/md/dm-snap.c	2013-09-19 01:21:31.000000000 +0200
+++ linux-3.10.12-fast/drivers/md/dm-snap.c	2013-09-19 01:33:55.000000000 +0200
@@ -725,17 +725,16 @@ static int calc_max_buckets(void)
  */
 static int init_hash_tables(struct dm_snapshot *s)
 {
-	sector_t hash_size, cow_dev_size, origin_dev_size, max_buckets;
+	sector_t hash_size, cow_dev_size, max_buckets;
 
 	/*
 	 * Calculate based on the size of the original volume or
 	 * the COW volume...
 	 */
 	cow_dev_size = get_dev_size(s->cow->bdev);
-	origin_dev_size = get_dev_size(s->origin->bdev);
 	max_buckets = calc_max_buckets();
 
-	hash_size = min(origin_dev_size, cow_dev_size) >> s->store->chunk_shift;
+	hash_size = cow_dev_size >> s->store->chunk_shift;
 	hash_size = min(hash_size, max_buckets);
 
 	if (hash_size < 64)


