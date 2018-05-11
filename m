From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 May 2018 13:50:37 -0400
Subject: master - dev_cache: drop open_list
Message-ID: <201805111750.w4BHobts013442@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbb8040456a07a0c9076d45a8eee5e5f7fcde0ec
Commit:        bbb8040456a07a0c9076d45a8eee5e5f7fcde0ec
Parent:        43620138726da124f5eb58c9347cba8b582271ed
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 11 11:59:44 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 11 12:47:56 2018 -0500

dev_cache: drop open_list

devices are now held open only in bcache,
so drop the dev_cache list of open devices
which is unused.
---
 lib/cache/lvmcache.c    |    1 -
 lib/device/dev-cache.c  |    1 -
 lib/device/dev-io.c     |   16 ----------------
 lib/device/device.h     |    2 --
 lib/label/label.c       |    4 ----
 lib/metadata/metadata.c |    2 --
 lib/misc/lvm-exec.c     |    1 -
 tools/polldaemon.c      |    8 --------
 tools/toollib.c         |    1 -
 9 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 290d733..3f9e6fd 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -643,7 +643,6 @@ void lvmcache_unlock_vgname(const char *vgname)
 
 	/* FIXME Do this per-VG */
 	if (strcmp(vgname, VG_GLOBAL) && !--_vgs_locked) {
-		dev_close_all();
 		dev_size_seqno_inc(); /* invalidate all cached dev sizes */
 	}
 }
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 15d4cdf..975fc12 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -73,7 +73,6 @@ static void _dev_init(struct device *dev, int max_error_count)
 	dev->ext.src = DEV_EXT_NONE;
 
 	dm_list_init(&dev->aliases);
-	dm_list_init(&dev->open_list);
 }
 
 void dev_destroy_file(struct device *dev)
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index cce5a94..903c582 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -53,7 +53,6 @@
 #  endif
 #endif
 
-static DM_LIST_INIT(_open_devices);
 static unsigned _dev_size_seqno = 1;
 
 static const char *_reasons[] = {
@@ -597,8 +596,6 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 	if ((flags & O_CREAT) && !(flags & O_TRUNC))
 		dev->end = lseek(dev->fd, (off_t) 0, SEEK_END);
 
-	dm_list_add(&_open_devices, &dev->open_list);
-
 	log_debug_devs("Opened %s %s%s%s", dev_name(dev),
 		       dev->flags & DEV_OPENED_RW ? "RW" : "RO",
 		       dev->flags & DEV_OPENED_EXCL ? " O_EXCL" : "",
@@ -650,7 +647,6 @@ static void _close(struct device *dev)
 	dev->fd = -1;
 	dev->phys_block_size = -1;
 	dev->block_size = -1;
-	dm_list_del(&dev->open_list);
 
 	log_debug_devs("Closed %s", dev_name(dev));
 
@@ -696,18 +692,6 @@ int dev_close_immediate(struct device *dev)
 	return _dev_close(dev, 1);
 }
 
-void dev_close_all(void)
-{
-	struct dm_list *doh, *doht;
-	struct device *dev;
-
-	dm_list_iterate_safe(doh, doht, &_open_devices) {
-		dev = dm_list_struct_base(doh, struct device, open_list);
-		if (dev->open_count < 1)
-			_close(dev);
-	}
-}
-
 static inline int _dev_is_valid(struct device *dev)
 {
 	return (dev->max_error_count == NO_DEV_ERROR_COUNT_LIMIT ||
diff --git a/lib/device/device.h b/lib/device/device.h
index fd8cbb7..42659cd 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -74,7 +74,6 @@ struct device {
 	unsigned size_seqno;
 	uint64_t size;
 	uint64_t end;
-	struct dm_list open_list;
 	struct dev_ext ext;
 
 	const char *vgid; /* if device is an LV */
@@ -144,7 +143,6 @@ int dev_open_readonly_buffered(struct device *dev);
 int dev_open_readonly_quiet(struct device *dev);
 int dev_close(struct device *dev);
 int dev_close_immediate(struct device *dev);
-void dev_close_all(void);
 int dev_test_excl(struct device *dev);
 
 int dev_fd(struct device *dev);
diff --git a/lib/label/label.c b/lib/label/label.c
index 45acd73..ab040e1 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -975,8 +975,6 @@ int label_scan_open(struct device *dev)
 
 bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 {
-	int ret;
-
 	if (!scan_bcache) {
 		/* Should not happen */
 		log_error("dev_read bcache not set up %s", dev_name(dev));
@@ -1003,8 +1001,6 @@ bool dev_read_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 
 bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 {
-	int ret;
-
 	if (test_mode())
 		return true;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b8f1b97..bfdc4cf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5192,8 +5192,6 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 
 	unlock_vg(cmd, NULL, vg_name);
 
-	dev_close_all();
-
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL))
 		return_NULL;
 
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index 190d426..c3858c4 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -78,7 +78,6 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 	if (!pid) {
 		/* Child */
 		reset_locking();
-		dev_close_all();
 		/* FIXME Fix effect of reset_locking on cache then include this */
 		/* destroy_toolcontext(cmd); */
 		/* FIXME Use execve directly */
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 5b5f57f..020be21 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -134,7 +134,6 @@ static void _sleep_and_rescan_devices(struct cmd_context *cmd, struct daemon_par
 		 */
 		lvmcache_destroy(cmd, 1, 0);
 		label_scan_destroy(cmd);
-		dev_close_all();
 		_nanosleep(parms->interval, 1);
 		lvmcache_label_scan(cmd);
 	}
@@ -530,9 +529,6 @@ static void _lvmpolld_poll_for_all_vgs(struct cmd_context *cmd,
 				_report_progress(cmd, idl->id, lpdp.parms);
 		}
 
-		if (lpdp.parms->interval)
-			dev_close_all();
-
 		_nanosleep(lpdp.parms->interval, 0);
 	}
 
@@ -559,9 +555,6 @@ static int _lvmpoll_daemon(struct cmd_context *cmd, struct poll_operation_id *id
 				    (!parms->aborting && !(r = _report_progress(cmd, id, parms))))
 					break;
 
-				if (parms->interval)
-					dev_close_all();
-
 				_nanosleep(parms->interval, 0);
 			}
 		}
@@ -620,7 +613,6 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 	/* clear lvmcache/bcache/fds from the parent */
 	lvmcache_destroy(cmd, 1, 0);
 	label_scan_destroy(cmd);
-	dev_close_all();
 
 	if (id) {
 		if (!wait_for_single_lv(cmd, id, parms)) {
diff --git a/tools/toollib.c b/tools/toollib.c
index e633cdd..5e5cc51 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -115,7 +115,6 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 			/* FIXME Clean up properly here */
 			_exit(ECMD_FAILED);
 	}
-	dev_close_all();
 
 	return 1;
 }


