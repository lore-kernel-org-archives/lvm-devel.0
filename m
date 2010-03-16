From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Mar 2010 17:30:04 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20100316173004.11566.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-16 17:30:02

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/format_text: format-text.c import_vsn1.c 
	lib/metadata   : metadata.c 

Log message:
	Only do one full device scan during each read of text format metadata.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1463&r2=1.1464
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.321&r2=1.322

--- LVM2/WHATS_NEW	2010/03/16 16:57:03	1.1463
+++ LVM2/WHATS_NEW	2010/03/16 17:30:00	1.1464
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Only do one full device scan during each read of text format metadata.
   Remove unnecessary full_scan parameter from get_vgids and get_vgnames calls.
   Look up missing PVs by uuid not dev_name in _pvs_single to avoid invalid stat.
   Make find_pv_in_vg_by_uuid() return same type as related functions.
--- LVM2/lib/cache/lvmcache.c	2010/03/16 16:57:04	1.79
+++ LVM2/lib/cache/lvmcache.c	2010/03/16 17:30:01	1.80
@@ -703,7 +703,8 @@
 	return pvids;
 }
 
-struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid)
+struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
+				int *scan_done_once)
 {
 	struct label *label;
 	struct lvmcache_info *info;
@@ -728,10 +729,11 @@
 		}
 	}
 
-	if (memlock())
+	if (memlock() || (scan_done_once && *scan_done_once))
 		return NULL;
 
 	lvmcache_label_scan(cmd, 2);
+	*scan_done_once = 1;
 
 	/* Try again */
 	if ((info = info_from_pvid((char *) pvid, 0))) {
--- LVM2/lib/cache/lvmcache.h	2010/03/16 16:57:04	1.28
+++ LVM2/lib/cache/lvmcache.h	2010/03/16 17:30:01	1.29
@@ -93,7 +93,8 @@
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
 struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
-struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid);
+struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
+				int *scan_done_once);
 int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 
--- LVM2/lib/format_text/format-text.c	2010/02/15 23:53:15	1.119
+++ LVM2/lib/format_text/format-text.c	2010/03/16 17:30:01	1.120
@@ -2025,7 +2025,7 @@
 		return 0;
 	}
 
-	if (!(dev_area.dev = device_from_pvid(cmd, &id))) {
+	if (!(dev_area.dev = device_from_pvid(cmd, &id, NULL))) {
 		char buffer[64] __attribute((aligned(8)));
 
 		if (!id_write_format(&id, buffer, sizeof(buffer)))
--- LVM2/lib/format_text/import_vsn1.c	2009/12/04 17:48:32	1.67
+++ LVM2/lib/format_text/import_vsn1.c	2010/03/16 17:30:01	1.68
@@ -27,7 +27,8 @@
 typedef int (*section_fn) (struct format_instance * fid, struct dm_pool * mem,
 			   struct volume_group * vg, struct config_node * pvn,
 			   struct config_node * vgn,
-			   struct dm_hash_table * pv_hash);
+			   struct dm_hash_table * pv_hash,
+			   int *scan_done_once);
 
 #define _read_int32(root, path, result) \
 	get_config_uint32(root, path, (uint32_t *) result)
@@ -153,7 +154,7 @@
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		    struct volume_group *vg, struct config_node *pvn,
 		    struct config_node *vgn __attribute((unused)),
-		    struct dm_hash_table *pv_hash)
+		    struct dm_hash_table *pv_hash, int *scan_done_once)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -186,7 +187,7 @@
 	/*
 	 * Convert the uuid into a device.
 	 */
-	if (!(pv->dev = device_from_pvid(fid->fmt->cmd, &pv->id))) {
+	if (!(pv->dev = device_from_pvid(fid->fmt->cmd, &pv->id, scan_done_once))) {
 		char buffer[64] __attribute((aligned(8)));
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
@@ -490,7 +491,8 @@
 			 struct dm_pool *mem,
 			 struct volume_group *vg, struct config_node *lvn,
 			 struct config_node *vgn __attribute((unused)),
-			 struct dm_hash_table *pv_hash __attribute((unused)))
+			 struct dm_hash_table *pv_hash __attribute((unused)),
+			 int *scan_done_once __attribute((unused)))
 {
 	struct logical_volume *lv;
 	struct config_node *cn;
@@ -556,7 +558,8 @@
 			struct dm_pool *mem,
 			struct volume_group *vg, struct config_node *lvn,
 			struct config_node *vgn __attribute((unused)),
-			struct dm_hash_table *pv_hash)
+			struct dm_hash_table *pv_hash,
+			int *scan_done_once __attribute((unused)))
 {
 	struct logical_volume *lv;
 	struct lv_list *lvl;
@@ -612,6 +615,7 @@
 			  struct dm_hash_table *pv_hash, int optional)
 {
 	struct config_node *n;
+	int scan_done_once = 0;
 
 	if (!(n = find_config_node(vgn, section))) {
 		if (!optional) {
@@ -623,7 +627,7 @@
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, mem, vg, n, vgn, pv_hash))
+		if (!fn(fid, mem, vg, n, vgn, pv_hash, &scan_done_once))
 			return_0;
 	}
 
--- LVM2/lib/metadata/metadata.c	2010/03/16 16:57:04	1.321
+++ LVM2/lib/metadata/metadata.c	2010/03/16 17:30:02	1.322
@@ -1416,7 +1416,7 @@
 		pp = &default_pp;
 
 	if (pp->idp) {
-		if ((dev = device_from_pvid(cmd, pp->idp)) &&
+		if ((dev = device_from_pvid(cmd, pp->idp, NULL)) &&
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
 			if (!id_write_format((const struct id*)&pp->idp->uuid,
 			    buffer, sizeof(buffer)))


