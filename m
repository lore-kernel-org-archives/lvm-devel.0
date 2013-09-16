From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 16 Sep 2013 16:34:41 -0400 (EDT)
Subject: [PATCH] remove device on close
In-Reply-To: <20130916194530.GA3513@redhat.com>
References: <alpine.LRH.2.02.1309161535340.9077@file01.intranet.prod.int.rdu2.redhat.com>
	<20130916194530.GA3513@redhat.com>
Message-ID: <alpine.LRH.2.02.1309161634070.18672@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Mon, 16 Sep 2013, Mike Snitzer wrote:

> On Mon, Sep 16 2013 at  3:41pm -0400,
> Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > Hi
> > 
> > I placed the patches for deferred removal at 
> > http://people.redhat.com/mpatocka/patches/kernel/deferred-remove/
> 
> Please post the kernel patch to dm-devel so it is easier for people to
> review/comment.  It also enables the patch to be tracked via patchwork.
> 
> Thanks,
> Mike

Here it is.

Mikulas

---

dm: deferred remove

This patch introduces the functionality of deferred remove - if a device
mapper device is open, it is scheduled to be deleted on close.

The deferred remove functionality is enabled by setting the flag
DM_DEFERRED_REMOVE in the ioctl structure on DM_DEV_REMOVE or
DM_REMOVE_ALL ioctl.

On return from DM_DEV_REMOVE, the flag DM_DEFERRED_REMOVE indicates if the
device was removed immediatelly or flagged to be removed on close - if the
flag is clear, the device was removed.

On return from DM_DEV_STATUS and other ioctls, the flag DM_DEFERRED_REMOVE
is set if the device is scheduled to be removed on close.

A device that is scheduled to be delete can be revived using the message
"@cancel_deferred_remove". This message clear the DMF_DEFERRED_REMOVE so
that the device won't be deleted on close.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 drivers/md/dm-ioctl.c         |   35 +++++++++++++++++++++++++-----
 drivers/md/dm.c               |   48 +++++++++++++++++++++++++++++++++++++-----
 drivers/md/dm.h               |   13 ++++++++++-
 include/uapi/linux/dm-ioctl.h |   14 ++++++++++++
 4 files changed, 98 insertions(+), 12 deletions(-)

