From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Feb 2012 01:28:32 -0000
Subject: LVM2 lib/cache/lvmcache.c lib/cache/lvmcache.h ...
Message-ID: <20120210012832.22358.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-10 01:28:29

Modified files:
	lib/cache      : lvmcache.c lvmcache.h 
	lib/device     : dev-io.c 
	lib/format1    : disk-rep.c format1.c lvm1-label.c 
	lib/format_pool: disk_rep.c 
	lib/format_text: format-text.c format-text.h import_vsn1.c 
	                 layout.h text_label.c 
	lib/label      : label.c 
	lib/metadata   : metadata.c pv.c vg.c 
	tools          : toollib.c vgrename.c 

Log message:
	Move lvmcache data structures behind an API (making the structures private to
	lvmcache.c). No functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/lvm1-label.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/layout.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.476&r2=1.477
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.239&r2=1.240
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/lib/cache/lvmcache.c	2012/02/08 12:57:15	1.122
+++ LVM2/lib/cache/lvmcache.c	2012/02/10 01:28:27	1.123
@@ -28,6 +28,43 @@
 #include "format1.h"
 #include "config.h"
 
+#define CACHE_INVALID	0x00000001
+#define CACHE_LOCKED	0x00000002
+
+/* One per device */
+struct lvmcache_info {
+	struct dm_list list;	/* Join VG members together */
+	struct dm_list mdas;	/* list head for metadata areas */
+	struct dm_list das;	/* list head for data areas */
+	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
+	struct label *label;
+	const struct format_type *fmt;
+	struct device *dev;
+	uint64_t device_size;	/* Bytes */
+	uint32_t status;
+};
+
+/* One per VG */
+struct lvmcache_vginfo {
+	struct dm_list list;	/* Join these vginfos together */
+	struct dm_list infos;	/* List head for lvmcache_infos */
+	const struct format_type *fmt;
+	char *vgname;		/* "" == orphan */
+	uint32_t status;
+	char vgid[ID_LEN + 1];
+	char _padding[7];
+	struct lvmcache_vginfo *next; /* Another VG with same name? */
+	char *creation_host;
+	size_t vgmetadata_size;
+	char *vgmetadata;	/* Copy of VG metadata as format_text string */
+	struct dm_config_tree *cft; /* Config tree created from vgmetadata */
+				    /* Lifetime is directly tied to vgmetadata */
+	struct volume_group *cached_vg;
+	unsigned holders;
+	unsigned vg_use_count;	/* Counter of vg reusage */
+	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
+};
+
 static struct dm_hash_table *_pvid_hash = NULL;
 static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
@@ -104,7 +141,7 @@
 	char *data;
 	size_t size;
 
-	if (!(vginfo = vginfo_from_vgid((const char *)&vg->id))) {
+	if (!(vginfo = lvmcache_vginfo_from_vgid((const char *)&vg->id))) {
 		stack;
 		return;
 	}
@@ -147,7 +184,7 @@
 	 * Cache becomes invalid whenever lock state changes unless
 	 * exclusive VG_GLOBAL is held (i.e. while scanning).
 	 */
-	if (!vgname_is_locked(VG_GLOBAL) && (was_locked != locked)) {
+	if (!lvmcache_vgname_is_locked(VG_GLOBAL) && (was_locked != locked)) {
 		info->status |= CACHE_INVALID;
 		*cached_vgmetadata_valid = 0;
 	}
@@ -176,7 +213,7 @@
 {
 	struct lvmcache_vginfo *vginfo;
 
-	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
 	_update_cache_vginfo_lock_state(vginfo, locked);
@@ -187,7 +224,7 @@
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 
-	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
 	/*
@@ -220,7 +257,7 @@
 {
 	struct lvmcache_vginfo *vginfo;
 
-	if (!(vginfo = vginfo_from_vgname(vgname, NULL)))
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
 	if (vginfo->precommitted) {
@@ -240,7 +277,7 @@
 
 		/* Indicate that PVs could now be missing from the cache */
 		init_full_scan_done(0);
-	} else if (!vgname_is_locked(VG_GLOBAL))
+	} else if (!lvmcache_vgname_is_locked(VG_GLOBAL))
 		_drop_metadata(vgname, drop_precommitted);
 }
 
@@ -317,7 +354,7 @@
 		_vgs_locked++;
 }
 
-int vgname_is_locked(const char *vgname)
+int lvmcache_vgname_is_locked(const char *vgname)
 {
 	if (!_lock_hash)
 		return 0;
@@ -340,7 +377,7 @@
 		dev_close_all();
 }
 
-int vgs_locked(void)
+int lvmcache_vgs_locked(void)
 {
 	return _vgs_locked;
 }
@@ -366,12 +403,12 @@
 }
 
 /* If vgid supplied, require a match. */
-struct lvmcache_vginfo *vginfo_from_vgname(const char *vgname, const char *vgid)
+struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 
 	if (!vgname)
-		return vginfo_from_vgid(vgid);
+		return lvmcache_vginfo_from_vgid(vgid);
 
 	if (!_vgname_hash)
 		return NULL;
@@ -388,7 +425,7 @@
 	return vginfo;
 }
 
-const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels)
+const struct format_type *lvmcache_fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -398,7 +435,7 @@
 	struct device_list *devl;
 	char vgid_found[ID_LEN + 1] __attribute__((aligned(8)));
 
-	if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
 		return NULL;
 
 	/*
@@ -431,7 +468,7 @@
 	}
 
 	/* If vginfo changed, caller needs to rescan */
-	if (!(vginfo = vginfo_from_vgname(vgname, vgid_found)) ||
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid_found)) ||
 	    strncmp(vginfo->vgid, vgid_found, ID_LEN))
 		return NULL;
 
@@ -439,7 +476,7 @@
 	return vginfo->fmt;
 }
 
-struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid)
+struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 	char id[ID_LEN + 1] __attribute__((aligned(8)));
@@ -457,12 +494,12 @@
 	return vginfo;
 }
 
-const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid)
+const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 	const char *vgname = NULL;
 
-	if ((vginfo = vginfo_from_vgid(vgid)))
+	if ((vginfo = lvmcache_vginfo_from_vgid(vgid)))
 		vgname = vginfo->vgname;
 
 	if (mem && vgname)
@@ -483,7 +520,7 @@
 	 * So if the VG appears to be unlocked here, it should be safe
 	 * to use the cached value.
 	 */
-	if (info->vginfo && !vgname_is_locked(info->vginfo->vgname))
+	if (info->vginfo && !lvmcache_vgname_is_locked(info->vginfo->vgname))
 		return 1;
 
 	if (!(info->status & CACHE_LOCKED))
@@ -520,7 +557,7 @@
  * If valid_only is set, data will only be returned if the cached data is
  * known still to be valid.
  */
-struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only)
+struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only)
 {
 	struct lvmcache_info *info;
 	char id[ID_LEN + 1] __attribute__((aligned(8)));
@@ -545,12 +582,12 @@
 	struct lvmcache_info *info;
 	char *vgname;
 
-	if (!device_from_pvid(cmd, (const struct id *)pvid, NULL, NULL)) {
+	if (!lvmcache_device_from_pvid(cmd, (const struct id *)pvid, NULL, NULL)) {
 		log_error("Couldn't find device with uuid %s.", pvid);
 		return NULL;
 	}
 
-	info = info_from_pvid(pvid, 0);
+	info = lvmcache_info_from_pvid(pvid, 0);
 	if (!info)
 		return_NULL;
 
@@ -644,7 +681,7 @@
 	struct format_instance *fid;
 	struct format_instance_ctx fic;
 
-	if (!vgid || !(vginfo = vginfo_from_vgid(vgid)) || !vginfo->vgmetadata)
+	if (!vgid || !(vginfo = lvmcache_vginfo_from_vgid(vgid)) || !vginfo->vgmetadata)
 		return NULL;
 
 	if (!_vginfo_is_valid(vginfo))
@@ -708,7 +745,8 @@
 	return NULL;
 }
 
-int vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo)
+// #if 0
+int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo)
 {
 	log_debug("VG %s decrementing %d holder(s) at %p.",
 		  vginfo->cached_vg->name, vginfo->holders, vginfo->cached_vg);
@@ -731,6 +769,7 @@
 
 	return 1;
 }
+// #endif
 
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal)
@@ -798,7 +837,7 @@
 		return NULL;
 	}
 
