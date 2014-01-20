From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 20 Jan 2014 19:40:11 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20140120194011.E423F60D42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa21e79991da6f6583f708f81ff32a1e2c0c3a42
Commit:        aa21e79991da6f6583f708f81ff32a1e2c0c3a42
Parent:        cf97d8d5f9449a2102f3e6c92efe4987744c96e9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 20 19:22:56 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 20 19:22:56 2014 +0000

pre-release

---
 VERSION             |    2 +-
 VERSION_DM          |    2 +-
 WHATS_NEW           |   28 +++++++++++++++++-----------
 WHATS_NEW_DM        |    8 ++++----
 lib/metadata/pv.c   |   33 ++++++++++++++++++++++++---------
 lib/report/report.c |    1 -
 6 files changed, 47 insertions(+), 27 deletions(-)

diff --git a/VERSION b/VERSION
index 8594917..07b56f1 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.105(2)-git (2013-11-13)
+2.02.105(2)-git (2014-01-20)
diff --git a/VERSION_DM b/VERSION_DM
index d36b815..23b8f70 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.84-git (2013-11-13)
+1.02.84-git (2014-01-20)
diff --git a/WHATS_NEW b/WHATS_NEW
index 284c92e..26b63ae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,7 @@
-Version 2.02.105 -
-=====================================
-  Fix thin LV flagging for udev to skip scanning only if the LV is wiped
-  Replace use of xfs_check with xfs_reparir in fsadm. 
+Version 2.02.105 - 20th January 2014
+====================================
+  Fix thin LV flagging for udev to skip scanning only if the LV is wiped.
+  Replace use of xfs_check with xfs_repair in fsadm. 
   Mark lvm1 format metadata as FMT_OBSOLETE. Do not use it with lvmetad.
   Invalidate cached VG struct after a PV in it gets orphaned. (2.02.87)
   Mark pool format metadata as FMT_OBSOLETE.
@@ -12,7 +12,7 @@ Version 2.02.105 -
   Optimize double call of stat() for cached devices.
   Enable support for thin provisioning for default configuration.
   Improve process_each_lv_in_vg() tag processing.
-  Reodered and simplified logging code.
+  Reordered and simplified logging code.
   Fix SYSTEMD_READY assignment for foreign devices in lvmetad udev rules.
   Disable online thin pool metadata resize for 1.9 kernel thin target.
   Shortened code for initialization of raid segment types.
@@ -49,13 +49,19 @@ Version 2.02.105 -
   Check for failure of dev_get_size() when reporting device size.
   Drop extra unneeded '/' when scanning sysfs directory.
   Fix undef value if skipped clustered VG ignored for toollib PV seg. (2.02.103)
-  liblvm/python API Add ability to validate VG/LV names.
-  liblvm/python API Add ability to create PV with arguments.
-  liblvm/python API Fail VG reduce when insufficient metadata copies
-  Fix install of conf subdir when not building in srcdir.
+  Support validation of VG/LV names in liblvm/python.
+  Allow creation of PVs with arguments to liblvm/python.
+  Ensure sufficient metadata copies retained in liblvm/python vgreduce.
+  Fix installation of profiles from conf subdir when not building in srcdir.
+  Show UUIDs for missing PVs in reports.
+  Change dev_size/name, pv_fmt/mda_free/mda_size/uuid fields from pv to label.
+  Add struct device *dev to struct label.
+  Introduce process_each_label.
+  Change void *private to struct format_type *fmt in struct labeller.
+  Remove pv_read.
   Add reporting of thin_id device id for thin volumes.
-  Fix reporting of empty numerical values.
-  Simplify reporting code.
+  Fix reporting of empty numerical values for recently-added fields.
+  Use _field_set_percent/value in reporting code.
 
 Version 2.02.104 - 13th November 2013
 =====================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index af82096..ce302f3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,8 +1,8 @@
-Version 1.02.84 -
-====================================
-  Deactive already actived nodes when node's preload callback fails.
+Version 1.02.84 - 20th January 2014
+===================================
+  Revert activation of activated nodes if a node preload callback fails.
   Avoid busy looping on CPU when dmeventd reads event DM_WAIT_RETRY.
