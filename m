From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Feb 2015 08:59:30 +0000 (UTC)
Subject: master - filters: no need to refresh filters/rescan if no signature is wiped during pvcreate at all
Message-ID: <20150217085930.91363602F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b4066585f73df7328ea16f6cb3713cd49cf2d2d
Commit:        6b4066585f73df7328ea16f6cb3713cd49cf2d2d
Parent:        1ee82b545b5a1a1ca6cc7ae9d224ef981d59432f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 17 09:46:34 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 17 09:46:34 2015 +0100

filters: no need to refresh filters/rescan if no signature is wiped during pvcreate at all

Before, we refreshed filters and we did full rescan of devices if
we passed through wiping (wipe_known_signatures fn call). However,
this fn returns success even if no signatures were found and so
nothing was wiped. In this case, it's not necessary to do the
filter refresh/rescan of devices as nothing changed clearly.

This patch exports number of wiped signatures from all the
wiping functions below. The caller (_pvcreate_check) then checks
whether any wiping was done at all and if not, no refresh/rescan
is done, saving some time and resources.
---
 WHATS_NEW               |    1 +
 lib/device/dev-type.c   |   36 ++++++++++++++++++++++++------------
 lib/device/dev-type.h   |    2 +-
 lib/metadata/lv_manip.c |    2 +-
 lib/metadata/metadata.c |   34 ++++++++++++++++++----------------
 5 files changed, 45 insertions(+), 30 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c3dff92..b956a80 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Do not refresh filters/rescan if no signature is wiped during pvcreate.
   Enforce none external dev info for wiping during pvcreate to avoid races.
   Add support for VG system_id to control host access to VGs.
   Update vgextend to use process_each_vg.
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index ba30982..c7624ac 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -596,12 +596,16 @@ static int _blkid_wipe(blkid_probe probe, struct device *dev, const char *name,
 static int _wipe_known_signatures_with_blkid(struct device *dev, const char *name,
 					     uint32_t types_to_exclude,
 					     uint32_t types_no_prompt,
-					     int yes, force_t force)
+					     int yes, force_t force, int *wiped)
 {
 	blkid_probe probe = NULL;
-	int found = 0, wiped = 0, left = 0;
+	int found = 0, left = 0, wiped_tmp;
 	int r = 0;
 
+	if (!wiped)
+		wiped = &wiped_tmp;
+	*wiped = 0;
+
 	/* TODO: Should we check for valid dev - _dev_is_valid(dev)? */
 
 	if (!(probe = blkid_new_probe_from_filename(dev_name(dev)))) {
@@ -624,13 +628,13 @@ static int _wipe_known_signatures_with_blkid(struct device *dev, const char *nam
 	while (!blkid_do_probe(probe)) {
 		found++;
 		if (_blkid_wipe(probe, dev, name, types_to_exclude, types_no_prompt, yes, force))
-			wiped++;
+			(*wiped)++;
 	}
 
 	if (!found)
 		r = 1;
 
-	left = found - wiped;
+	left = found - *wiped;
 	if (!left)
 		r = 1;
 	else
@@ -645,7 +649,7 @@ out:
 #endif /* BLKID_WIPING_SUPPORT */
 
 static int _wipe_signature(struct device *dev, const char *type, const char *name,
-			   int wipe_len, int yes, force_t force,
+			   int wipe_len, int yes, force_t force, int *wiped,
 			   int (*signature_detection_fn)(struct device *dev, uint64_t *offset_found))
 {
 	int wipe;
@@ -675,17 +679,24 @@ static int _wipe_signature(struct device *dev, const char *type, const char *nam
 		return 0;
 	}
 
+	(*wiped)++;
 	return 1;
 }
 
 static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
 					   uint32_t types_to_exclude __attribute__((unused)),
 					   uint32_t types_no_prompt __attribute__((unused)),
-					   int yes, force_t force)
+					   int yes, force_t force, int *wiped)
 {
-	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, dev_is_md) ||
-	    !_wipe_signature(dev, "swap signature", name, 10, yes, force, dev_is_swap) ||
-	    !_wipe_signature(dev, "LUKS signature", name, 8, yes, force, dev_is_luks))
+	int wiped_tmp;
+
+	if (!wiped)
+		wiped = &wiped_tmp;
+	*wiped = 0;
+
+	if (!_wipe_signature(dev, "software RAID md superblock", name, 4, yes, force, wiped, dev_is_md) ||
+	    !_wipe_signature(dev, "swap signature", name, 10, yes, force, wiped, dev_is_swap) ||
+	    !_wipe_signature(dev, "LUKS signature", name, 8, yes, force, wiped, dev_is_luks))
 		return 0;
 
 	return 1;