-	if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid)))
 		return pvids;
 
 	dm_list_iterate_items(info, &vginfo->infos) {
@@ -818,7 +857,7 @@
 	struct lvmcache_info *info;
 	struct label *label;
 
-	if ((info = info_from_pvid((const char *) pvid, 0))) {
+	if ((info = lvmcache_info_from_pvid((const char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid)) {
@@ -831,7 +870,7 @@
 	return NULL;
 }
 
-struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
+struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once, uint64_t *label_sector)
 {
 	struct device *dev;
@@ -863,7 +902,7 @@
 	return NULL;
 }
 
-const char *pvid_from_devname(struct cmd_context *cmd,
+const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 			      const char *devname)
 {
 	struct device *dev;
@@ -889,7 +928,7 @@
 
 	_free_cached_vgmetadata(vginfo);
 
-	vginfo2 = primary_vginfo = vginfo_from_vgname(vginfo->vgname, NULL);
+	vginfo2 = primary_vginfo = lvmcache_vginfo_from_vgname(vginfo->vgname, NULL);
 
 	if (vginfo == primary_vginfo) {
 		dm_hash_remove(_vgname_hash, vginfo->vgname);
@@ -910,7 +949,7 @@
 	dm_free(vginfo->creation_host);
 
 	if (*vginfo->vgid && _vgid_hash &&
-	    vginfo_from_vgid(vginfo->vgid) == vginfo)
+	    lvmcache_vginfo_from_vgid(vginfo->vgid) == vginfo)
 		dm_hash_remove(_vgid_hash, vginfo->vgid);
 
 	dm_list_del(&vginfo->list);
@@ -959,6 +998,7 @@
 	/*
 	 * Nothing to do if already stored with same pvid.
 	 */
+
 	if (((dm_hash_lookup(_pvid_hash, pvid)) == info) &&
 	    !strcmp(info->dev->pvid, pvid))
 		return 1;
@@ -1110,7 +1150,7 @@
 		_drop_vginfo(info, info->vginfo);
 
 	/* Get existing vginfo or create new one */
-	if (!(vginfo = vginfo_from_vgname(vgname, vgid))) {
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
 /*** FIXME - vginfo ends up duplicated instead of renamed.
 		// Renaming?  This lookup fails.
 		if ((vginfo = vginfo_from_vgid(vgid))) {
@@ -1162,9 +1202,9 @@
 		 * If we're scanning and there's an invalidated entry, remove it.
 		 * Otherwise we risk bogus warnings of duplicate VGs.
 		 */
-		while ((primary_vginfo = vginfo_from_vgname(vgname, NULL)) &&
+		while ((primary_vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)) &&
 		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo)) {
-			orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
+			orphan_vginfo = lvmcache_vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
 			if (!orphan_vginfo) {
 				log_error(INTERNAL_ERROR "Orphan vginfo %s lost from cache.",
 					  primary_vginfo->fmt->orphan_vg_name);
@@ -1212,7 +1252,7 @@
 	else if (!_lvmcache_update_vgid(NULL, vginfo, vgid)) /* Orphans */
 		return_0;
 
-	_update_cache_vginfo_lock_state(vginfo, vgname_is_locked(vgname));
+	_update_cache_vginfo_lock_state(vginfo, lvmcache_vgname_is_locked(vgname));
 
 	/* FIXME Check consistency of list! */
 	vginfo->fmt = fmt;
@@ -1282,6 +1322,8 @@
 				  const char *vgname, const char *vgid,
 				  uint32_t vgstatus, const char *creation_host)
 {
+        log_error("lvmcache_update_vgname_and_id: %s -> %s", dev_name(info->dev), vgname);
+
 	if (!vgname && !info->vginfo) {
 		log_error(INTERNAL_ERROR "NULL vgname handed to cache");
 		/* FIXME Remove this */
@@ -1319,7 +1361,7 @@
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s) - 1);
 		/* FIXME Could pvl->pv->dev->pvid ever be different? */
-		if ((info = info_from_pvid(pvid_s, 0)) &&
+		if ((info = lvmcache_info_from_pvid(pvid_s, 0)) &&
 		    !lvmcache_update_vgname_and_id(info, vg->name,
 						   (char *) &vg->id,
 						   vg->status, NULL))
@@ -1350,8 +1392,8 @@
 	strncpy(pvid_s, pvid, sizeof(pvid_s) - 1);
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
 
-	if (!(existing = info_from_pvid(pvid_s, 0)) &&
-	    !(existing = info_from_pvid(dev->pvid, 0))) {
+	if (!(existing = lvmcache_info_from_pvid(pvid_s, 0)) &&
+	    !(existing = lvmcache_info_from_pvid(dev->pvid, 0))) {
 		if (!(label = label_create(labeller)))
 			return_NULL;
 		if (!(info = dm_zalloc(sizeof(*info)))) {
@@ -1520,3 +1562,259 @@
 	if (retain_orphans)
 		init_lvmcache_orphans(cmd);
 }
+
+int lvmcache_pvid_is_locked(const char *pvid) {
+	struct lvmcache_info *info;
+	info = lvmcache_info_from_pvid(pvid, 0);
+	if (!info || !info->vginfo)
+		return 0;
+
+	return lvmcache_vgname_is_locked(info->vginfo->vgname);
+}
+
+int lvmcache_fid_add_mdas(struct lvmcache_info *info, struct format_instance *fid,
+			  const char *id, int id_len)
+{
+	return fid_add_mdas(fid, &info->mdas, id, id_len);
+}
+
+int lvmcache_fid_add_mdas_pv(struct lvmcache_info *info, struct format_instance *fid)
+{
+	return lvmcache_fid_add_mdas(info, fid, info->dev->pvid, ID_LEN);
+}
+
+int lvmcache_fid_add_mdas_vg(struct lvmcache_vginfo *vginfo, struct format_instance *fid)
+{
+	struct lvmcache_info *info;
+	dm_list_iterate_items(info, &vginfo->infos) {
+		if (!lvmcache_fid_add_mdas_pv(info, fid))
+			return_0;
+	}
+	return 1;
+}
+
+static int _get_pv_if_in_vg(struct lvmcache_info *info,
+			    struct physical_volume *pv)
+{
+	char vgname[NAME_LEN + 1];
+	char vgid[ID_LEN + 1];
+
+	if (info->vginfo && info->vginfo->vgname &&
+	    !is_orphan_vg(info->vginfo->vgname)) {
+		/*
+		 * get_pv_from_vg_by_id() may call
+		 * lvmcache_label_scan() and drop cached
+		 * vginfo so make a local copy of string.
+		 */
+		strcpy(vgname, info->vginfo->vgname);
+		memcpy(vgid, info->vginfo->vgid, sizeof(vgid));
+
+		if (get_pv_from_vg_by_id(info->fmt, vgname, vgid,
+					 info->dev->pvid, pv))
+			return 1;
+	}
+
+	return 0;
+}
+
+int lvmcache_populate_pv_fields(struct lvmcache_info *info,
+				struct physical_volume *pv,
+				int scan_label_only)
+{
+	struct data_area_list *da;
+
+	/* Have we already cached vgname? */
+	if (!scan_label_only && _get_pv_if_in_vg(info, pv))
+		return 1;
+
+	/* Perform full scan (just the first time) and try again */
+	if (!scan_label_only && !critical_section() && !full_scan_done()) {
+		lvmcache_label_scan(info->fmt->cmd, 2);
+
+		if (_get_pv_if_in_vg(info, pv))
+			return 1;
+	}
+
+	/* Orphan */
+	pv->dev = info->dev;
+	pv->fmt = info->fmt;
+	pv->size = info->device_size >> SECTOR_SHIFT;
+	pv->vg_name = FMT_TEXT_ORPHAN_VG_NAME;
+	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
+
+	/* Currently only support exactly one data area */
+	if (dm_list_size(&info->das) != 1) {
+		log_error("Must be exactly one data area (found %d) on PV %s",
+			  dm_list_size(&info->das), dev_name(info->dev));
+		return 0;
+	}
+
+	dm_list_iterate_items(da, &info->das)
+		pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
+
+	return 1;
+}
+
+int lvmcache_check_format(struct lvmcache_info *info, const struct format_type *fmt)
+{
+	if (info->fmt != fmt) {
+		log_error("PV %s is a different format (seqno %s)",
+			  dev_name(info->dev), info->fmt->name);
+		return 0;
+	}
+	return 1;
+}
+
+void lvmcache_del_mdas(struct lvmcache_info *info)
+{
+	if (info->mdas.n)
+		del_mdas(&info->mdas);
+	dm_list_init(&info->mdas);
+}
+
+void lvmcache_del_das(struct lvmcache_info *info)
+{
+	if (info->das.n)
+		del_das(&info->das);
+	dm_list_init(&info->das);
+}
+
+int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
+		     uint64_t start, uint64_t size, unsigned ignored)
+{
+	return add_mda(info->fmt, NULL, &info->mdas, dev, start, size, ignored);
+}
+
+int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size)
+{
+	return add_da(NULL, &info->das, start, size);
+}
+
+
+void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
+			const struct format_type *fmt)
+{
+	info->device_size = pv->size << SECTOR_SHIFT;
+	info->fmt = fmt;
+}
+
+int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv)
+{
+	struct data_area_list *da;
+	if (info->das.n) {
+		if (!pv->pe_start)
+			dm_list_iterate_items(da, &info->das)
+				pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
+		del_das(&info->das);
+	} else
+		dm_list_init(&info->das);
+
+	if (!add_da(NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
+		return_0;
+
+	return 1;
+}
+
+int lvmcache_foreach_pv(struct lvmcache_vginfo *vginfo,
+			int (*fun)(struct lvmcache_info *, void *),
+			void *baton)
+{
+	struct lvmcache_info *info;
+	dm_list_iterate_items(info, &vginfo->infos) {
+		if (!fun(info, baton))
+			return_0;
+	}
+
+	return 1;
+}
+
+int lvmcache_foreach_mda(struct lvmcache_info *info,
+			 int (*fun)(struct metadata_area *, void *),
+			 void *baton)
+{
+	struct metadata_area *mda;
+	dm_list_iterate_items(mda, &info->mdas) {
+		if (!fun(mda, baton))
+			return_0;
+	}
+
+	return 1;
+}
+
+int lvmcache_mda_count(struct lvmcache_info *info)
+{
+	return dm_list_size(&info->mdas);
+}
+
+int lvmcache_foreach_da(struct lvmcache_info *info,
+			int (*fun)(struct data_area_list *, void *),
+			void *baton)
+{
+	struct data_area_list *da;
+	dm_list_iterate_items(da, &info->das) {
+		if (!fun(da, baton))
+			return_0;
+	}
+
+	return 1;
+}
+
+/*
+ * The lifetime of the label returned is tied to the lifetime of the
+ * lvmcache_info which is the same as lvmcache itself.
+ */
+struct label *lvmcache_get_label(struct lvmcache_info *info) {
+	return info->label;
+}
+
+void lvmcache_make_valid(struct lvmcache_info *info) {
+	info->status &= ~CACHE_INVALID;
+}
+
+uint64_t lvmcache_device_size(struct lvmcache_info *info) {
+	return info->device_size;
+}
+
+void lvmcache_set_device_size(struct lvmcache_info *info, uint64_t size) {
+	info->device_size = size;
+}
+
+struct device *lvmcache_device(struct lvmcache_info *info) {
+	return info->dev;
+}
+
+int lvmcache_is_orphan(struct lvmcache_info *info) {
+	if (!info->vginfo)
+		return 1; /* FIXME? */
+	return is_orphan_vg(info->vginfo->vgname);
+}
+
+int lvmcache_vgid_is_cached(const char *vgid) {
+	struct lvmcache_vginfo *vginfo;
+	vginfo = lvmcache_vginfo_from_vgid(vgid);
+
+	if (!vginfo || !vginfo->vgname)
+		return 0;
+
+	if (is_orphan_vg(vginfo->vgname))
+		return 0;
+
+	return 1;
+}
+
+/*
+ * Return true iff it is impossible to find out from this info alone whether the
+ * PV in question is or is not an orphan.
+ */
+int lvmcache_uncertain_ownership(struct lvmcache_info *info) {
+	return mdas_empty_or_ignored(&info->mdas);
+}
+
+int lvmcache_smallest_mda_size(struct lvmcache_info *info)
+{
+	return find_min_mda_size(&info->mdas);
+}
+
+const struct format_type *lvmcache_fmt(struct lvmcache_info *info) {
+	return info->fmt;
+}
--- LVM2/lib/cache/lvmcache.h	2011/08/30 14:55:16	1.41
+++ LVM2/lib/cache/lvmcache.h	2012/02/10 01:28:27	1.42
@@ -24,50 +24,19 @@
 #define ORPHAN_PREFIX VG_ORPHANS
 #define ORPHAN_VG_NAME(fmt) ORPHAN_PREFIX "_" fmt
 
-#define CACHE_INVALID	0x00000001
-#define CACHE_LOCKED	0x00000002
-
 /* LVM specific per-volume info */
 /* Eventual replacement for struct physical_volume perhaps? */
 
 struct cmd_context;
 struct format_type;
 struct volume_group;
+struct physical_volume;
 struct dm_config_tree;
+struct format_instance;
+struct metadata_area;
+struct data_area_list;
 
-/* One per VG */
-struct lvmcache_vginfo {
-	struct dm_list list;	/* Join these vginfos together */
-	struct dm_list infos;	/* List head for lvmcache_infos */
-	const struct format_type *fmt;
-	char *vgname;		/* "" == orphan */
-	uint32_t status;
-	char vgid[ID_LEN + 1];
-	char _padding[7];
-	struct lvmcache_vginfo *next; /* Another VG with same name? */
-	char *creation_host;
-	size_t vgmetadata_size;
-	char *vgmetadata;	/* Copy of VG metadata as format_text string */
-	struct dm_config_tree *cft; /* Config tree created from vgmetadata */
-				    /* Lifetime is directly tied to vgmetadata */
-	struct volume_group *cached_vg;
-	unsigned holders;
-	unsigned vg_use_count;	/* Counter of vg reusage */
-	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
-};
-
-/* One per device */
-struct lvmcache_info {
-	struct dm_list list;	/* Join VG members together */
-	struct dm_list mdas;	/* list head for metadata areas */
-	struct dm_list das;	/* list head for data areas */
-	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
-	struct label *label;
-	const struct format_type *fmt;
-	struct device *dev;
-	uint64_t device_size;	/* Bytes */
-	uint32_t status;
-};
+struct lvmcache_vginfo;
 
 int lvmcache_init(void);
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans);
@@ -95,21 +64,23 @@
 int lvmcache_verify_lock_order(const char *vgname);
 
 /* Queries */
-const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels);
+const struct format_type *lvmcache_fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels);
+
 /* Decrement and test if there are still vg holders in vginfo. */
-int vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo);
-struct lvmcache_vginfo *vginfo_from_vgname(const char *vgname,
+int lvmcache_vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo);
+
+struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
-struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
-struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
-const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
-struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
+struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid);
+struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid, int valid_only);
+const char *lvmcache_vgname_from_vgid(struct dm_pool *mem, const char *vgid);
+struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once, uint64_t *label_sector);
-const char *pvid_from_devname(struct cmd_context *cmd,
+const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 			      const char *dev_name);
 char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
