From: David Teigland <teigland@sourceware.org>
Date: Tue, 22 May 2018 11:01:32 -0400
Subject: master - scan: move warnings about duplicate devices
Message-ID: <201805221501.w4MF1W8O008239@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c9ed33f83c90aa15e57ba6dc12d8f1a80afab6d
Commit:        3c9ed33f83c90aa15e57ba6dc12d8f1a80afab6d
Parent:        73ae68e1c4308c3391fe3b21f2c721f659343f98
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 21 14:20:19 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 21 16:48:02 2018 -0500

scan: move warnings about duplicate devices

We have been warning about duplicate devices (and disabling lvmetad)
immediately when the dup was detected (during label_scan).  Move the
warnings (and the disabling) to happen later, after label_scan is
finished.

This lets us avoid an unwanted warning message about duplicates
in the special case were md components are eliminated during the
duplicate device resolution.
---
 lib/cache/lvmcache.c                     |  125 ++++++++++++++++++++++++++----
 lib/cache/lvmcache.h                     |    2 +
 lib/cache/lvmetad.c                      |    2 +
 lib/device/device.h                      |    1 +
 test/shell/process-each-duplicate-pvs.sh |   22 +++---
 test/shell/pv-duplicate-uuid.sh          |    5 +-
 6 files changed, 126 insertions(+), 31 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9912995..c306a3a 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -981,11 +981,25 @@ int lvmcache_dev_is_unchosen_duplicate(struct device *dev)
  * The actual filters are evaluated too early, before a complete
  * picture of all PVs is available, to eliminate these duplicates.
  *
- * By removing the filtered duplicates from unused_duplicate_devs, we remove
+ * By removing some duplicates from unused_duplicate_devs here, we remove
  * the restrictions that are placed on using duplicate devs or VGs with
  * duplicate devs.
  *
- * There may other kinds of duplicates that we want to ignore.
+ * In cases where we know that two duplicates refer to the same underlying
+ * storage, and we know which dev path to use, it's best for us to just
+ * use that one preferred device path and ignore the others.  It is the cases
+ * where we are unsure whether dups refer to the same underlying storage where
+ * we need to keep the unused duplicate referenced in the
+ * unused_duplicate_devs list, and restrict what we allow done with it.
+ *
+ * In the case of md components, we usually filter these out in filter-md,
+ * but in the special case of md superblocks <= 1.0 where the superblock
+ * is@the end of the device, filter-md doesn't always eliminate them
+ * first, so we eliminate them here.
+ *
+ * There may other kinds of duplicates that we want to eliminate at
+ * this point (using the knowledge from the scan) that we couldn't
+ * eliminate in the filters prior to the scan.
  */
 
 static void _filter_duplicate_devs(struct cmd_context *cmd)
@@ -1004,6 +1018,34 @@ static void _filter_duplicate_devs(struct cmd_context *cmd)
 			dm_free(devl);
 		}
 	}
+
+	if (dm_list_empty(&_unused_duplicate_devs))
+		_found_duplicate_pvs = 0;
+}
+
+static void _warn_duplicate_devs(struct cmd_context *cmd)
+{
+	char uuid[64] __attribute__((aligned(8)));
+	struct lvmcache_info *info;
+	struct device_list *devl, *devl2;
+
+	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
+		if (!id_write_format((const struct id *)devl->dev->pvid, uuid, sizeof(uuid)))
+			stack;
+
+		log_warn("WARNING: Not using device %s for PV %s.", dev_name(devl->dev), uuid);
+	}
+
+	dm_list_iterate_items_safe(devl, devl2, &_unused_duplicate_devs) {
+		/* info for the preferred device that we're actually using */
+		info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0);
+
+		if (!id_write_format((const struct id *)info->dev->pvid, uuid, sizeof(uuid)))
+			stack;
+
+		log_warn("WARNING: PV %s prefers device %s because %s.",
+			 uuid, dev_name(info->dev), info->dev->duplicate_prefer_reason);
+	}
 }
 
 /*
@@ -1028,7 +1070,6 @@ static void _choose_preferred_devs(struct cmd_context *cmd,
 				   struct dm_list *del_cache_devs,
 				   struct dm_list *add_cache_devs)
 {
-	char uuid[64] __attribute__((aligned(8)));
 	const char *reason;
 	struct dm_list altdevs;
 	struct dm_list new_unused;
@@ -1229,9 +1270,7 @@ next:
 			alt = devl;
 		}
 
-		if (!id_write_format((const struct id *)dev1->pvid, uuid, sizeof(uuid)))
-			stack;
-		log_warn("WARNING: PV %s prefers device %s because %s.", uuid, dev_name(dev1), reason);
+		dev1->duplicate_prefer_reason = reason;
 	}
 
 	if (dev1 != info->dev) {
@@ -1480,11 +1519,21 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
 
 		/*
-		 * We might want to move the duplicate device warnings until
-		 * after this filtering so that we can skip warning about
-		 * duplicates that we are filtering out.
+		 * This may remove some entries from the unused_duplicates list for
+		 * devs that we know are the same underlying dev.
 		 */
 		_filter_duplicate_devs(cmd);