-  Ensure global mutex is being hold when working with dmeventd thread.
+  Ensure global mutex is held when working with dmeventd thread.
   Drop taking timeout mutex for un/registering dmeventd monitor.
   Allow section names in config file data to be quoted strings.
   Close fifos before exiting in dmeventd restart() error path.
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 6f5fca4..45acef4 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -88,6 +88,7 @@ uint64_t pv_dev_size(const struct physical_volume *pv)
 
 	if (!dev_get_size(pv->dev, &size))
 		size = 0;
+
 	return size;
 }
 
@@ -99,6 +100,7 @@ uint64_t pv_size_field(const struct physical_volume *pv)
 		size = pv->size;
 	else
 		size = (uint64_t) pv->pe_count * pv->pe_size;
+
 	return size;
 }
 
@@ -111,6 +113,7 @@ uint64_t pv_free(const struct physical_volume *pv)
 	else
 		freespace = (uint64_t)
 			(pv->pe_count - pv->pe_alloc_count) * pv->pe_size;
+
 	return freespace;
 }
 
@@ -154,14 +157,17 @@ uint32_t pv_mda_count(const struct physical_volume *pv)
 	struct lvmcache_info *info;
 
 	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+
 	return info ? lvmcache_mda_count(info) : UINT64_C(0);
 }
 
 static int _count_unignored(struct metadata_area *mda, void *baton)
 {
 	uint32_t *count = baton;
+
 	if (!mda_is_ignored(mda))
 		(*count) ++;
+
 	return 1;
 }
 
@@ -174,6 +180,7 @@ uint32_t pv_mda_used_count(const struct physical_volume *pv)
 	if (!info)
 		return 0;
 	lvmcache_foreach_mda(info, _count_unignored, &used_count);
+
 	return used_count;
 }
 
@@ -228,7 +235,8 @@ uint64_t pv_mda_size(const struct physical_volume *pv)
 	return min_mda_size;
 }
 
-static int _pv_mda_free(struct metadata_area *mda, void *baton) {
+static int _pv_mda_free(struct metadata_area *mda, void *baton)
+{
 	uint64_t mda_free;
 	uint64_t *freespace = baton;
 
@@ -238,6 +246,7 @@ static int _pv_mda_free(struct metadata_area *mda, void *baton) {
 	mda_free = mda->ops->mda_free_sectors(mda);
 	if (mda_free < *freespace)
 		*freespace = mda_free;
+
 	return 1;
 }
 
@@ -258,8 +267,10 @@ uint64_t pv_mda_free(const struct physical_volume *pv)
 {
 	const char *pvid = (const char *)&pv->id.uuid;
 	struct lvmcache_info *info;
+
 	if ((info = lvmcache_info_from_pvid(pvid, 0)))
 		return lvmcache_info_mda_free(info);
+
 	return 0;
 }
 
@@ -271,6 +282,7 @@ uint64_t pv_used(const struct physical_volume *pv)
 		used = 0LL;
 	else
 		used = (uint64_t) pv->pe_alloc_count * pv->pe_size;
+
 	return used;
 }
 
@@ -299,6 +311,7 @@ static int _pv_mda_set_ignored_one(struct metadata_area *mda, void *baton)
 			mda_set_ignored(vg_mda, b->mda_ignored);
 
 	mda_set_ignored(mda, b->mda_ignored);
+
 	return 1;
 }
 
@@ -355,12 +368,14 @@ struct label *pv_label(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info =
 		lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
-	if (!info) {
-		if (pv->vg && pv->dev) /* process_each_pv will create PVs that are dummy
-			     * and that have no label associated */
-			log_error(INTERNAL_ERROR "PV %s unexpectedly not in cache.",
-				  dev_name(pv->dev));
-		return NULL;
-	}
-	return lvmcache_get_label(info);
+
+	if (info)
+		return lvmcache_get_label(info);
+
+	/* process_each_pv() may create dummy PVs that have no label */
+	if (pv->vg && pv->dev)
+		log_error(INTERNAL_ERROR "PV %s unexpectedly not in cache.",
+			  dev_name(pv->dev));
+
+	return NULL;
 }
diff --git a/lib/report/report.c b/lib/report/report.c
index bd4b725..3a5119d 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -55,7 +55,6 @@ static int _field_set_percent(struct dm_report_field *field,
 	uint64_t *sortval;
 
 	if (percent == PERCENT_INVALID)
-		// FIXME  maybe use here '--'?
 		return _field_set_value(field, "", &_minusone64);
 
 	if (!(repstr = dm_pool_alloc(mem, 8)) ||