-int vgs_locked(void);
-int vgname_is_locked(const char *vgname);
+int lvmcache_vgs_locked(void);
+int lvmcache_vgname_is_locked(const char *vgname);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgnames */
 /* If include_internal is not set, return only proper vg names. */
@@ -130,4 +101,46 @@
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted);
 void lvmcache_commit_metadata(const char *vgname);
 
+int lvmcache_pvid_is_locked(const char *pvid);
+int lvmcache_fid_add_mdas(struct lvmcache_info *info, struct format_instance *fid,
+			  const char *id, int id_len);
+int lvmcache_fid_add_mdas_pv(struct lvmcache_info *info, struct format_instance *fid);
+int lvmcache_fid_add_mdas_vg(struct lvmcache_vginfo *vginfo, struct format_instance *fid);
+int lvmcache_populate_pv_fields(struct lvmcache_info *info,
+				struct physical_volume *pv,
+				int scan_label_only);
+int lvmcache_check_format(struct lvmcache_info *info, const struct format_type *fmt);
+void lvmcache_del_mdas(struct lvmcache_info *info);
+void lvmcache_del_das(struct lvmcache_info *info);
+int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
+		     uint64_t start, uint64_t size, unsigned ignored);
+int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size);
+
+const struct format_type *lvmcache_fmt(struct lvmcache_info *info);
+struct label *lvmcache_get_label(struct lvmcache_info *info);
+
+void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
+			const struct format_type *fmt);
+int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv);
+int lvmcache_foreach_mda(struct lvmcache_info *info,
+			 int (*fun)(struct metadata_area *, void *),
+			 void *baton);
+
+int lvmcache_foreach_da(struct lvmcache_info *info,
+			int (*fun)(struct data_area_list *, void *),
+			void *baton);
+
+int lvmcache_foreach_pv(struct lvmcache_vginfo *vg,
+			int (*fun)(struct lvmcache_info *, void *), void * baton);
+
+uint64_t lvmcache_device_size(struct lvmcache_info *info);
+void lvmcache_set_device_size(struct lvmcache_info *info, uint64_t size);
+struct device *lvmcache_device(struct lvmcache_info *info);
+void lvmcache_make_valid(struct lvmcache_info *info);
+int lvmcache_is_orphan(struct lvmcache_info *info);
+int lvmcache_uncertain_ownership(struct lvmcache_info *info);
+int lvmcache_mda_count(struct lvmcache_info *info);
+int lvmcache_vgid_is_cached(const char *vgid);
+int lvmcache_smallest_mda_size(struct lvmcache_info *info);
+
 #endif
--- LVM2/lib/device/dev-io.c	2012/02/08 11:15:38	1.80
+++ LVM2/lib/device/dev-io.c	2012/02/10 01:28:27	1.81
@@ -586,7 +586,6 @@
 
 static int _dev_close(struct device *dev, int immediate)
 {
-	struct lvmcache_info *info;
 
 	if (dev->fd < 0) {
 		log_error("Attempt to close device '%s' "
@@ -608,10 +607,7 @@
 
 	/* Close unless device is known to belong to a locked VG */
 	if (immediate ||
-	    (dev->open_count < 1 &&
-	     (!(info = info_from_pvid(dev->pvid, 0)) ||
-	      !info->vginfo ||
-	      !vgname_is_locked(info->vginfo->vgname))))
+	    (dev->open_count < 1 && !lvmcache_pvid_is_locked(dev->pvid)))
 		_close(dev);
 
 	return 1;
--- LVM2/lib/format1/disk-rep.c	2011/05/28 09:48:15	1.84
+++ LVM2/lib/format1/disk-rep.c	2012/02/10 01:28:28	1.85
@@ -335,9 +335,9 @@
 		return;
 	}
 
-	info->device_size = xlate32(dl->pvd.pv_size) << SECTOR_SHIFT;
-	dm_list_init(&info->mdas);
-	info->status &= ~CACHE_INVALID;
+	lvmcache_set_device_size(info, xlate32(dl->pvd.pv_size) << SECTOR_SHIFT);
+	lvmcache_del_mdas(info);
+	lvmcache_make_valid(info);
 }
 
 static struct disk_list *__read_disk(const struct format_type *fmt,
@@ -451,6 +451,28 @@
 	dm_list_add(head, &data->list);
 }
 
+struct _read_pvs_in_vg_baton {
+	const char *vg_name;
+	struct dm_list *head;
+	struct disk_list *data;
+	struct dm_pool *mem;
+	int empty;
+};
+
+static int _read_pv_in_vg(struct lvmcache_info *info, void *baton)
+{
+	struct _read_pvs_in_vg_baton *b = baton;
+
+	b->empty = 0;
+
+	if (!lvmcache_device(info) ||
+	    !(b->data = read_disk(lvmcache_fmt(info), lvmcache_device(info), b->mem, b->vg_name)))
+		return 0; /* stop here */
+
+	_add_pv_to_list(b->head, b->data);
+	return 1;
+}
+
 /*
  * Build a list of pv_d's structures, allocated from mem.
  * We keep track of the first object allocated from the pool
@@ -462,29 +484,31 @@
 {
 	struct dev_iter *iter;
 	struct device *dev;
-	struct disk_list *data = NULL;
 	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info;
+	struct _read_pvs_in_vg_baton baton;
+
+	baton.head = head;
+	baton.empty = 1;
+	baton.data = NULL;
+	baton.mem = mem;
+	baton.vg_name = vg_name;
 
 	/* Fast path if we already saw this VG and cached the list of PVs */
-	if (vg_name && (vginfo = vginfo_from_vgname(vg_name, NULL)) &&
-	    vginfo->infos.n) {
-		dm_list_iterate_items(info, &vginfo->infos) {
-			dev = info->dev;
-			if (!dev || !(data = read_disk(fmt, dev, mem, vg_name)))
-				break;
-			_add_pv_to_list(head, data);
-		}
+	if (vg_name && (vginfo = lvmcache_vginfo_from_vgname(vg_name, NULL))) {
+
+		lvmcache_foreach_pv(vginfo, _read_pv_in_vg, &baton);
 
-		/* Did we find the whole VG? */
-		if (!vg_name || is_orphan_vg(vg_name) ||
-		    (data && *data->pvd.vg_name &&
-		     dm_list_size(head) == data->vgd.pv_cur))
-			return 1;
-
-		/* Failed */
-		dm_list_init(head);
-		/* vgcache_del(vg_name); */
+		if (!baton.empty) {
+			/* Did we find the whole VG? */
+			if (!vg_name || is_orphan_vg(vg_name) ||
+			    (baton.data && *baton.data->pvd.vg_name &&
+			     dm_list_size(head) == baton.data->vgd.pv_cur))
+				return 1;
+
+			/* Failed */
+			dm_list_init(head);
+			/* vgcache_del(vg_name); */
+		}
 	}
 
 	if (!(iter = dev_iter_create(filter, 1))) {
@@ -494,8 +518,8 @@
 
 	/* Otherwise do a complete scan */
 	for (dev = dev_iter_get(iter); dev; dev = dev_iter_get(iter)) {
-		if ((data = read_disk(fmt, dev, mem, vg_name))) {
-			_add_pv_to_list(head, data);
+		if ((baton.data = read_disk(fmt, dev, mem, vg_name))) {
+			_add_pv_to_list(head, baton.data);
 		}
 	}
 	dev_iter_destroy(iter);
--- LVM2/lib/format1/format1.c	2012/02/08 10:49:36	1.140
+++ LVM2/lib/format1/format1.c	2012/02/10 01:28:28	1.141
@@ -413,10 +413,8 @@
 				  pv->vg_name, NULL, 0)))
 		return_0;
 
-	info->device_size = pv->size << SECTOR_SHIFT;
-	info->fmt = fmt;
-
-	dm_list_init(&info->mdas);
+	lvmcache_update_pv(info, pv, fmt);
+	lvmcache_del_mdas(info);
 
 	dm_list_init(&pvs);
 
--- LVM2/lib/format1/lvm1-label.c	2010/07/09 15:34:44	1.23
+++ LVM2/lib/format1/lvm1-label.c	2012/02/10 01:28:28	1.24
@@ -77,12 +77,11 @@
 	if (!(info = lvmcache_add(l, (char *)pvd->pv_uuid, dev, vgname, vgid,
 				  exported)))
 		return_0;
-	*label = info->label;
+	*label = lvmcache_get_label(info);
 