+
+		/*
+		 * Warn about remaining duplicates that may actually be separate copies of
+		 * the same device.
+		 */
+		_warn_duplicate_devs(cmd);
+
+		if (!_found_duplicate_pvs && lvmetad_used()) {
+			log_warn("WARNING: Disabling lvmetad cache which does not support duplicate PVs.");
+			lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
+		}
 	}
 
 	/* Perform any format-specific scanning e.g. text files */
@@ -1509,6 +1558,53 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	return r;
 }
 
+/*
+ * When not using lvmetad, lvmcache_label_scan() detects duplicates in
+ * the basic label_scan(), then filters out some dups, and chooses
+ * preferred duplicates to use.
+ *
+ * When using lvmetad, pvscan --cache does not use lvmcache_label_scan(),
+ * only label_scan() which detects the duplicates.  This function is used
+ * after pvscan's label_scan() to filter out some dups, print any warnings,
+ * and disable lvmetad if any dups are left.
+ */
+
+void lvmcache_pvscan_duplicate_check(struct cmd_context *cmd)
+{
+	struct device_list *devl;
+
+	/* Check if label_scan() detected any dups. */
+	if (!_found_duplicate_pvs)
+		return;
+
+	/*
+	 * Once all the dups are identified, they are moved from the
+	 * "found" list to the "unused" list to sort out.
+	 */
+	dm_list_splice(&_unused_duplicate_devs, &_found_duplicate_devs);
+
+	/*
+	 * Remove items from the dups list that we know are the same
+	 * underlying dev, e.g. md components, that we want to just ignore.
+	 */
+	_filter_duplicate_devs(cmd);
+
+	/*
+	 * If no more dups after ignoring some, then we can use lvmetad.
+	 */
+	if (!_found_duplicate_pvs)
+		return;
+
+	/* Duplicates are found where we would have to pick one, so disable lvmetad. */
+
+	dm_list_iterate_items(devl, &_unused_duplicate_devs)
+		log_warn("WARNING: found device with duplicate %s", dev_name(devl->dev));
+
+	log_warn("WARNING: Disabling lvmetad cache which does not support duplicate PVs.");
+	lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
+	lvmetad_make_unused(cmd);
+}
+
 int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
 			   struct dm_list *vgnameids)
 {
@@ -2303,14 +2399,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 	 */
 	if (!created) {
 		if (info->dev != dev) {
-			log_warn("WARNING: PV %s on %s was already found on %s.",
-				  uuid, dev_name(dev), dev_name(info->dev));
-
-			if (!_found_duplicate_pvs && lvmetad_used()) {
-				log_warn("WARNING: Disabling lvmetad cache which does not support duplicate PVs."); 
-				lvmetad_set_disabled(labeller->fmt->cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
-			}
-			_found_duplicate_pvs = 1;
+			log_debug_cache("PV %s on %s was already found on %s.",
+				        uuid, dev_name(dev), dev_name(info->dev));
 
 			strncpy(dev->pvid, pvid_s, sizeof(dev->pvid));
 
@@ -2328,6 +2418,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 			devl->dev = dev;
 
 			dm_list_add(&_found_duplicate_devs, &devl->list);
+			_found_duplicate_pvs = 1;
 			return NULL;
 		}
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index a2a7f07..b988be6 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -188,6 +188,8 @@ uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info);
 
 int lvmcache_found_duplicate_pvs(void);
 
+void lvmcache_pvscan_duplicate_check(struct cmd_context *cmd);
+
 int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *head);
 
 int vg_has_duplicate_pvs(struct volume_group *vg);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 235f72b..a1ab41a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2350,6 +2350,8 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 
 	label_scan(cmd);
 
+	lvmcache_pvscan_duplicate_check(cmd);
+
 	if (lvmcache_found_duplicate_pvs()) {
 		log_warn("WARNING: Scan found duplicate PVs.");
 		return 0;
diff --git a/lib/device/device.h b/lib/device/device.h
index 42659cd..c8ccd73 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -75,6 +75,7 @@ struct device {
 	uint64_t size;
 	uint64_t end;
 	struct dev_ext ext;
+	const char *duplicate_prefer_reason;
 
 	const char *vgid; /* if device is an LV */
 	const char *lvid; /* if device is an LV */
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index 98dd285..9ce4e14 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -72,7 +72,7 @@ not grep duplicate main
 not grep $vg2 main
 not grep $UUID2 main
 
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 # Find which is the preferred dev and which is the duplicate.
@@ -119,7 +119,7 @@ grep "$dev2" main | grep $vg1
 grep "$dev1" main | grep $UUID1
 grep "$dev2" main | grep $UUID1
 
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 #
@@ -136,7 +136,7 @@ grep "$dev1" main
 not grep "$dev2" main
 grep "$UUID1" main
 grep "$vg1" main
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 pvs -o+uuid "$dev2" 2>&1 | tee out
@@ -149,7 +149,7 @@ grep "$dev2" main
 not grep "$dev1" main
 grep "$UUID1" main
 grep "$vg1" main
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 pvs -o+uuid,duplicate "$dev1" "$dev2" 2>&1 | tee out
@@ -225,7 +225,7 @@ grep -v WARNING out > main || true
 not grep "$dev1" main
 grep "$dev2" main
 
-not grep "was already found on" warn
+not grep "Not using device" warn
 not grep "prefers device" warn
 
 
@@ -238,7 +238,7 @@ grep -v WARNING out > main || true
 grep "$dev1" main
 not grep "$dev2" main
 
-not grep "was already found on" warn
+not grep "Not using device" warn
 not grep "prefers device" warn
 
 # PV size and minor is still reported correctly for each.
@@ -306,7 +306,7 @@ grep -v WARNING out > main || true
 test "$(grep -c "$UUID3" main)" -eq 1
 not grep "$UUID4" main
 
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 # Both appear with 'pvs -a'
@@ -325,7 +325,7 @@ grep "$dev4" main
 grep $UUID3 main
 not grep $UUID4 main
 
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 # Show each dev individually and both together
@@ -339,7 +339,7 @@ grep -v WARNING out > main || true
 grep "$dev3" main
 not grep "$dev4" main
 
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 pvs -o+uuid "$dev4" 2>&1 | tee out
@@ -351,7 +351,7 @@ grep -v WARNING out > main || true
 not grep "$dev3" main
 grep "$dev4" main
 
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 pvs -o+uuid "$dev3" "$dev4" 2>&1 | tee out
@@ -363,7 +363,7 @@ grep -v WARNING out > main || true
 grep "$dev3" main
 grep "$dev4" main
 
-grep "was already found on" warn
+grep "Not using device" warn
 grep "prefers device" warn
 
 # Same sizes shown.
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index 43eb830..2c121d7 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -26,7 +26,6 @@ pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]} global/use_lvmetad=0
 pvscan --cache 2>&1 | tee out
 
 if test -e LOCAL_LVMETAD; then
-	grep "was already found" out
 	grep "WARNING: Disabling lvmetad cache which does not support duplicate PVs." out
 fi
 
@@ -37,7 +36,7 @@ grep -v WARNING out > main || true
 
 test "$(grep -c $UUID1 main)" -eq 1
 
-COUNT=$(grep --count "was already found" warn)
+COUNT=$(grep --count "Not using device" warn)
 [ "$COUNT" -eq 2 ]
 
 pvs -o+uuid --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" 2>&1 | tee out
@@ -50,5 +49,5 @@ not grep "$dev1" main
 grep "$dev2" main
 not grep "$dev3" main
 
-not grep "was already found" warn
+not grep "Not using device" warn
 


