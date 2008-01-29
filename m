From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jan 2008 23:45:49 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20080129234549.23528.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-29 23:45:48

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/device     : dev-io.c 
	lib/format_text: archiver.c format-text.c 
	lib/label      : label.c 
	lib/report     : report.c 

Log message:
	Rely upon internally-cached PV labels while corresponding VG lock is held.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.781&r2=1.782
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/WHATS_NEW	2008/01/29 12:02:04	1.781
+++ LVM2/WHATS_NEW	2008/01/29 23:45:47	1.782
@@ -1,5 +1,6 @@
 Version 2.02.33 -
 ===================================
+  Rely upon internally-cached PV labels while corresponding VG lock is held.
 
 Version 2.02.32 - 29th January 2008
 ===================================
--- LVM2/lib/cache/lvmcache.c	2007/11/05 17:12:50	1.33
+++ LVM2/lib/cache/lvmcache.c	2008/01/29 23:45:47	1.34
@@ -49,6 +49,41 @@
 	return 1;
 }
 
+static void _update_cache_info_lock_state(struct lvmcache_info *info, int locked)
+{
+	int was_locked = (info->status & CACHE_LOCKED) ? 1 : 0;
+
+	/*
+	 * Cache becomes invalid whenever lock state changes
+	 */
+	if (was_locked != locked)
+		info->status |= CACHE_INVALID;
+
+	if (locked)
+		info->status |= CACHE_LOCKED;
+	else
+		info->status &= ~CACHE_LOCKED;
+}
+
+static void _update_cache_vginfo_lock_state(struct lvmcache_vginfo *vginfo,
+					    int locked)
+{
+	struct lvmcache_info *info;
+
+	list_iterate_items(info, &vginfo->infos)
+		_update_cache_info_lock_state(info, locked);
+}
+
+static void _update_cache_lock_state(const char *vgname, int locked)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
+		return;
+
+	_update_cache_vginfo_lock_state(vginfo, locked);
+}
+
 void lvmcache_lock_vgname(const char *vgname, int read_only __attribute((unused)))
 {
 	if (!_lock_hash && !lvmcache_init()) {
@@ -59,6 +94,8 @@
 	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
 		log_error("Cache locking failure for %s", vgname);
 
+	_update_cache_lock_state(vgname, 1);
+
 	_vgs_locked++;
 }
 
@@ -72,7 +109,8 @@
 
 void lvmcache_unlock_vgname(const char *vgname)
 {
-	/* FIXME: Clear all CACHE_LOCKED flags in this vg */
+	_update_cache_lock_state(vgname, 0);
+
 	dm_hash_remove(_lock_hash, vgname);
 
 	/* FIXME Do this per-VG */
@@ -182,7 +220,22 @@
 	return vgname;
 }
 
-struct lvmcache_info *info_from_pvid(const char *pvid)
+static int _info_is_valid(struct lvmcache_info *info)
+{
+	if (info->status & CACHE_INVALID)
+		return 0;
+
+	if (!(info->status & CACHE_LOCKED))
+		return 0;
+
+	return 1;
+}
+
+/*
+ * If valid_only is set, data will only be returned if the cached data is
+ * known still to be valid.
+ */
+struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only)
 {
 	struct lvmcache_info *info;
 	char id[ID_LEN + 1] __attribute((aligned(8)));
@@ -196,6 +249,9 @@
 	if (!(info = dm_hash_lookup(_pvid_hash, id)))
 		return NULL;
 
+	if (valid_only && !_info_is_valid(info))
+		return NULL;
+
 	return info;
 }
 
@@ -344,7 +400,7 @@
 	struct lvmcache_info *info;
 
 	/* Already cached ? */