-	info->device_size = xlate32(pvd->pv_size) << SECTOR_SHIFT;
-	dm_list_init(&info->mdas);
-
-	info->status &= ~CACHE_INVALID;
+	lvmcache_set_device_size(info, xlate32(pvd->pv_size) << SECTOR_SHIFT);
+	lvmcache_del_mdas(info);
+	lvmcache_make_valid(info);
 
 	return 1;
 }
--- LVM2/lib/format_pool/disk_rep.c	2011/05/28 09:48:15	1.19
+++ LVM2/lib/format_pool/disk_rep.c	2012/02/10 01:28:28	1.20
@@ -101,12 +101,11 @@
 				  (char *) &vgid, 0)))
 		return_0;
 	if (label)
-		*label = info->label;
+		*label = lvmcache_get_label(info);
 
-	info->device_size = xlate32_be(pd->pl_blocks) << SECTOR_SHIFT;
-	dm_list_init(&info->mdas);
-
-	info->status &= ~CACHE_INVALID;
+	lvmcache_set_device_size(info, xlate32_be(pd->pl_blocks) << SECTOR_SHIFT);
+	lvmcache_del_mdas(info);
+	lvmcache_make_valid(info);
 
 	pl->dev = dev;
 	pl->pv = NULL;
@@ -236,68 +235,92 @@
 
 }
 
-static int _read_vg_pds(const struct format_type *fmt, struct dm_pool *mem,
-			struct lvmcache_vginfo *vginfo, struct dm_list *head,
-			uint32_t *devcount)
+struct _read_pool_pv_baton {
+	const struct format_type *fmt;
+	struct dm_pool *mem, *tmpmem;
+	struct pool_list *pl;
+	struct dm_list *head;
+	const char *vgname;
+	uint32_t *sp_devs;
+	int sp_count;
+	int failed;
+	int empty;
+};
+
+static int _read_pool_pv(struct lvmcache_info *info, void *baton)
 {
-	struct lvmcache_info *info;
-	struct pool_list *pl = NULL;
-	struct dm_pool *tmpmem;
+	struct _read_pool_pv_baton *b = baton;
+
+	b->empty = 0;
+
+	if (lvmcache_device(info) &&
+	    !(b->pl = read_pool_disk(b->fmt, lvmcache_device(info), b->mem, b->vgname)))
+		return 0;
+
+	/*
+	 * We need to keep track of the total expected number
+	 * of devices per subpool
+	 */
+	if (!b->sp_count) {
+		/* FIXME pl left uninitialised if !info->dev */
+		if (!b->pl) {
+			log_error(INTERNAL_ERROR "device is missing");
+			dm_pool_destroy(b->tmpmem);
+			b->failed = 1;
+			return 0;
+		}
+		b->sp_count = b->pl->pd.pl_subpools;
+		if (!(b->sp_devs =
+		      dm_pool_zalloc(b->tmpmem,
+				     sizeof(uint32_t) * b->sp_count))) {
+			log_error("Unable to allocate %d 32-bit uints",
+				  b->sp_count);
+			dm_pool_destroy(b->tmpmem);
+			b->failed = 1;
+			return 0;
+		}
+	}
+
+	/*
+	 * watch out for a pool label with a different subpool
+	 * count than the original - give up if it does
+	 */
+	if (b->sp_count != b->pl->pd.pl_subpools)
+		return 0;
+
+	_add_pl_to_list(b->head, b->pl);
 
-	uint32_t sp_count = 0;
-	uint32_t *sp_devs = NULL;
+	if (b->sp_count > b->pl->pd.pl_sp_id && b->sp_devs[b->pl->pd.pl_sp_id] == 0)
+		b->sp_devs[b->pl->pd.pl_sp_id] = b->pl->pd.pl_sp_devs;
+
+	return 1;
+}
+
+static int _read_vg_pds(struct _read_pool_pv_baton *b,
+			struct lvmcache_vginfo *vginfo,
+			uint32_t *devcount)
+{
 	uint32_t i;
 
+	b->sp_count = 0;
+	b->sp_devs = NULL;
+	b->failed = 0;
+	b->pl = NULL;
+
 	/* FIXME: maybe should return a different error in memory
 	 * allocation failure */
-	if (!(tmpmem = dm_pool_create("pool read_vg", 512)))
+	if (!(b->tmpmem = dm_pool_create("pool read_vg", 512)))
 		return_0;
 
-	dm_list_iterate_items(info, &vginfo->infos) {
-		if (info->dev &&
-		    !(pl = read_pool_disk(fmt, info->dev, mem, vginfo->vgname)))
-			    break;
-		/*
-		 * We need to keep track of the total expected number
-		 * of devices per subpool
-		 */
-		if (!sp_count) {
-			/* FIXME pl left uninitialised if !info->dev */
-			if (!pl) {
-				log_error(INTERNAL_ERROR "device is missing");
-				dm_pool_destroy(tmpmem);
-				return 0;
-			}
-			sp_count = pl->pd.pl_subpools;
-			if (!(sp_devs =
-			      dm_pool_zalloc(tmpmem,
-					  sizeof(uint32_t) * sp_count))) {
-				log_error("Unable to allocate %d 32-bit uints",
-					  sp_count);
-				dm_pool_destroy(tmpmem);
-				return 0;
-			}
-		}
-		/*
-		 * watch out for a pool label with a different subpool
-		 * count than the original - give up if it does
-		 */
-		if (sp_count != pl->pd.pl_subpools)
-			break;
-
-		_add_pl_to_list(head, pl);
-
-		if (sp_count > pl->pd.pl_sp_id && sp_devs[pl->pd.pl_sp_id] == 0)
-			sp_devs[pl->pd.pl_sp_id] = pl->pd.pl_sp_devs;
-	}
+	lvmcache_foreach_pv(vginfo, _read_pool_pv, b);
 
 	*devcount = 0;
-	for (i = 0; i < sp_count; i++)
-		*devcount += sp_devs[i];
+	for (i = 0; i < b->sp_count; i++)
+		*devcount += b->sp_devs[i];
 
-	dm_pool_destroy(tmpmem);
+	dm_pool_destroy(b->tmpmem);
 
-	if (pl && *pl->pd.pl_pool_name)
+	if (b->pl && *b->pl->pd.pl_pool_name)
 		return 1;
 
 	return 0;
@@ -311,29 +334,36 @@
 	uint32_t totaldevs;
 	int full_scan = -1;
 
+	struct _read_pool_pv_baton baton;
+
+	baton.vgname = vg_name;
+	baton.mem = mem;
+	baton.fmt = fmt;
+	baton.head = pdhead;
+	baton.empty = 1;
+
 	do {
 		/*
 		 * If the cache scanning doesn't work, this will never work
 		 */
-		if (vg_name && (vginfo = vginfo_from_vgname(vg_name, NULL)) &&
-		    vginfo->infos.n) {
-
-			if (_read_vg_pds(fmt, mem, vginfo, pdhead, &totaldevs)) {
-				/*
-				 * If we found all the devices we were
-				 * expecting, return success
-				 */
-				if (dm_list_size(pdhead) == totaldevs)
-					return 1;
-
-				/*
-				 * accept partial pool if we've done a full
-				 * rescan of the cache
-				 */
-				if (full_scan > 0)
-					return 1;
-			}
+		if (vg_name && (vginfo = lvmcache_vginfo_from_vgname(vg_name, NULL)) &&
+		    _read_vg_pds(&baton, vginfo, &totaldevs) && !baton.empty)
+		{
+			/*
+			 * If we found all the devices we were expecting, return
+			 * success
+			 */
+			if (dm_list_size(pdhead) == totaldevs)
+				return 1;
+
+			/*
+			 * accept partial pool if we've done a full rescan of
+			 * the cache
+			 */
+			if (full_scan > 0)
+				return 1;
 		}
+
 		/* Failed */
 		dm_list_init(pdhead);
 
--- LVM2/lib/format_text/format-text.c	2012/02/08 10:49:36	1.187
+++ LVM2/lib/format_text/format-text.c	2012/02/10 01:28:28	1.188
@@ -432,7 +432,7 @@
 			  "not match expected name %s.", vgname);
 
       bad:
-	if ((info = info_from_pvid(dev_area->dev->pvid, 0)))
+	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, 0)))
 		lvmcache_update_vgname_and_id(info, FMT_TEXT_ORPHAN_VG_NAME,
 					      FMT_TEXT_ORPHAN_VG_NAME, 0, NULL);
 
@@ -1251,6 +1251,33 @@
 	return (_scan_file(fmt, vgname) & _scan_raw(fmt, vgname));
 }
 
+struct _write_single_mda_baton {
+	const struct format_type *fmt;
+	struct physical_volume *pv;
+};
+
+static int _write_single_mda(struct metadata_area *mda, void *baton)
+{
+	struct _write_single_mda_baton *p = baton;
+	struct mda_context *mdac;
+
+	char buf[MDA_HEADER_SIZE] __attribute__((aligned(8)));
+	struct mda_header *mdah = (struct mda_header *) buf;
+
+	mdac = mda->metadata_locn;
+	memset(&buf, 0, sizeof(buf));
+	mdah->size = mdac->area.size;
+	rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
+
+	if (!_raw_write_mda_header(p->fmt, mdac->area.dev,
+				   mdac->area.start, mdah)) {
+		if (!dev_close(p->pv->dev))
+			stack;
+		return_0;
+	}
+	return 1;
+}
+
 /* Only for orphans */
 static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv)
 {
@@ -1260,27 +1287,21 @@
 	struct lvmcache_info *info;
 	struct mda_context *mdac;
 	struct metadata_area *mda;
+	struct _write_single_mda_baton baton;
 	unsigned mda_index;
-	char buf[MDA_HEADER_SIZE] __attribute__((aligned(8)));
-	struct mda_header *mdah = (struct mda_header *) buf;
-	struct data_area_list *da;
 
 	/* Add a new cache entry with PV info or update existing one. */
 	if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,
 				  pv->dev, pv->vg_name, NULL, 0)))
 		return_0;
 
-	label = info->label;
+	label = lvmcache_get_label(info);
 	label->sector = pv->label_sector;
 
-	info->device_size = pv->size << SECTOR_SHIFT;
-	info->fmt = fmt;
+	lvmcache_update_pv(info, pv, fmt);
 
 	/* Flush all cached metadata areas, we will reenter new/modified ones. */
