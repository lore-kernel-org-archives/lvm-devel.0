From: David Teigland <teigland@sourceware.org>
Date: Wed,  6 Apr 2022 17:51:59 +0000 (GMT)
Subject: main - filter: remove unused EAGAIN case and flag
Message-ID: <20220406175159.A96F8385741C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6cb0b44cd2f518ed32c9bef571986d51c775c99b
Commit:        6cb0b44cd2f518ed32c9bef571986d51c775c99b
Parent:        fb7698b0ce47b965db056022cad712a965554f3a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 1 15:06:03 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 6 12:51:34 2022 -0500

filter: remove unused EAGAIN case and flag

The case of filters returning EAGAIN and using the
FILTER_AFTER_SCAN flag is no longer used.
---
 lib/device/dev-cache.c           | 21 +--------------------
 lib/device/dev-luks.c            |  3 ---
 lib/device/dev-md.c              |  6 ------
 lib/device/dev-swap.c            |  3 ---
 lib/device/dev-type.c            |  5 -----
 lib/device/device.h              |  4 ++--
 lib/filters/filter-md.c          |  8 --------
 lib/filters/filter-partitioned.c |  8 --------
 lib/filters/filter-persistent.c  | 20 +++++---------------
 lib/filters/filter-signature.c   |  7 -------
 10 files changed, 8 insertions(+), 77 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 5607beefc..3aaf6a2e5 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1606,18 +1606,6 @@ static struct device *_dev_cache_get(struct cmd_context *cmd, const char *name,
 		return dev;
 
 	ret = f->passes_filter(cmd, f, dev, NULL);
-
-	/*
-	 * This might happen if this function is called before
-	 * filters can do i/o.  I don't think this will happen
-	 * any longer and this EAGAIN case can be removed.
-	 */
-	if (ret == -EAGAIN) {
-		log_debug_devs("dev_cache_get filter deferred %s", dev_name(dev));
-		dev->flags |= DEV_FILTER_AFTER_SCAN;
-		ret = 1;
-	}
-
 	if (!ret) {
 		log_debug_devs("dev_cache_get filter excludes %s", dev_name(dev));
 		return NULL;
@@ -1688,16 +1676,9 @@ struct device *dev_iter_get(struct cmd_context *cmd, struct dev_iter *iter)
 
 		f = iter->filter;
 
-		if (f && !(d->flags & DEV_REGULAR)) {
+		if (f && !(d->flags & DEV_REGULAR))
 			ret = f->passes_filter(cmd, f, d, NULL);
 
-			if (ret == -EAGAIN) {
-				log_debug_devs("get device by iter defer filter %s", dev_name(d));
-				d->flags |= DEV_FILTER_AFTER_SCAN;
-				ret = 1;
-			}
-		}
-
 		if (!f || (d->flags & DEV_REGULAR) || ret)
 			return d;
 	}
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index d8c422519..2434d6291 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -23,9 +23,6 @@ int dev_is_luks(struct cmd_context *cmd, struct device *dev, uint64_t *offset_fo
 	char buf[LUKS_SIGNATURE_SIZE];
 	int ret = -1;
 
-	if (!scan_bcache)
-		return -EAGAIN;
-
 	if (offset_found)
 		*offset_found = 0;
 
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 4debe9e99..fa4ff123f 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -178,12 +178,6 @@ static int _dev_is_md_component_native(struct device *dev, uint64_t *offset_foun
 	uint64_t size, sb_offset = 0;
 	int ret;
 
-	/* i/o layer has not been set up */
-	if (!scan_bcache) {
-		log_error(INTERNAL_ERROR "dev_is_md_component_native requires io layer.");
-		return -1;
-	}
-
 	if (!dev_get_size(dev, &size)) {
 		stack;
 		return -1;
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 1d2a4c9d1..86d67df3c 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -42,9 +42,6 @@ int dev_is_swap(struct cmd_context *cmd, struct device *dev, uint64_t *offset_fo
 	unsigned page;
 	int ret = 0;
 
-	if (!scan_bcache)
-		return -EAGAIN;
-
 	if (!dev_get_size(dev, &size)) {
 		stack;
 		return -1;
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index c67a86fa3..939eb4aeb 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -674,11 +674,6 @@ static int _dev_is_partitioned_native(struct dev_types *dt, struct device *dev)
 {
 	int r;
 
-	if (!scan_bcache) {
-		log_error(INTERNAL_ERROR "dev_is_partitioned_native requires i/o.");
-		return -1;
-	}
-
 	/* Unpartitioned DASD devices are not supported. */
 	if ((MAJOR(dev->dev) == dt->dasd_major) && dasd_is_cdl_formatted(dev))
 		return 1;
diff --git a/lib/device/device.h b/lib/device/device.h
index 572994bb9..d0d670ec3 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -32,8 +32,8 @@
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 #define DEV_IN_BCACHE		0x00000800      /* dev fd is open and used in bcache */
 #define DEV_BCACHE_EXCL		0x00001000      /* bcache_fd should be open EXCL */
-#define DEV_FILTER_AFTER_SCAN	0x00002000	/* apply filter after bcache has data */
-#define DEV_FILTER_OUT_SCAN	0x00004000	/* filtered out during label scan */
+/* unused                       0x00002000      */
+/* unused			0x00004000	*/
 #define DEV_BCACHE_WRITE	0x00008000      /* bcache_fd is open with RDWR */
 #define DEV_SCAN_FOUND_LABEL	0x00010000      /* label scan read dev and found label */
 #define DEV_IS_MD_COMPONENT	0x00020000	/* device is an md component */
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 865fde1a2..84bfcadb0 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -99,14 +99,6 @@ static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __att
 		return 1;
 
 	ret = dev_is_md_component(cmd, dev, NULL, cmd->use_full_md_check);
-
-	if (ret == -EAGAIN) {
-		/* let pass, call again after scan */
-		dev->flags |= DEV_FILTER_AFTER_SCAN;
-		log_debug_devs("filter md deferred %s", dev_name(dev));
-		return 1;
-	}
-
 	if (ret == 0)
 		return 1;
 
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 642553ef2..cab86e9b4 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -30,14 +30,6 @@ static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter
 	dev->filtered_flags &= ~DEV_FILTERED_PARTITIONED;
 
 	ret = dev_is_partitioned(cmd, dev);
-
-	if (ret == -EAGAIN) {
-		/* let pass, call again after scan */
-		log_debug_devs("filter partitioned deferred %s", dev_name(dev));
-		dev->flags |= DEV_FILTER_AFTER_SCAN;
-		return 1;
-	}
-
 	if (ret) {
 		if (dev->ext.src == DEV_EXT_NONE)
 			log_debug_devs(MSG_SKIPPING, dev_name(dev));
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index c164c4a99..212a5c183 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -109,8 +109,6 @@ static int _lookup_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 
 	/* Uncached, check filters and cache the result */
 	if (!l) {
-		dev->flags &= ~DEV_FILTER_AFTER_SCAN;
-
 		pass = pf->real->passes_filter(cmd, pf->real, dev, use_filter_name);
 
 		if (!pass) {
@@ -120,21 +118,13 @@ static int _lookup_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 			 * because the deferred result won't change the exclude.
 			 */
 			l = PF_BAD_DEVICE;
-
-		} else if ((pass == -EAGAIN) || (dev->flags & DEV_FILTER_AFTER_SCAN)) {
-			/*
-			 * When the filter result is deferred, we let the device
-			 * pass for now, but do not cache the result.  We need to
-			 * rerun the filters later.  At that point the final result
-			 * will be cached.
-			 */
-			log_debug_devs("filter cache deferred %s", dev_name(dev));
-			dev->flags |= DEV_FILTER_AFTER_SCAN;
+		} else if (pass == 1) {
+			l = PF_GOOD_DEVICE;
+		} else {
+			log_error("Ignore invalid filter result %d %s", pass, dev_name(dev));
 			pass = 1;
+			/* don't cache invalid result */
 			goto out;
-
-		} else if (pass) {
-			l = PF_GOOD_DEVICE;
 		}
 
 		if (!dev->filtered_flags) /* skipping reason already logged by filter */
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
index eeefa4f58..dd9922471 100644
--- a/lib/filters/filter-signature.c
+++ b/lib/filters/filter-signature.c
@@ -33,13 +33,6 @@ static int _ignore_signature(struct cmd_context *cmd, struct dev_filter *f __att
 
 	dev->filtered_flags &= ~DEV_FILTERED_SIGNATURE;
 
-	if (!scan_bcache) {
-		/* let pass, call again after scan */
-		log_debug_devs("filter signature deferred %s", dev_name(dev));
-		dev->flags |= DEV_FILTER_AFTER_SCAN;
-		return 1;
-	}
-
 	memset(buf, 0, BUFSIZE);
 
 	if (!dev_read_bytes(dev, 0, BUFSIZE, buf)) {