@@ -693,19 +704,20 @@ static int _wipe_known_signatures_with_lvm(struct device *dev, const char *name,
 
 int wipe_known_signatures(struct cmd_context *cmd, struct device *dev,
 			  const char *name, uint32_t types_to_exclude,
-			  uint32_t types_no_prompt, int yes, force_t force)
+			  uint32_t types_no_prompt, int yes, force_t force,
+			  int *wiped)
 {
 #ifdef BLKID_WIPING_SUPPORT
 	if (find_config_tree_bool(cmd, allocation_use_blkid_wiping_CFG, NULL))
 		return _wipe_known_signatures_with_blkid(dev, name,
 							 types_to_exclude,
 							 types_no_prompt,
-							 yes, force);
+							 yes, force, wiped);
 #endif
 	return _wipe_known_signatures_with_lvm(dev, name,
 					       types_to_exclude,
 					       types_no_prompt,
-					       yes, force);
+					       yes, force, wiped);
 }
 
 #ifdef __linux__
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 10f82ba..2a49b4b 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -66,7 +66,7 @@ int dev_is_luks(struct device *dev, uint64_t *signature);
 #define TYPE_DM_SNAPSHOT_COW	0x004
 int wipe_known_signatures(struct cmd_context *cmd, struct device *dev, const char *name,
 			  uint32_t types_to_exclude, uint32_t types_no_prompt,
-			  int yes, force_t force);
+			  int yes, force_t force, int *wiped);
 
 /* Type-specific device properties */
 unsigned long dev_md_stripe_width(struct dev_types *dt, struct device *dev);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0fcf7c2..bdb2ef2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6466,7 +6466,7 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 			     lv->vg->name, lv->name);
 		if (!wipe_known_signatures(lv->vg->cmd, dev, name, 0,
 					   TYPE_DM_SNAPSHOT_COW,
-					   wp.yes, wp.force))
+					   wp.yes, wp.force, NULL))
 			stack;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 55e6476..a4c3033 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1421,23 +1421,11 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 	struct physical_volume *pv;
 	struct device *dev;
 	int r = 0;
+	int wiped;
 	int scan_needed = 0;
 	int filter_refresh_needed = 0;
 	dev_ext_t dev_ext_src = external_device_info_source();
 
-	if (dev_ext_src == DEV_EXT_UDEV)
-		/*
-		 * wipe_known_signatures called later fires WATCH event
-		 * to update udev database. But at the moment, we have
-		 * no way to synchronize with such event - we may end
-		 * up still seeing the old info in udev db and pvcreate
-		 * can fail to proceed because of the device still
-		 * being filtered (because of the stale info in udev db).
-		 * Disable udev dev-ext source temporarily here for
-		 * this reason.
-		 */
-		init_external_device_info_source(DEV_EXT_NONE);
-
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
@@ -1493,12 +1481,26 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	if (!wipe_known_signatures(cmd, dev, name,
 				   TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
-				   0, pp->yes, pp->force)) {
+				   0, pp->yes, pp->force, &wiped)) {
 		log_error("Aborting pvcreate on %s.", name);
 		goto out;
-	} else
+	}
+
+	if (wiped) {
+		if (dev_ext_src == DEV_EXT_UDEV)
+			/*
+			 * wipe_known_signatures called later fires WATCH event
+			 * to update udev database. But at the moment, we have
+			 * no way to synchronize with such event - we may end
+			 * up still seeing the old info in udev db and pvcreate
+			 * can fail to proceed because of the device still
+			 * being filtered (because of the stale info in udev db).
+			 * Disable udev dev-ext source temporarily here for
+			 * this reason.
+			 */
+			init_external_device_info_source(DEV_EXT_NONE);
 		filter_refresh_needed = scan_needed = 1;
-	
+	}
 
 	if (sigint_caught())
 		goto_out;