-	if (info->mdas.n)
-		del_mdas(&info->mdas);
-	else
-		dm_list_init(&info->mdas);
+	lvmcache_del_mdas(info);
 
 	/*
 	 * Add all new or modified metadata areas for this PV stored in
@@ -1299,8 +1320,10 @@
 			  dev_name(mdac->area.dev),
 			  mdac->area.start >> SECTOR_SHIFT,
 			  mdac->area.size >> SECTOR_SHIFT);
-		add_mda(fmt, NULL, &info->mdas, mdac->area.dev,
-			mdac->area.start, mdac->area.size, mda_is_ignored(mda));
+
+		// if fmt is not the same as info->fmt we are in trouble
+		lvmcache_add_mda(info, mdac->area.dev,
+				 mdac->area.start, mdac->area.size, mda_is_ignored(mda));
 	}
 
 	/*
@@ -1318,34 +1341,20 @@
 	 * pvcreate --restorefile. However, we can can have this value in
 	 * metadata which will override the value in the PV header.
 	 */
-	if (info->das.n) {
-		if (!pv->pe_start)
-			dm_list_iterate_items(da, &info->das)
-				pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
-		del_das(&info->das);
-	} else
-		dm_list_init(&info->das);
 
-	if (!add_da(NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
+	if (!lvmcache_update_das(info, pv))
 		return_0;
 
 	if (!dev_open(pv->dev))
 		return_0;
 
-	dm_list_iterate_items(mda, &info->mdas) {
-		mdac = mda->metadata_locn;
-		memset(&buf, 0, sizeof(buf));
-		mdah->size = mdac->area.size;
-		rlocn_set_ignored(mdah->raw_locns, mda_is_ignored(mda));
-		if (!_raw_write_mda_header(fmt, mdac->area.dev,
-					   mdac->area.start, mdah)) {
-			if (!dev_close(pv->dev))
-				stack;
-			return_0;
-		}
-	}
+	baton.pv = pv;
+	baton.fmt = fmt;
+
+	if (!lvmcache_foreach_mda(info, _write_single_mda, &baton))
+		return_0;
 
-	if (!label_write(pv->dev, info->label)) {
+	if (!label_write(pv->dev, label)) {
 		dev_close(pv->dev);
 		return_0;
 	}
@@ -1384,68 +1393,6 @@
 	return 1;
 }
 
-static int _get_pv_if_in_vg(struct lvmcache_info *info,
-			    struct physical_volume *pv)
-{
-	char vgname[NAME_LEN + 1];
-	char vgid[ID_LEN + 1];
-
-	if (info->vginfo && info->vginfo->vgname &&
-	    !is_orphan_vg(info->vginfo->vgname)) {
-		/*
-		 * get_pv_from_vg_by_id() may call
-		 * lvmcache_label_scan() and drop cached
-		 * vginfo so make a local copy of string.
-		 */
-		strcpy(vgname, info->vginfo->vgname);
-		memcpy(vgid, info->vginfo->vgid, sizeof(vgid));
-
-		if (get_pv_from_vg_by_id(info->fmt, vgname, vgid,
-					 info->dev->pvid, pv))
-			return 1;
-	}
-
-	return 0;
-}
-
-static int _populate_pv_fields(struct lvmcache_info *info,
-			       struct physical_volume *pv,
-			       int scan_label_only)
-{
-	struct data_area_list *da;
-
-	/* Have we already cached vgname? */
-	if (!scan_label_only && _get_pv_if_in_vg(info, pv))
-		return 1;
-
-	/* Perform full scan (just the first time) and try again */
-	if (!scan_label_only && !critical_section() && !full_scan_done()) {
-		lvmcache_label_scan(info->fmt->cmd, 2);
-
-		if (_get_pv_if_in_vg(info, pv))
-			return 1;
-	}
-
-	/* Orphan */
-	pv->dev = info->dev;
-	pv->fmt = info->fmt;
-	pv->size = info->device_size >> SECTOR_SHIFT;
-	pv->vg_name = FMT_TEXT_ORPHAN_VG_NAME;
-	memcpy(&pv->id, &info->dev->pvid, sizeof(pv->id));
-
-	/* Currently only support exactly one data area */
-	if (dm_list_size(&info->das) != 1) {
-		log_error("Must be exactly one data area (found %d) on PV %s",
-			  dm_list_size(&info->das), dev_name(info->dev));
-		return 0;
-	}
-
-	dm_list_iterate_items(da, &info->das)
-		pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
-
-	return 1;
-}
-
 /*
  * Copy constructor for a metadata_locn.
  */
@@ -1485,16 +1432,14 @@
 {
 	struct label *label;
 	struct device *dev;
-	struct lvmcache_info *info;
 
 	if (!(dev = dev_cache_get(pv_name, fmt->cmd->filter)))
 		return_0;
 
 	if (!(label_read(dev, &label, UINT64_C(0))))
 		return_0;
-	info = (struct lvmcache_info *) label->info;
 
-	if (!_populate_pv_fields(info, pv, scan_label_only))
+	if (!lvmcache_populate_pv_fields(label->info, pv, scan_label_only))
 		return 0;
 
 	return 1;
@@ -1670,18 +1615,15 @@
 	 * reread PV mda information from the cache and add it to vg->fid.
 	 */
 	else {
-		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
+		if (!(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
 			log_error("PV %s missing from cache", pv_dev_name(pv));
 			return 0;
 		}
 
-		if (fmt != info->fmt) {
-			log_error("PV %s is a different format (seqno %s)",
-				  pv_dev_name(pv), info->fmt->name);
-			return 0;
-		}
+		if (!lvmcache_check_format(info, fmt))
+			return_0;
 
-		if (!fid_add_mdas(vg->fid, &info->mdas, pvid, ID_LEN))
+		if (!lvmcache_fid_add_mdas_pv(info, fid))
 			return_0;
 	}
 
@@ -1736,8 +1678,8 @@
 	}
 
 	if (fic->type & FMT_INSTANCE_MDAS &&
-	    (info = info_from_pvid(fic->context.pv_id, 0)))
-		fid_add_mdas(fid, &info->mdas, fic->context.pv_id, ID_LEN);
+	    (info = lvmcache_info_from_pvid(fic->context.pv_id, 0)))
+		lvmcache_fid_add_mdas_pv(info, fid);
 
 	return 1;
 }
@@ -1801,7 +1743,6 @@
 	struct dm_list *dir_list, *raw_list;
 	struct text_context tc;
 	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info;
 	const char *vg_name, *vg_id;
 
 	if (!(fidtc = (struct text_fid_context *)
@@ -1873,12 +1814,10 @@
 		if (type & FMT_INSTANCE_MDAS) {
 			/* Scan PVs in VG for any further MDAs */
 			lvmcache_label_scan(fid->fmt->cmd, 0);
-			if (!(vginfo = vginfo_from_vgname(vg_name, vg_id)))
+			if (!(vginfo = lvmcache_vginfo_from_vgname(vg_name, vg_id)))
+				goto_out;
+			if (!lvmcache_fid_add_mdas_vg(vginfo, fid))
 				goto_out;
-			dm_list_iterate_items(info, &vginfo->infos) {
-				if (!fid_add_mdas(fid, &info->mdas, info->dev->pvid, ID_LEN))
-					return_0;
-			}
 		}
 
 		/* FIXME Check raw metadata area count - rescan if required */
@@ -2314,7 +2253,7 @@
 		return 0;
 	}
 
-	if (!(dev_area.dev = device_from_pvid(cmd, &id, NULL, NULL))) {
+	if (!(dev_area.dev = lvmcache_device_from_pvid(cmd, &id, NULL, NULL))) {
 		char buffer[64] __attribute__((aligned(8)));
 
 		if (!id_write_format(&id, buffer, sizeof(buffer)))
--- LVM2/lib/format_text/format-text.h	2011/03/11 14:45:18	1.33
+++ LVM2/lib/format_text/format-text.h	2012/02/10 01:28:28	1.34
@@ -62,4 +62,16 @@
 	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
 void del_mdas(struct dm_list *mdas);
 
+/* On disk */
+struct disk_locn {
+	uint64_t offset;	/* Offset in bytes to start sector */
+	uint64_t size;		/* Bytes */
+} __attribute__ ((packed));
+
+/* Data areas (holding PEs) */
+struct data_area_list {
+	struct dm_list list;
+	struct disk_locn disk_locn;
+};
+
 #endif
--- LVM2/lib/format_text/import_vsn1.c	2012/01/25 21:43:51	1.99
+++ LVM2/lib/format_text/import_vsn1.c	2012/02/10 01:28:28	1.100
@@ -190,7 +190,7 @@
 	/*
 	 * Convert the uuid into a device.
 	 */
-	if (!(pv->dev = device_from_pvid(fid->fmt->cmd, &pv->id, scan_done_once,
+	if (!(pv->dev = lvmcache_device_from_pvid(fid->fmt->cmd, &pv->id, scan_done_once,
                                          &pv->label_sector))) {
 		char buffer[64] __attribute__((aligned(8)));
 
--- LVM2/lib/format_text/layout.h	2010/06/30 17:13:05	1.13
+++ LVM2/lib/format_text/layout.h	2012/02/10 01:28:28	1.14
@@ -21,17 +21,7 @@
 #include "metadata.h"
 #include "uuid.h"
 
-/* On disk */
-struct disk_locn {
-	uint64_t offset;	/* Offset in bytes to start sector */
-	uint64_t size;		/* Bytes */
-} __attribute__ ((packed));
-
-/* Data areas (holding PEs) */
-struct data_area_list {
-	struct dm_list list;
-	struct disk_locn disk_locn;
-};
+/* disk_locn and data_area_list are defined in format-text.h */
 
 /* Fields with the suffix _xl should be xlate'd wherever they appear */
 /* On disk */
--- LVM2/lib/format_text/text_label.c	2011/05/28 09:48:15	1.40
+++ LVM2/lib/format_text/text_label.c	2012/02/10 01:28:28	1.41
@@ -35,15 +35,41 @@
 	return 0;
 }
 
+struct _da_setup_baton {
+	struct disk_locn *pvh_dlocn_xl;
+	struct device *dev;
+};
+
+static int _da_setup(struct data_area_list *da, void *baton)
+{
+	struct _da_setup_baton *p = baton;
+	p->pvh_dlocn_xl->offset = xlate64(da->disk_locn.offset);
+	p->pvh_dlocn_xl->size = xlate64(da->disk_locn.size);
+	p->pvh_dlocn_xl++;
+	return 1;
+}
+
+static int _mda_setup(struct metadata_area *mda, void *baton)
+{
+	struct _da_setup_baton *p = baton;
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+
+	if (mdac->area.dev != p->dev)
+		return 1;
+
+	p->pvh_dlocn_xl->offset = xlate64(mdac->area.start);
+	p->pvh_dlocn_xl->size = xlate64(mdac->area.size);
+	p->pvh_dlocn_xl++;
+
+	return 1;
+}
+
 static int _text_write(struct label *label, void *buf)
 {
 	struct label_header *lh = (struct label_header *) buf;
 	struct pv_header *pvhdr;
 	struct lvmcache_info *info;
-	struct disk_locn *pvh_dlocn_xl;
-	struct metadata_area *mda;
-	struct mda_context *mdac;
-	struct data_area_list *da;
+	struct _da_setup_baton baton;
 	char buffer[64] __attribute__((aligned(8)));
 	int da1, mda1, mda2;
 
@@ -54,43 +80,31 @@
 
 	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 	info = (struct lvmcache_info *) label->info;
-	pvhdr->device_size_xl = xlate64(info->device_size);
-	memcpy(pvhdr->pv_uuid, &info->dev->pvid, sizeof(struct id));
+	pvhdr->device_size_xl = xlate64(lvmcache_device_size(info));
+	memcpy(pvhdr->pv_uuid, &lvmcache_device(info)->pvid, sizeof(struct id));
 	if (!id_write_format((const struct id *)pvhdr->pv_uuid, buffer,
 			     sizeof(buffer))) {
 		stack;
 		buffer[0] = '\0';
 	}
 
-	pvh_dlocn_xl = &pvhdr->disk_areas_xl[0];
+	baton.dev = lvmcache_device(info);
 
 	/* List of data areas (holding PEs) */
-	dm_list_iterate_items(da, &info->das) {
-		pvh_dlocn_xl->offset = xlate64(da->disk_locn.offset);
-		pvh_dlocn_xl->size = xlate64(da->disk_locn.size);
-		pvh_dlocn_xl++;
-	}
+	baton.pvh_dlocn_xl = &pvhdr->disk_areas_xl[0];
+	lvmcache_foreach_da(info, _da_setup, &baton);
 
 	/* NULL-termination */
-	pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
-	pvh_dlocn_xl->size = xlate64(UINT64_C(0));
-	pvh_dlocn_xl++;
+	baton.pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
+	baton.pvh_dlocn_xl->size = xlate64(UINT64_C(0));
+	baton.pvh_dlocn_xl++;
 
 	/* List of metadata area header locations */
-	dm_list_iterate_items(mda, &info->mdas) {
-		mdac = (struct mda_context *) mda->metadata_locn;
-
-		if (mdac->area.dev != info->dev)
-			continue;
-
-		pvh_dlocn_xl->offset = xlate64(mdac->area.start);
-		pvh_dlocn_xl->size = xlate64(mdac->area.size);
-		pvh_dlocn_xl++;
-	}
+	lvmcache_foreach_mda(info, _mda_setup, &baton);
 
 	/* NULL-termination */
-	pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
-	pvh_dlocn_xl->size = xlate64(UINT64_C(0));
+	baton.pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
+	baton.pvh_dlocn_xl->size = xlate64(UINT64_C(0));
 
 	/* Create debug message with da and mda locations */
 	if (xlate64(pvhdr->disk_areas_xl[0].offset) ||
@@ -113,7 +127,7 @@
 		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
 		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s"
 		  "%s%.*" PRIu64 "%s%.*" PRIu64 "%s",
-		  dev_name(info->dev), buffer, info->device_size, 
+		  dev_name(lvmcache_device(info)), buffer, lvmcache_device_size(info),
 		  (da1 > -1) ? " da1 (" : "",
 		  (da1 > -1) ? 1 : 0,
 		  (da1 > -1) ? xlate64(pvhdr->disk_areas_xl[da1].offset) >> SECTOR_SHIFT : 0,
@@ -138,7 +152,7 @@
 
 	if (da1 < 0) {
 		log_error(INTERNAL_ERROR "%s label header currently requires "
-			  "a data area.", dev_name(info->dev));
+			  "a data area.", dev_name(lvmcache_device(info)));
 		return 0;
 	}
 
@@ -250,6 +264,62 @@
 	return 1;
 }
 
+struct _update_mda_baton {
+	struct lvmcache_info *info;
+	struct label *label;
+};
+
+static int _update_mda(struct metadata_area *mda, void *baton)
+{
+	struct _update_mda_baton *p = baton;
+	const struct format_type *fmt = p->label->labeller->private; // Oh dear.
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+	struct mda_header *mdah;
+	const char *vgname;
+	struct id vgid;
+	uint64_t vgstatus;
+	char *creation_host;
+
+	if (!dev_open_readonly(mdac->area.dev)) {
+		mda_set_ignored(mda, 1);
+		stack;
+		return 1;
+	}
+
+	if (!(mdah = raw_read_mda_header(fmt, &mdac->area))) {
+		stack;
+		goto close_dev;
+	}
+
+	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
+
+	if (mda_is_ignored(mda)) {
+		log_debug("Ignoring mda on device %s at offset %"PRIu64,
+			  dev_name(mdac->area.dev),
+			  mdac->area.start);
+		if (!dev_close(mdac->area.dev))
+			stack;
+		return 1;
+	}
+
+	if ((vgname = vgname_from_mda(fmt, mdah,
+				      &mdac->area,
+				      &vgid, &vgstatus, &creation_host,
+				      &mdac->free_sectors)) &&
+	    !lvmcache_update_vgname_and_id(p->info, vgname,
+					   (char *) &vgid, vgstatus,
+					   creation_host)) {
+		if (!dev_close(mdac->area.dev))
+			stack;
+		return_0;
+	}
+close_dev:
+	if (!dev_close(mdac->area.dev))
+		stack;
+
+	return 1;
+}
+
 static int _text_read(struct labeller *l, struct device *dev, void *buf,
 		 struct label **label)
 {
@@ -258,13 +328,7 @@
 	struct lvmcache_info *info;
 	struct disk_locn *dlocn_xl;
 	uint64_t offset;
-	struct metadata_area *mda;
-	struct id vgid;
-	struct mda_context *mdac;
-	const char *vgname;
-	uint64_t vgstatus;
-	char *creation_host;
-	struct mda_header *mdah;
+	struct _update_mda_baton baton;
 
 	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
 
@@ -272,73 +336,34 @@
 				  FMT_TEXT_ORPHAN_VG_NAME,
 				  FMT_TEXT_ORPHAN_VG_NAME, 0)))
 		return_0;
-	*label = info->label;
 
-	info->device_size = xlate64(pvhdr->device_size_xl);
+	/* this one is leaked forever */
+	*label = lvmcache_get_label(info);
 
-	if (info->das.n)
-		del_das(&info->das);
-	dm_list_init(&info->das);
+	lvmcache_set_device_size(info, xlate64(pvhdr->device_size_xl));
 
-	if (info->mdas.n)
-		del_mdas(&info->mdas);
-	dm_list_init(&info->mdas);
+	lvmcache_del_das(info);
+	lvmcache_del_mdas(info);
 
 	/* Data areas holding the PEs */
 	dlocn_xl = pvhdr->disk_areas_xl;
 	while ((offset = xlate64(dlocn_xl->offset))) {
-		add_da(NULL, &info->das, offset,
-		       xlate64(dlocn_xl->size));
+		lvmcache_add_da(info, offset, xlate64(dlocn_xl->size));
 		dlocn_xl++;
 	}
 
 	/* Metadata area headers */
 	dlocn_xl++;
 	while ((offset = xlate64(dlocn_xl->offset))) {
-		add_mda(info->fmt, NULL, &info->mdas, dev, offset,
-			xlate64(dlocn_xl->size), 0);
+		lvmcache_add_mda(info, dev, offset, xlate64(dlocn_xl->size), 0);
 		dlocn_xl++;
 	}
 
-	dm_list_iterate_items(mda, &info->mdas) {
-		mdac = (struct mda_context *) mda->metadata_locn;
-		if (!dev_open_readonly(mdac->area.dev)) {
-			mda_set_ignored(mda, 1);
-			stack;
-			continue;
-		}
-		if (!(mdah = raw_read_mda_header(info->fmt, &mdac->area))) {
-			stack;
-			goto close_dev;
-		}
-		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
-
-		if (mda_is_ignored(mda)) {
-			log_debug("Ignoring mda on device %s at offset %"PRIu64,
-				  dev_name(mdac->area.dev),
-				  mdac->area.start);
-			if (!dev_close(mdac->area.dev))
-				stack;
-			continue;
-		}
-
-		if ((vgname = vgname_from_mda(info->fmt, mdah,
-					      &mdac->area,
-					      &vgid, &vgstatus, &creation_host,
-					      &mdac->free_sectors)) &&
-		    !lvmcache_update_vgname_and_id(info, vgname,
-						   (char *) &vgid, vgstatus,
-						   creation_host)) {
-			if (!dev_close(mdac->area.dev))
-					stack;
-			return_0;
-		}
-	close_dev:
-		if (!dev_close(mdac->area.dev))
-			stack;
-	}
+	baton.info = info;
+	baton.label = *label;
 
-	info->status &= ~CACHE_INVALID;
+	lvmcache_foreach_mda(info, _update_mda, &baton);
+	lvmcache_make_valid(info);
 
 	return 1;
 }
@@ -348,10 +373,8 @@
 {
 	struct lvmcache_info *info = (struct lvmcache_info *) label->info;
 
-	if (info->mdas.n)
-		del_mdas(&info->mdas);
-	if (info->das.n)
-		del_das(&info->das);
+	lvmcache_del_mdas(info);
+	lvmcache_del_das(info);
 }
 
 static void _fmt_text_destroy(struct labeller *l)
--- LVM2/lib/label/label.c	2012/02/08 11:12:18	1.55
+++ LVM2/lib/label/label.c	2012/02/10 01:28:28	1.56
@@ -172,9 +172,9 @@
 
       out:
 	if (!found) {
-		if ((info = info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, info->fmt->orphan_vg_name,
-						      info->fmt->orphan_vg_name,
+		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+			lvmcache_update_vgname_and_id(info, lvmcache_fmt(info)->orphan_vg_name,
+						      lvmcache_fmt(info)->orphan_vg_name,
 						      0, NULL);
 		log_very_verbose("%s: No label detected", dev_name(dev));
 	}
@@ -261,18 +261,18 @@
 	struct lvmcache_info *info;
 	int r = 0;
 
-	if ((info = info_from_pvid(dev->pvid, 1))) {
+	if ((info = lvmcache_info_from_pvid(dev->pvid, 1))) {
 		log_debug("Using cached label for %s", dev_name(dev));
-		*result = info->label;
+		*result = lvmcache_get_label(info); /* leaked */
 		return 1;
 	}
 
 	if (!dev_open_readonly(dev)) {
 		stack;
 
-		if ((info = info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, info->fmt->orphan_vg_name,
-						      info->fmt->orphan_vg_name,
+		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+			lvmcache_update_vgname_and_id(info, lvmcache_fmt(info)->orphan_vg_name,
+						      lvmcache_fmt(info)->orphan_vg_name,
 						      0, NULL);
 
 		return r;
@@ -348,9 +348,9 @@
 	int r = 0;
 
 	if (!dev_open_readonly(dev)) {
-		if ((info = info_from_pvid(dev->pvid, 0)))
-			lvmcache_update_vgname_and_id(info, info->fmt->orphan_vg_name,
-						      info->fmt->orphan_vg_name,
+		if ((info = lvmcache_info_from_pvid(dev->pvid, 0)))
+			lvmcache_update_vgname_and_id(info, lvmcache_fmt(info)->orphan_vg_name,
+						      lvmcache_fmt(info)->orphan_vg_name,
 						      0, NULL);
 
 		return_0;
--- LVM2/lib/metadata/metadata.c	2012/02/08 12:52:59	1.476
+++ LVM2/lib/metadata/metadata.c	2012/02/10 01:28:28	1.477
@@ -1504,7 +1504,7 @@
 		pp = &default_pp;
 
 	if (pp->idp) {
-		if ((dev = device_from_pvid(cmd, pp->idp, NULL, NULL)) &&
+		if ((dev = lvmcache_device_from_pvid(cmd, pp->idp, NULL, NULL)) &&
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
 			if (!id_write_format((const struct id*)&pp->idp->uuid,
 			    buffer, sizeof(buffer)))
@@ -2671,7 +2671,7 @@
 {
 	int cache_updated = 0;
 
-	if (!vgname_is_locked(vg->name)) {
+	if (!lvmcache_vgname_is_locked(vg->name)) {
 		log_error(INTERNAL_ERROR "Attempt to write new VG metadata "
 			  "without locking %s", vg->name);
 		return cache_updated;
@@ -2717,6 +2717,31 @@
 	remote_revert_cached_metadata(vg);
 }
 
+struct _vg_read_orphan_baton {
+	struct volume_group *vg;
+	int warnings;
+};
+
+static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
+{
+	struct _vg_read_orphan_baton *b = baton;
+	struct physical_volume *pv = NULL;
+	struct pv_list *pvl;
+
+	if (!(pv = _pv_read(b->vg->cmd, b->vg->vgmem, dev_name(lvmcache_device(info)),
+			    b->vg->fid, b->warnings, 0))) {
+		return 1;
+	}
+	if (!(pvl = dm_pool_zalloc(b->vg->vgmem, sizeof(*pvl)))) {
+		log_error("pv_list allocation failed");
+		free_pv_fid(pv);
+		return 0;
+	}
+	pvl->pv = pv;
+	add_pvl_to_vgs(b->vg, pvl);
+	return 1;
+}
+
 /* Make orphan PVs look like a VG */
 static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 					     int warnings,
@@ -2724,15 +2749,17 @@
 {
 	struct format_instance_ctx fic;
 	struct format_instance *fid;
+	const struct format_type *fmt;
 	struct lvmcache_vginfo *vginfo;
-	struct lvmcache_info *info;
-	struct pv_list *pvl;
 	struct volume_group *vg = NULL;
-	struct physical_volume *pv = NULL;
+	struct _vg_read_orphan_baton baton;
 
 	lvmcache_label_scan(cmd, 0);
 
-	if (!(vginfo = vginfo_from_vgname(orphan_vgname, NULL)))
+	if (!(vginfo = lvmcache_vginfo_from_vgname(orphan_vgname, NULL)))
+		return_NULL;
+
+	if (!(fmt = lvmcache_fmt_from_vgname(orphan_vgname, NULL, 0)))
 		return_NULL;
 
 	if (!(vg = alloc_vg("vg_read_orphans", cmd, orphan_vgname)))
@@ -2742,28 +2769,18 @@
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = orphan_vgname;
 	fic.context.vg_ref.vg_id = NULL;
-	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic))) {
+	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
 		log_error("Failed to create format instance");
 		goto bad;
 	}
 	vg_set_fid(vg, fid);
 
-	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, vg->vgmem, dev_name(info->dev),
-				    vg->fid, warnings, 0))) {
-			continue;
-		}
-		if (!(pvl = dm_pool_zalloc(vg->vgmem, sizeof(*pvl)))) {
-			log_error("pv_list allocation failed");
-			goto bad;
-		}
-		pvl->pv = pv;
-		add_pvl_to_vgs(vg, pvl);
-	}
+	baton.warnings = warnings;
+	baton.vg = vg;
+	lvmcache_foreach_pv(vginfo, _vg_read_orphan_pv, &baton);
 
 	return vg;
 bad:
-	free_pv_fid(pv);
 	release_vg(vg);
 	return NULL;
 }
@@ -2848,6 +2865,15 @@
 					 "on it, remove volumes and consider vgreduce --removemissing.");
 		}
 }
+
+static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
+{
+	int *in_use = _in_use;
+	if (!mda_is_ignored(mda))
+		*in_use = 1;
+	return 1;
+}
+
 /* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned.
@@ -2913,20 +2939,20 @@
 
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
-	if (!(fmt = fmt_from_vgname(vgname, vgid, 1))) {
+	if (!(fmt = lvmcache_fmt_from_vgname(vgname, vgid, 1))) {
 		lvmcache_label_scan(cmd, 0);
-		if (!(fmt = fmt_from_vgname(vgname, vgid, 1))) {
+		if (!(fmt = lvmcache_fmt_from_vgname(vgname, vgid, 1))) {
 			/* Independent MDAs aren't supported under low memory */
 			if (!cmd->independent_metadata_areas && critical_section())
 				return_NULL;
 			lvmcache_label_scan(cmd, 2);
-			if (!(fmt = fmt_from_vgname(vgname, vgid, 0)))
+			if (!(fmt = lvmcache_fmt_from_vgname(vgname, vgid, 0)))
 				return_NULL;
 		}
 	}
 
 	/* Now determine the correct vgname if none was supplied */
-	if (!vgname && !(vgname = vgname_from_vgid(cmd->mem, vgid)))
+	if (!vgname && !(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
 		return_NULL;
 
 	if (use_precommitted && !(fmt->features & FMT_PRECOMMIT))
@@ -3016,18 +3042,17 @@
 				 * Check it's an orphan without metadata area
 				 * not ignored.
 				 */
-				if (!(info = info_from_pvid(pvl->pv->dev->pvid, 1)) ||
-				   !info->vginfo || !is_orphan_vg(info->vginfo->vgname)) {
+				if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, 1)) ||
+				    !lvmcache_is_orphan(info)) {
 					inconsistent_pvs = 1;
 					break;
 				}
-				if (dm_list_size(&info->mdas)) {
-					if (!fid_add_mdas(fid, &info->mdas,
-							  info->dev->pvid, ID_LEN)) {
+				if (lvmcache_mda_count(info)) {
+					if (!lvmcache_fid_add_mdas_pv(info, fid)) {
 						release_vg(correct_vg);
 						return_NULL;
 					}
-					 
+
 					log_debug("Empty mda found for VG %s.", vgname);
 
 					if (inconsistent_mdas)
@@ -3037,11 +3062,8 @@
 					 * If any newly-added mdas are in-use then their
 					 * metadata needs updating.
 					 */
-					dm_list_iterate_items(mda, &info->mdas)
-						if (!mda_is_ignored(mda)) {
-							inconsistent_mdas = 1;
-							break;
-						}
+					lvmcache_foreach_mda(info, _check_mda_in_use,
+							     &inconsistent_mdas);
 				}
 			}
 
@@ -3110,7 +3132,7 @@
 		if (!cmd->independent_metadata_areas && critical_section())
 			return_NULL;
 		lvmcache_label_scan(cmd, 2);
-		if (!(fmt = fmt_from_vgname(vgname, vgid, 0)))
+		if (!(fmt = lvmcache_fmt_from_vgname(vgname, vgid, 0)))
 			return_NULL;
 
 		if (precommitted && !(fmt->features & FMT_PRECOMMIT))
@@ -3383,13 +3405,11 @@
 	const char *vgname;
 	struct dm_list *vgnames;
 	struct volume_group *vg;
-	struct lvmcache_vginfo *vginfo;
 	struct str_list *strl;
 	int consistent = 0;
 
 	/* Is corresponding vgname already cached? */
-	if ((vginfo = vginfo_from_vgid(vgid)) &&
-	    vginfo->vgname && !is_orphan_vg(vginfo->vgname)) {
+	if (lvmcache_vgid_is_cached(vgid)) {
 		if ((vg = _vg_read(cmd, NULL, vgid, 1,
 				   &consistent, precommitted)) &&
 		    id_equal(&vg->id, (const struct id *)vgid)) {
@@ -3480,7 +3500,7 @@
 	vgname = lvmcache_vgname_from_pvid(cmd, pvid);
 
 	if (is_orphan_vg(vgname)) {
-		if (!(info = info_from_pvid(pvid, 0))) {
+		if (!(info = lvmcache_info_from_pvid(pvid, 0))) {
 			return_NULL;
 		}
 		/*
@@ -3490,7 +3510,7 @@
 		 * Detecting this means checking every VG by scanning
 		 * every PV on the system.
 		 */
-		if (mdas_empty_or_ignored(&info->mdas)) {
+		if (lvmcache_uncertain_ownership(info)) {
 			if (!scan_vgs_for_pvs(cmd, 1)) {
 				log_error("Rescan for PVs without "
 					  "metadata areas failed.");
@@ -3512,7 +3532,7 @@
 {
 	const char *pvid;
 
-	pvid = pvid_from_devname(cmd, pvname);
+	pvid = lvmcache_pvid_from_devname(cmd, pvname);
 	if (!pvid)
 		/* Not a PV */
 		return NULL;
@@ -3576,7 +3596,7 @@
 	pv->label_sector = label->sector;
 
 	/* FIXME Move more common code up here */
-	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, scan_label_only))) {
+	if (!(lvmcache_fmt(info)->ops->pv_read(lvmcache_fmt(info), pv_name, pv, scan_label_only))) {
 		log_error("Failed to read existing physical volume '%s'",
 			  pv_name);
 		goto bad;
@@ -3589,7 +3609,7 @@
 		goto_bad;
 
 	if (fid)
-		fid_add_mdas(fid, &info->mdas, (const char *) &pv->id, ID_LEN);
+		lvmcache_fid_add_mdas(info, fid, (const char *) &pv->id, ID_LEN);
 	else {
 		fic.type = FMT_INSTANCE_PV | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 		fic.context.pv_id = (const char *) &pv->id;
@@ -3656,7 +3676,7 @@
 		if (!vgid)
 			continue;	/* FIXME Unnecessary? */
 		consistent = 0;
-		if (!(vgname = vgname_from_vgid(NULL, vgid))) {
+		if (!(vgname = lvmcache_vgname_from_vgid(NULL, vgid))) {
 			stack;
 			continue;
 		}
@@ -3777,6 +3797,13 @@
 	return (vg_name && *vg_name != '#');
 }
 
+static int _analyze_mda(struct metadata_area *mda, void *baton)
+{
+	const struct format_type *fmt = baton;
+	mda->ops->pv_analyze_mda(fmt, mda);
+	return 1;
+}
+
 /*
  * Returns:
  *  0 - fail
@@ -3787,7 +3814,6 @@
 {
 	struct label *label;
 	struct device *dev;
-	struct metadata_area *mda;
 	struct lvmcache_info *info;
 
 	dev = dev_cache_get(pv_name, cmd->filter);
@@ -3813,8 +3839,7 @@
 	 * Next, loop through metadata areas
 	 */
 	info = label->info;
-	dm_list_iterate_items(mda, &info->mdas)
-		mda->ops->pv_analyze_mda(info->fmt, mda);
+	lvmcache_foreach_mda(info, _analyze_mda, (void *)lvmcache_fmt(info));
 
 	return 1;
 }
@@ -3932,7 +3957,7 @@
 		return NULL;
 	}
 
-	already_locked = vgname_is_locked(vg_name);
+	already_locked = lvmcache_vgname_is_locked(vg_name);
 
 	if (!already_locked && !(misc_flags & READ_WITHOUT_LOCK) &&
 	    !lock_vol(cmd, vg_name, lock_flags)) {
@@ -4096,9 +4121,9 @@
 
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
-	if (!fmt_from_vgname(vgname, NULL, 1)) {
+	if (!lvmcache_fmt_from_vgname(vgname, NULL, 1)) {
 		lvmcache_label_scan(cmd, 0);
-		if (!fmt_from_vgname(vgname, NULL, 1)) {
+		if (!lvmcache_fmt_from_vgname(vgname, NULL, 1)) {
 			/* Independent MDAs aren't supported under low memory */
 			if (!cmd->independent_metadata_areas && critical_section()) {
 				/*
@@ -4109,7 +4134,7 @@
 				return FAILED_LOCKING;
 			}
 			lvmcache_label_scan(cmd, 2);
-			if (!fmt_from_vgname(vgname, NULL, 0)) {
+			if (!lvmcache_fmt_from_vgname(vgname, NULL, 0)) {
 				/* vgname not found after scanning */
 				return SUCCESS;
 			}
--- LVM2/lib/metadata/pv.c	2011/09/07 13:42:00	1.11
+++ LVM2/lib/metadata/pv.c	2012/02/10 01:28:28	1.12
@@ -143,23 +143,27 @@
 {
 	struct lvmcache_info *info;
 
-	info = info_from_pvid((const char *)&pv->id.uuid, 0);
-	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
+	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
+	return info ? lvmcache_mda_count(info) : UINT64_C(0);
+}
+
+static int _count_unignored(struct metadata_area *mda, void *baton)
+{
+	uint32_t *count = baton;
+	if (!mda_is_ignored(mda))
+		(*count) ++;
+	return 1;
 }
 
 uint32_t pv_mda_used_count(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
-	struct metadata_area *mda;
 	uint32_t used_count=0;
 
-	info = info_from_pvid((const char *)&pv->id.uuid, 0);
+	info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0);
 	if (!info)
 		return 0;
-	dm_list_iterate_items(mda, &info->mdas) {
-		if (!mda_is_ignored(mda))
-			used_count++;
-	}
+	lvmcache_foreach_mda(info, _count_unignored, &used_count);
 	return used_count;
 }
 
@@ -209,29 +213,36 @@
 	const char *pvid = (const char *)(&pv->id.uuid);
 
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
-	if ((info = info_from_pvid(pvid, 0)))
-		min_mda_size = find_min_mda_size(&info->mdas);
+	if ((info = lvmcache_info_from_pvid(pvid, 0)))
+		min_mda_size = lvmcache_smallest_mda_size(info);
 	return min_mda_size;
 }
 
+static int _pv_mda_free(struct metadata_area *mda, void *baton) {
+	uint64_t mda_free;
+	uint64_t *freespace = baton;
+
+	if (!mda->ops->mda_free_sectors)
+		return 1;
+
+	mda_free = mda->ops->mda_free_sectors(mda);
+	if (mda_free < *freespace)
+		*freespace = mda_free;
+	return 1;
+}
+
 uint64_t pv_mda_free(const struct physical_volume *pv)
 {
 	struct lvmcache_info *info;
-	uint64_t freespace = UINT64_MAX, mda_free;
+	uint64_t freespace = UINT64_MAX;
 	const char *pvid = (const char *)&pv->id.uuid;
-	struct metadata_area *mda;
 
-	if ((info = info_from_pvid(pvid, 0)))
-		dm_list_iterate_items(mda, &info->mdas) {
-			if (!mda->ops->mda_free_sectors)
-				continue;
-			mda_free = mda->ops->mda_free_sectors(mda);
-			if (mda_free < freespace)
-				freespace = mda_free;
-		}
+	if ((info = lvmcache_info_from_pvid(pvid, 0)))
+		lvmcache_foreach_mda(info, _pv_mda_free, &freespace);
 
 	if (freespace == UINT64_MAX)
 		freespace = UINT64_C(0);
+
 	return freespace;
 }
 
@@ -246,22 +257,51 @@
 	return used;
 }
 
+struct _pv_mda_set_ignored_baton {
+	unsigned mda_ignored;
+	struct dm_list *mdas_in_use, *mdas_ignored, *mdas_to_change;
+};
+
+static int _pv_mda_set_ignored_one(struct metadata_area *mda, void *baton)
+{
+	struct _pv_mda_set_ignored_baton *b = baton;
+	struct metadata_area *vg_mda, *tmda;
+
+	if (mda_is_ignored(mda) && !b->mda_ignored) {
+		/* Changing an ignored mda to one in_use requires moving it */
+		dm_list_iterate_items_safe(vg_mda, tmda, b->mdas_ignored)
+			if (mda_locns_match(mda, vg_mda)) {
+				mda_set_ignored(vg_mda, b->mda_ignored);
+				dm_list_move(b->mdas_in_use, &vg_mda->list);
+			}
+	}
+
+	dm_list_iterate_items_safe(vg_mda, tmda, b->mdas_in_use)
+		if (mda_locns_match(mda, vg_mda))
+			/* Don't move mda: needs writing to disk. */
+			mda_set_ignored(vg_mda, b->mda_ignored);
+
+	mda_set_ignored(mda, b->mda_ignored);
+	return 1;
+}
+
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored)
 {
 	struct lvmcache_info *info;
-	struct metadata_area *mda, *vg_mda, *tmda;
-	struct dm_list *mdas_in_use, *mdas_ignored, *mdas_to_change;
+	struct _pv_mda_set_ignored_baton baton;
+	struct metadata_area *mda;
 
-	if (!(info = info_from_pvid((const char *)&pv->id.uuid, 0)))
+	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id.uuid, 0)))
 		return_0;
 
-	mdas_in_use = &pv->fid->metadata_areas_in_use;
-	mdas_ignored = &pv->fid->metadata_areas_ignored;
-	mdas_to_change = mda_ignored ? mdas_in_use : mdas_ignored;
+	baton.mda_ignored = mda_ignored;
+	baton.mdas_in_use = &pv->fid->metadata_areas_in_use;
+	baton.mdas_ignored = &pv->fid->metadata_areas_ignored;
+	baton.mdas_to_change = baton.mda_ignored ? baton.mdas_in_use : baton.mdas_ignored;
 
 	if (is_orphan(pv)) {
-		dm_list_iterate_items(mda, mdas_to_change)
-			mda_set_ignored(mda, mda_ignored);
+		dm_list_iterate_items(mda, baton.mdas_to_change)
+			mda_set_ignored(mda, baton.mda_ignored);
 		return 1;
 	}
 
@@ -288,22 +328,8 @@
 	/* FIXME: Try not to update the cache here! Also, try to iterate over
 	 *	  PV mdas only using the format instance's index somehow
 	 * 	  (i.e. try to avoid using mda_locn_match call). */
-	dm_list_iterate_items(mda, &info->mdas) {
-		if (mda_is_ignored(mda) && !mda_ignored)
-			/* Changing an ignored mda to one in_use requires moving it */
-			dm_list_iterate_items_safe(vg_mda, tmda, mdas_ignored)
-				if (mda_locns_match(mda, vg_mda)) {
-					mda_set_ignored(vg_mda, mda_ignored);
-					dm_list_move(mdas_in_use, &vg_mda->list);
-				}
-
-		dm_list_iterate_items_safe(vg_mda, tmda, mdas_in_use)
-			if (mda_locns_match(mda, vg_mda))
-				/* Don't move mda: needs writing to disk. */
-				mda_set_ignored(vg_mda, mda_ignored);
 
-		mda_set_ignored(mda, mda_ignored);
-	}
+	lvmcache_foreach_mda(info, _pv_mda_set_ignored_one, &baton);
 
 	return 1;
 }
--- LVM2/lib/metadata/vg.c	2012/01/19 15:31:45	1.14
+++ LVM2/lib/metadata/vg.c	2012/02/10 01:28:28	1.15
@@ -84,7 +84,7 @@
 
 	/* Check if there are any vginfo holders */
 	if (vg->vginfo &&
-	    !vginfo_holders_dec_and_test_for_zero(vg->vginfo))
+	    !lvmcache_vginfo_holders_dec_and_test_for_zero(vg->vginfo))
 		return;
 
 	_free_vg(vg);
--- LVM2/tools/toollib.c	2012/02/08 12:52:59	1.239
+++ LVM2/tools/toollib.c	2012/02/10 01:28:28	1.240
@@ -587,7 +587,7 @@
 		}
 		dm_list_iterate_items(sl, vgids) {
 			vgid = sl->str;
-			if (!(vgid) || !(vg_name = vgname_from_vgid(cmd->mem, vgid)))
+			if (!(vgid) || !(vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
--- LVM2/tools/vgrename.c	2011/08/10 20:25:31	1.76
+++ LVM2/tools/vgrename.c	2012/02/10 01:28:29	1.77
@@ -87,7 +87,7 @@
 
 	dm_list_iterate_items(sl, vgids) {
 		vgid = sl->str;
-		if (!vgid || !(vg_name = vgname_from_vgid(NULL, vgid)))
+		if (!vgid || !(vg_name = lvmcache_vgname_from_vgid(NULL, vgid)))
 			continue;
 		if (!strcmp(vg_name, vg_name_old)) {
 			if (match) {
@@ -102,7 +102,7 @@
 	log_suppress(2);
 	found_id = id_read_format(&id, vg_name_old);
 	log_suppress(0);
-	if (found_id && (vg_name = vgname_from_vgid(cmd->mem, (char *)id.uuid))) {
+	if (found_id && (vg_name = lvmcache_vgname_from_vgid(cmd->mem, (char *)id.uuid))) {
 		vg_name_old = vg_name;
 		vgid = (char *)id.uuid;
 	} else