Index: linux-3.11.1-fast/include/uapi/linux/dm-ioctl.h
===================================================================
--- linux-3.11.1-fast.orig/include/uapi/linux/dm-ioctl.h	2013-09-16 21:15:10.000000000 +0200
+++ linux-3.11.1-fast/include/uapi/linux/dm-ioctl.h	2013-09-16 21:15:26.000000000 +0200
@@ -341,4 +341,18 @@ enum {
  */
 #define DM_DATA_OUT_FLAG		(1 << 16) /* Out */
 
+/*
+ * Remove the device when it is closed.
+ *
+ * This flag may be set on DM_DEV_REMOVE or DM_REMOVE_ALL to indicate that
+ * the device should be remove on close if it is open.
+ *
+ * On return from DM_DEV_REMOVE, this flag indicates that the device was not
+ * removed because it was open, but it is scheduled to be removed on close.
+ *
+ * When this flag is returned in DM_DEV_STATUS or other ioctls, it indicates
+ * that the device is scheduled to be removed on close.
+ */
+#define DM_DEFERRED_REMOVE		(1 << 17) /* In/Out */
+
 #endif				/* _LINUX_DM_IOCTL_H */
Index: linux-3.11.1-fast/drivers/md/dm-ioctl.c
===================================================================
--- linux-3.11.1-fast.orig/drivers/md/dm-ioctl.c	2013-09-16 21:15:11.000000000 +0200
+++ linux-3.11.1-fast/drivers/md/dm-ioctl.c	2013-09-16 21:15:26.000000000 +0200
@@ -57,7 +57,7 @@ struct vers_iter {
 static struct list_head _name_buckets[NUM_BUCKETS];
 static struct list_head _uuid_buckets[NUM_BUCKETS];
 
-static void dm_hash_remove_all(int keep_open_devices);
+static void dm_hash_remove_all(bool keep_open_devices, bool mark_deferred, bool only_deferred);
 
 /*
  * Guards access to both hash tables.
@@ -86,7 +86,7 @@ static int dm_hash_init(void)
 
 static void dm_hash_exit(void)
 {
-	dm_hash_remove_all(0);
+	dm_hash_remove_all(false, false, false);
 }
 
 /*-----------------------------------------------------------------
@@ -276,7 +276,7 @@ static struct dm_table *__hash_remove(st
 	return table;
 }
 
-static void dm_hash_remove_all(int keep_open_devices)
+static void dm_hash_remove_all(bool keep_open_devices, bool mark_deferred, bool only_deferred)
 {
 	int i, dev_skipped;
 	struct hash_cell *hc;
@@ -293,7 +293,7 @@ retry:
 			md = hc->md;
 			dm_get(md);
 
-			if (keep_open_devices && dm_lock_for_deletion(md)) {
+			if (keep_open_devices && dm_lock_for_deletion(md, mark_deferred, only_deferred)) {
 				dm_put(md);
 				dev_skipped++;
 				continue;
@@ -450,6 +450,11 @@ static struct mapped_device *dm_hash_ren
 	return md;
 }
 
+void dm_deferred_remove(void)
+{
+	dm_hash_remove_all(true, false, true);
+}
+
 /*-----------------------------------------------------------------
  * Implementation of the ioctl commands
  *---------------------------------------------------------------*/
@@ -461,7 +466,7 @@ typedef int (*ioctl_fn)(struct dm_ioctl 
 
 static int remove_all(struct dm_ioctl *param, size_t param_size)
 {
-	dm_hash_remove_all(1);
+	dm_hash_remove_all(true, !!(param->flags & DM_DEFERRED_REMOVE), false);
 	param->data_size = 0;
 	return 0;
 }
@@ -683,6 +688,9 @@ static void __dev_status(struct mapped_d
 	if (dm_suspended_md(md))
 		param->flags |= DM_SUSPEND_FLAG;
 
+	if (dm_test_deferred_remove_flag(md))
+		param->flags |= DM_DEFERRED_REMOVE;
+
 	param->dev = huge_encode_dev(disk_devt(disk));
 
 	/*
@@ -832,8 +840,13 @@ static int dev_remove(struct dm_ioctl *p
 	/*
 	 * Ensure the device is not open and nothing further can open it.
 	 */
-	r = dm_lock_for_deletion(md);
+	r = dm_lock_for_deletion(md, !!(param->flags & DM_DEFERRED_REMOVE), false);
 	if (r) {
+		if (r == -EBUSY && param->flags & DM_DEFERRED_REMOVE) {
+			up_write(&_hash_lock);
+			dm_put(md);
+			return 0;
+		}
 		DMDEBUG_LIMIT("unable to remove open device %s", hc->name);
 		up_write(&_hash_lock);
 		dm_put(md);
@@ -848,6 +861,8 @@ static int dev_remove(struct dm_ioctl *p
 		dm_table_destroy(t);
 	}
 
+	param->flags &= ~DM_DEFERRED_REMOVE;
+
 	if (!dm_kobject_uevent(md, KOBJ_REMOVE, param->event_nr))
 		param->flags |= DM_UEVENT_GENERATED_FLAG;
 
@@ -1469,6 +1484,14 @@ static int message_for_md(struct mapped_
 	if (**argv != '@')
 		return 2; /* no '@' prefix, deliver to target */
 
+	if (!strcasecmp(argv[0], "@cancel_deferred_remove")) {
+		if (argc != 1) {
+			DMERR("Invalid arguments for @cancel_deferred_remove");
+			return -EINVAL;
+		}
+		return dm_cancel_deferred_remove(md);
+	}
+
 	r = dm_stats_message(md, argc, argv, result, maxlen);
 	if (r < 2)
 		return r;
Index: linux-3.11.1-fast/drivers/md/dm.c
===================================================================
--- linux-3.11.1-fast.orig/drivers/md/dm.c	2013-09-16 21:15:11.000000000 +0200
+++ linux-3.11.1-fast/drivers/md/dm.c	2013-09-16 21:15:26.000000000 +0200
@@ -49,6 +49,11 @@ static unsigned int _major = 0;
 static DEFINE_IDR(_minor_idr);
 
 static DEFINE_SPINLOCK(_minor_lock);
+
+static void do_deferred_remove(struct work_struct *w);
+
+static DECLARE_WORK(deferred_remove_work, do_deferred_remove);
+
 /*
  * For bio-based dm.
  * One of these is allocated per bio.
@@ -116,6 +121,7 @@ EXPORT_SYMBOL_GPL(dm_get_rq_mapinfo);
 #define DMF_DELETING 4
 #define DMF_NOFLUSH_SUSPENDING 5
 #define DMF_MERGE_IS_OPTIONAL 6
+#define DMF_DEFERRED_REMOVE 7
 
 /*
  * A dummy definition to make RCU happy.
@@ -254,6 +260,8 @@ out_free_io_cache:
 
 static void local_exit(void)
 {
+	flush_scheduled_work();
+
 	kmem_cache_destroy(_rq_tio_cache);
 	kmem_cache_destroy(_io_cache);
 	unregister_blkdev(_major, _name);
@@ -359,7 +367,11 @@ static void dm_blk_close(struct gendisk 
 
 	spin_lock(&_minor_lock);
 
-	atomic_dec(&md->open_count);
+	if (atomic_dec_and_test(&md->open_count)) {
+		if (test_bit(DMF_DEFERRED_REMOVE, &md->flags)) {
+			schedule_work(&deferred_remove_work);
+		}
+	}
 	dm_put(md);
 
 	spin_unlock(&_minor_lock);
@@ -373,22 +385,43 @@ int dm_open_count(struct mapped_device *
 /*
  * Guarantees nothing is using the device before it's deleted.
  */
-int dm_lock_for_deletion(struct mapped_device *md)
+int dm_lock_for_deletion(struct mapped_device *md, bool mark_deferred, bool only_deferred)
 {
 	int r = 0;
 
 	spin_lock(&_minor_lock);
 
-	if (dm_open_count(md))
+	if (dm_open_count(md)) {
 		r = -EBUSY;
-	else
-		set_bit(DMF_DELETING, &md->flags);
+		if (mark_deferred)
+			set_bit(DMF_DEFERRED_REMOVE, &md->flags);
+	} else {
+		if (only_deferred && !test_bit(DMF_DEFERRED_REMOVE, &md->flags))
+			r = -EEXIST;
+		else
+			set_bit(DMF_DELETING, &md->flags);
+	}
 
 	spin_unlock(&_minor_lock);
 
 	return r;
 }
 
+int dm_cancel_deferred_remove(struct mapped_device *md)
+{
+	int r = 0;
+	spin_lock(&_minor_lock);
+	if (test_bit(DMF_DELETING, &md->flags)) r = -EBUSY;
+	else clear_bit(DMF_DEFERRED_REMOVE, &md->flags);
+	spin_unlock(&_minor_lock);
+	return r;
+}
+
+static void do_deferred_remove(struct work_struct *w)
+{
+	dm_deferred_remove();
+}
+
 sector_t dm_get_size(struct mapped_device *md)
 {
 	return get_capacity(md->disk);
@@ -2845,6 +2878,11 @@ int dm_suspended_md(struct mapped_device
 	return test_bit(DMF_SUSPENDED, &md->flags);
 }
 
+int dm_test_deferred_remove_flag(struct mapped_device *md)
+{
+	return test_bit(DMF_DEFERRED_REMOVE, &md->flags);
+}
+
 int dm_suspended(struct dm_target *ti)
 {
 	return dm_suspended_md(dm_table_get_md(ti->table));
Index: linux-3.11.1-fast/drivers/md/dm.h
===================================================================
--- linux-3.11.1-fast.orig/drivers/md/dm.h	2013-09-16 21:15:11.000000000 +0200
+++ linux-3.11.1-fast/drivers/md/dm.h	2013-09-16 21:15:26.000000000 +0200
@@ -118,6 +118,16 @@ int dm_deleting_md(struct mapped_device 
 int dm_suspended_md(struct mapped_device *md);
 
 /*
+ * Test if the device is scheduled for deferred remove.
+ */
+int dm_test_deferred_remove_flag(struct mapped_device *md);
+
+/*
+ * Try to remove devices marked for deferred removal.
+ */
+void dm_deferred_remove(void);
+
+/*
  * The device-mapper can be driven through one of two interfaces;
  * ioctl or filesystem, depending which patch you have applied.
  */
@@ -147,7 +157,8 @@ void dm_stripe_exit(void);
 void dm_destroy(struct mapped_device *md);
 void dm_destroy_immediate(struct mapped_device *md);
 int dm_open_count(struct mapped_device *md);
-int dm_lock_for_deletion(struct mapped_device *md);
+int dm_lock_for_deletion(struct mapped_device *md, bool mark_deferred, bool only_deferred);
+int dm_cancel_deferred_remove(struct mapped_device *md);
 int dm_request_based(struct mapped_device *md);
 sector_t dm_get_size(struct mapped_device *md);
 struct dm_stats *dm_get_stats(struct mapped_device *md);


