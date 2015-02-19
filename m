From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 19 Feb 2015 13:39:35 +0000 (UTC)
Subject: master - pvcreate: switch to "none" dev-ext source during pvcreate
Message-ID: <20150219133935.29B2660DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed420fb6917162ed17af69a9a0ec9ae26e61e209
Commit:        ed420fb6917162ed17af69a9a0ec9ae26e61e209
Parent:        69b1e32c8a06c77023d2e3440e0abfaeb86808f7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 19 14:30:20 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 19 14:34:55 2015 +0100

pvcreate: switch to "none" dev-ext source during pvcreate

The dev ext source must be reset for the dev_cache_get call
(which evaluates filters), not lvmcache_label_scan - so fix
original commit 727c7ff85d448743f751bc5218e73c41314ed5f1.

Also, add comments in _pvcreate_check fn explaining why
refresh filter and rescan is needed and exactly in which
situations.
---
 lib/metadata/metadata.c |   82 +++++++++++++++++++++++++++++++++-------------
 1 files changed, 59 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a4c3033..5acb2b4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1416,18 +1416,18 @@ int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
  * 0 indicates we may not.
  */
 static int _pvcreate_check(struct cmd_context *cmd, const char *name,
-			   struct pvcreate_params *pp)
+			   struct pvcreate_params *pp, int *wiped)
 {
 	struct physical_volume *pv;
 	struct device *dev;
 	int r = 0;
-	int wiped;
 	int scan_needed = 0;
 	int filter_refresh_needed = 0;
-	dev_ext_t dev_ext_src = external_device_info_source();
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
+	*wiped = 0;
+
 	/* Is there a pv here already? */
 	pv = find_pv_by_name(cmd, name, 1, 1);
 
@@ -1452,6 +1452,33 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	dev = dev_cache_get(name, cmd->full_filter);
 
+	/*
+	 * Refresh+rescan at the end is needed if:
+	 *   - we don't obtain device list from udev,
+	 *     hence persistent cache file is used
+	 *     and we need to trash it and reevaluate
+	 *     for any changes done outside - adding
+	 *     any new foreign signature which may affect
+	 *     filtering - before we do pvcreate, we
+	 *     need to be sure that we have up-to-date
+	 *     view for filters
+	 *
+	 *   - we have wiped existing foreign signatures
+	 *     from dev as this may affect what's filtered
+	 *     as well
+	 *
+	 *
+	 * Only rescan at the end is needed if:
+	 *   - we've just checked whether dev is fileterd
+	 *     by MD filter. We do the refresh in-situ,
+	 *     so no need to require the refresh at the
+	 *     end of this fn. This is to allow for
+	 *     wiping MD signature during pvcreate for
+	 *     the dev - the dev would normally be
+	 *     filtered because of MD filter.
+	 *     This is an exception.
+	 */
+
 	/* Is there an md superblock here? */
 	if (!dev && md_filtering()) {
 		if (!refresh_filters(cmd))
@@ -1462,7 +1489,8 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 		init_md_filtering(1);
 
 		scan_needed = 1;
-	}
+	} else if (!obtain_device_list_from_udev())
+		filter_refresh_needed = scan_needed = 1;
 
 	if (!dev) {
 		log_error("Device %s not found (or ignored by filtering).", name);
@@ -1481,26 +1509,13 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	if (!wipe_known_signatures(cmd, dev, name,
 				   TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
-				   0, pp->yes, pp->force, &wiped)) {
+				   0, pp->yes, pp->force, wiped)) {
 		log_error("Aborting pvcreate on %s.", name);
 		goto out;
 	}
 
-	if (wiped) {
-		if (dev_ext_src == DEV_EXT_UDEV)
-			/*
-			 * wipe_known_signatures called later fires WATCH event
-			 * to update udev database. But at the moment, we have
-			 * no way to synchronize with such event - we may end
-			 * up still seeing the old info in udev db and pvcreate
-			 * can fail to proceed because of the device still
-			 * being filtered (because of the stale info in udev db).
-			 * Disable udev dev-ext source temporarily here for
-			 * this reason.
-			 */
-			init_external_device_info_source(DEV_EXT_NONE);
+	if (wiped)
 		filter_refresh_needed = scan_needed = 1;
-	}
 
 	if (sigint_caught())
 		goto_out;
@@ -1521,14 +1536,14 @@ out:
 			r = 0;
 		}
 
-	if (scan_needed)
+	if (scan_needed) {
 		if (!lvmcache_label_scan(cmd, 2)) {
 			stack;
 			r = 0;
 		}
+	}
 
 	free_pv_fid(pv);
-	init_external_device_info_source(dev_ext_src);
 	return r;
 }
 
@@ -1637,9 +1652,11 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 {
 	struct physical_volume *pv = NULL;
 	struct device *dev;
+	int wiped = 0;
 	struct dm_list mdas;
 	struct pvcreate_params default_pp;
 	char buffer[64] __attribute__((aligned(8)));
+	dev_ext_t dev_ext_src;
 
 	pvcreate_params_set_defaults(&default_pp);
 	if (!pp)
@@ -1661,13 +1678,32 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 		}
 	}
 
-	if (!_pvcreate_check(cmd, pv_name, pp))
+	if (!_pvcreate_check(cmd, pv_name, pp, &wiped))
 		goto_bad;
 
 	if (sigint_caught())
 		goto_bad;
 
-	if (!(dev = dev_cache_get(pv_name, cmd->full_filter))) {
+	/*
+	 * wipe_known_signatures called in _pvcreate_check fires
+	 * WATCH event to update udev database. But at the moment,
+	 * we have no way to synchronize with such event - we may
+	 * end up still seeing the old info in udev db and pvcreate
+	 * can fail to proceed because of the device still being
+	 * filtered (because of the stale info in udev db).
+	 * Disable udev dev-ext source temporarily here for
+	 * this reason and rescan with DEV_EXT_NONE dev-ext
+	 * source (so filters use DEV_EXT_NONE source).
+	 */
+	dev_ext_src = external_device_info_source();
+	if (wiped && (dev_ext_src == DEV_EXT_UDEV))
+		init_external_device_info_source(DEV_EXT_NONE);
+
+	dev = dev_cache_get(pv_name, cmd->full_filter);
+
+	init_external_device_info_source(dev_ext_src);
+
+	if (!dev) {
 		log_error("%s: Couldn't find device.  Check your filters?",
 			  pv_name);
 		goto bad;