-	if ((info = info_from_pvid((char *) pvid))) {
+	if ((info = info_from_pvid((char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
@@ -355,7 +411,7 @@
 	lvmcache_label_scan(cmd, 0);
 
 	/* Try again */
-	if ((info = info_from_pvid((char *) pvid))) {
+	if ((info = info_from_pvid((char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
@@ -369,7 +425,7 @@
 	lvmcache_label_scan(cmd, 2);
 
 	/* Try again */
-	if ((info = info_from_pvid((char *) pvid))) {
+	if ((info = info_from_pvid((char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
@@ -645,6 +701,8 @@
 	info->vginfo = vginfo;
 	list_add(&vginfo->infos, &info->list);
 
+	_update_cache_vginfo_lock_state(vginfo, vgname_is_locked(vgname));
+
 	/* FIXME Check consistency of list! */
 	vginfo->fmt = info->fmt;
 
@@ -716,7 +774,7 @@
 	list_iterate_items(pvl, &vg->pvs) {
 		strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s) - 1);
 		/* FIXME Could pvl->pv->dev->pvid ever be different? */
-		if ((info = info_from_pvid(pvid_s)) &&
+		if ((info = info_from_pvid(pvid_s, 0)) &&
 		    !lvmcache_update_vgname_and_id(info, vg->name,
 						   (char *) &vg->id,
 						   vg->status, NULL))
@@ -743,8 +801,8 @@
 	strncpy(pvid_s, pvid, sizeof(pvid_s));
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
-	if (!(existing = info_from_pvid(pvid_s)) &&
-	    !(existing = info_from_pvid(dev->pvid))) {
+	if (!(existing = info_from_pvid(pvid_s, 0)) &&
+	    !(existing = info_from_pvid(dev->pvid, 0))) {
 		if (!(label = label_create(labeller))) {
 			stack;
 			return NULL;
--- LVM2/lib/cache/lvmcache.h	2007/08/20 20:55:24	1.15
+++ LVM2/lib/cache/lvmcache.h	2008/01/29 23:45:47	1.16
@@ -86,7 +86,7 @@
 struct lvmcache_vginfo *vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
-struct lvmcache_info *info_from_pvid(const char *pvid);
+struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid);
 int vgs_locked(void);
--- LVM2/lib/device/dev-io.c	2007/09/07 11:24:19	1.59
+++ LVM2/lib/device/dev-io.c	2008/01/29 23:45:47	1.60
@@ -523,7 +523,7 @@
 	/* Close unless device is known to belong to a locked VG */
 	if (immediate ||
 	    (dev->open_count < 1 && 
-	     (!(info = info_from_pvid(dev->pvid)) ||
+	     (!(info = info_from_pvid(dev->pvid, 0)) ||
 	      !info->vginfo ||
 	      !vgname_is_locked(info->vginfo->vgname))))
 		_close(dev);
--- LVM2/lib/format_text/archiver.c	2007/10/12 14:29:32	1.10
+++ LVM2/lib/format_text/archiver.c	2008/01/29 23:45:47	1.11
@@ -305,7 +305,7 @@
 	/* Add any metadata areas on the PVs */
 	list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
-		if (!(info = info_from_pvid(pv->dev->pvid))) {
+		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
 			log_error("PV %s missing from cache",
 				  pv_dev_name(pv));
 			return 0;
--- LVM2/lib/format_text/format-text.c	2007/11/05 17:17:55	1.85
+++ LVM2/lib/format_text/format-text.c	2008/01/29 23:45:47	1.86
@@ -391,7 +391,7 @@
 	}
 
       error:
-	if ((info = info_from_pvid(dev_area->dev->pvid)))
+	if ((info = info_from_pvid(dev_area->dev->pvid, 0)))
 		lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN, 0, NULL);
 
 	return NULL;
@@ -1610,7 +1610,7 @@
 	/* If new vg, add any further mdas on this PV to the fid's mda list */
 	if (vg) {
 		/* Iterate through all mdas on this PV */
-		if ((info = info_from_pvid(pv->dev->pvid))) {
+		if ((info = info_from_pvid(pv->dev->pvid, 0))) {
 			pvmdas = &info->mdas;
 			list_iterate_items(mda, pvmdas) {
 				mda_count++;
--- LVM2/lib/label/label.c	2007/08/20 20:55:26	1.38
+++ LVM2/lib/label/label.c	2008/01/29 23:45:48	1.39
@@ -179,7 +179,7 @@
 
       out:
 	if (!found) {
-		if ((info = info_from_pvid(dev->pvid)))
+		if ((info = info_from_pvid(dev->pvid, 0)))
 			lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN,
 						      0, NULL);
 		log_very_verbose("%s: No label detected", dev_name(dev));
@@ -260,7 +260,6 @@
 	return r;
 }
 
-/* FIXME Avoid repeated re-reading if cache lock held */
 int label_read(struct device *dev, struct label **result,
 		uint64_t scan_sector)
 {
@@ -270,10 +269,16 @@
 	struct lvmcache_info *info;
 	int r = 0;
 
+	if ((info = info_from_pvid(dev->pvid, 1))) {
+		log_debug("Using cached label for %s", dev_name(dev));
+		*result = info->label;
+		return 1;
+	}
+
 	if (!dev_open(dev)) {
 		stack;
 
-		if ((info = info_from_pvid(dev->pvid)))
+		if ((info = info_from_pvid(dev->pvid, 0)))
 			lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN,
 						      0, NULL);
 
@@ -353,7 +358,7 @@
 	int r = 0;
 
 	if (!dev_open(dev)) {
-		if ((info = info_from_pvid(dev->pvid)))
+		if ((info = info_from_pvid(dev->pvid, 0)))
 			lvmcache_update_vgname_and_id(info, ORPHAN, ORPHAN,
 						      0, NULL);
 
--- LVM2/lib/report/report.c	2008/01/16 19:00:59	1.72
+++ LVM2/lib/report/report.c	2008/01/29 23:45:48	1.73
@@ -840,7 +840,7 @@
 	uint32_t count;
 	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 
-	info = info_from_pvid(pvid);
+	info = info_from_pvid(pvid, 0);
 	count = info ? list_size(&info->mdas) : 0;
 
 	return _uint32_disp(rh, mem, field, &count, private);
@@ -867,7 +867,7 @@
 	const char *pvid = (const char *)(&((struct id *) data)->uuid);
 	struct metadata_area *mda;
 
-	info = info_from_pvid(pvid);
+	info = info_from_pvid(pvid, 0);
 
 	list_iterate_items(mda, &info->mdas) {
 		if (!mda->ops->mda_free_sectors)


