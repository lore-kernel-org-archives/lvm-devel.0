From: David Teigland <teigland@sourceware.org>
Date: Fri, 25 May 2018 14:09:38 -0400
Subject: master - scan: refresh paths and retry open
Message-ID: <201805251809.w4PI9cm0032050@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=28c8e95d197bf512a39b561281162ff4d93a598e
Commit:        28c8e95d197bf512a39b561281162ff4d93a598e
Parent:        9a730233c935085ec5de9440796daa0d416ba4ba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 11:14:12 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 25 13:09:07 2018 -0500

scan: refresh paths and retry open

If scanning fails to open any devices, refresh the
device paths in dev cache, and retry the opens.
---
 lib/device/dev-cache.c              |    2 +
 lib/label/label.c                   |  115 +++++++++++++++++++++++++++++++---
 test/shell/pvcreate-operation-md.sh |    6 ++
 3 files changed, 112 insertions(+), 11 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 975fc12..dd01558 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1079,6 +1079,8 @@ static int _insert(const char *path, const struct stat *info,
 void dev_cache_scan(void)
 {
 	struct dir_list *dl;
+	
+	log_debug_devs("Creating list of system devices.");
 
 	_cache.has_scanned = 1;
 
diff --git a/lib/label/label.c b/lib/label/label.c
index b9227f5..8ecaa61 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -427,7 +427,11 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 
 static int _scan_dev_open(struct device *dev)
 {
+	struct dm_list *name_list;
+	struct dm_str_list *name_sl;
 	const char *name;
+	struct stat sbuf;
+	int retried = 0;
 	int flags = 0;
 	int fd;
 
@@ -435,20 +439,30 @@ static int _scan_dev_open(struct device *dev)
 		return 0;
 
 	if (dev->flags & DEV_IN_BCACHE) {
-		log_error("scan_dev_open %s DEV_IN_BCACHE already set", dev_name(dev));
+		/* Shouldn't happen */
+		log_error("Device open %s has DEV_IN_BCACHE already set", dev_name(dev));
 		dev->flags &= ~DEV_IN_BCACHE;
 	}
 
 	if (dev->bcache_fd > 0) {
-		log_error("scan_dev_open %s already open with fd %d",
+		/* Shouldn't happen */
+		log_error("Device open %s already open with fd %d",
 			  dev_name(dev), dev->bcache_fd);
 		return 0;
 	}
 
-	if (!(name = dev_name_confirmed(dev, 1))) {
-		log_error("scan_dev_open %s no name", dev_name(dev));
+	/*
+	 * All the names for this device (major:minor) are kept on
+	 * dev->aliases, the first one is the primary/preferred name.
+	 */
+	if (!(name_list = dm_list_first(&dev->aliases))) {
+		/* Shouldn't happen */
+		log_error("Device open %s %d:%d has no path names.",
+			  dev_name(dev), (int)MAJOR(dev->dev), (int)MINOR(dev->dev));
 		return 0;
 	}
+	name_sl = dm_list_item(name_list, struct dm_str_list);
+	name = name_sl->str;
 
 	flags |= O_RDWR;
 	flags |= O_DIRECT;
@@ -457,6 +471,8 @@ static int _scan_dev_open(struct device *dev)
 	if (dev->flags & DEV_BCACHE_EXCL)
 		flags |= O_EXCL;
 
+retry_open:
+
 	fd = open(name, flags, 0777);
 
 	if (fd < 0) {
@@ -464,7 +480,48 @@ static int _scan_dev_open(struct device *dev)
 			log_error("Can't open %s exclusively.  Mounted filesystem?",
 				  dev_name(dev));
 		} else {
-			log_error("scan_dev_open %s failed errno %d", dev_name(dev), errno);
+			int major, minor;
+
+			/*
+			 * Shouldn't happen, if it does, print stat info to help figure
+			 * out what's wrong.
+			 */
+
+			major = (int)MAJOR(dev->dev);
+			minor = (int)MINOR(dev->dev);
+
+			log_error("Device open %s %d:%d failed errno %d", name, major, minor, errno);
+
+			if (stat(name, &sbuf)) {
+				log_debug_devs("Device open %s %d:%d stat failed errno %d",
+					       name, major, minor, errno);
+			} else if (sbuf.st_rdev != dev->dev) {
+				log_debug_devs("Device open %s %d:%d stat %d:%d does not match.",
+					       name, major, minor,
+					       (int)MAJOR(sbuf.st_rdev), (int)MINOR(sbuf.st_rdev));
+			}
+
+			/*
+			 * FIXME: do we want to try opening this device using
+			 * one of the other path aliases for the same
+			 * major:minor from dev->aliases?  We could iterate
+			 * through those aliases to try opening each of them to
+			 * find one that works.  What are the consequences of
+			 * using a different, non-preferred alias to a device?
+			 */
+
+			if (!retried) {
+				/*
+				 * FIXME: remove this, the theory for this retry is that
+				 * there may be a udev race that we can sometimes mask by
+				 * retrying.  This is here until we can figure out if it's
+				 * needed and if so fix the real problem.
+				 */
+				usleep(5000);
+				log_debug_devs("Device open %s retry", dev_name(dev));
+				retried = 1;
+				goto retry_open;
+			}
 		}
 		return 0;
 	}
@@ -509,9 +566,10 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 {
 	struct dm_list wait_devs;
 	struct dm_list done_devs;
+	struct dm_list reopen_devs;
 	struct device_list *devl, *devl2;
 	struct block *bb;
-	int scan_open_errors = 0;
+	int retried_open = 0;
 	int scan_read_errors = 0;
 	int scan_process_errors = 0;
 	int scan_failed_count = 0;
@@ -524,6 +582,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 
 	dm_list_init(&wait_devs);
 	dm_list_init(&done_devs);
+	dm_list_init(&reopen_devs);
 
 	log_debug_devs("Scanning %d devices for VG info", dm_list_size(devs));
 
@@ -547,9 +606,7 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 			if (!_scan_dev_open(devl->dev)) {
 				log_debug_devs("Scan failed to open %s.", dev_name(devl->dev));
 				dm_list_del(&devl->list);
-				dm_list_add(&done_devs, &devl->list);
-				scan_open_errors++;
-				scan_failed_count++;
+				dm_list_add(&reopen_devs, &devl->list);
 				continue;
 			}
 		}
@@ -612,8 +669,44 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 	if (!dm_list_empty(devs))
 		goto scan_more;
 
-	log_debug_devs("Scanned devices: open errors %d read errors %d process errors %d",
-			scan_open_errors, scan_read_errors, scan_process_errors);
+	/*
+	 * We're done scanning all the devs.  If we failed to open any of them
+	 * the first time through, refresh device paths and retry.  We failed
+	 * to open the devs on the reopen_devs list.
+	 *
+	 * FIXME: it's not clear if or why this helps.
+	 *
+	 * FIXME: should we delete the first path name from dev->aliases that
+	 * we failed to open the first time before retrying?  If that path
+	 * still exists on the system, dev_cache_scan should put it back, but
+	 * if it doesn't exist we don't want to try using it again.
+	 */
+	if (!dm_list_empty(&reopen_devs)) {
+		if (retried_open) {
+			/* Don't try again. */
+			scan_failed_count += dm_list_size(&reopen_devs);
+			dm_list_splice(&done_devs, &reopen_devs);
+			goto out;
+		}
+		retried_open = 1;
+
+		/*
+		 * This will search the system's /dev for new path names and
+		 * could help us reopen the device if it finds a new preferred
+		 * path name for this dev's major:minor.  It does that by
+		 * inserting a new preferred path name on dev->aliases.  open
+		 * uses the first name from that list.
+		 */
+		log_debug_devs("Scanning refreshing device paths.");
+		dev_cache_scan();
+
+		/* Put devs that failed to open back on the original list to retry. */
+		dm_list_splice(devs, &reopen_devs);
+		goto scan_more;
+	}
+out:
+	log_debug_devs("Scanned devices: read errors %d process errors %d failed %d",
+			scan_read_errors, scan_process_errors, scan_failed_count);
 
 	if (failed)
 		*failed = scan_failed_count;
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 359113d..f534785 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -90,6 +90,12 @@ EOF
 	maj=$(($(stat -L --printf=0x%t "${mddev}p1")))
 	min=$(($(stat -L --printf=0x%T "${mddev}p1")))
 
+	ls /sys/dev/block/$maj:$min/
+	ls /sys/dev/block/$maj:$min/holders/
+	cat /sys/dev/block/$maj:$min/dev
+	cat /sys/dev/block/$maj:$min/stat
+	cat /sys/dev/block/$maj:$min/size
+
 	sysfs_alignment_offset="/sys/dev/block/$maj:$min/alignment_offset"
 	[ -f "$sysfs_alignment_offset" ] && \
 		alignment_offset=$(< "$sysfs_alignment_offset") || \


