From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Mar 2010 02:11:20 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20100317021120.4682.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-17 02:11:19

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/format_text: import-export.h import.c import_vsn1.c 

Log message:
	Suppress repeated errors about the same missing PV uuids.
	Bypass full device scans when using internally-cached VG metadata.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1464&r2=1.1465
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2010/03/16 17:30:00	1.1464
+++ LVM2/WHATS_NEW	2010/03/17 02:11:18	1.1465
@@ -1,5 +1,7 @@
 Version 2.02.63 - 
 ================================
+  Suppress repeated errors about the same missing PV uuids.
+  Bypass full device scans when using internally-cached VG metadata.
   Only do one full device scan during each read of text format metadata.
   Remove unnecessary full_scan parameter from get_vgids and get_vgnames calls.
   Look up missing PVs by uuid not dev_name in _pvs_single to avoid invalid stat.
--- LVM2/lib/cache/lvmcache.c	2010/03/16 19:06:57	1.81
+++ LVM2/lib/cache/lvmcache.c	2010/03/17 02:11:18	1.82
@@ -704,7 +704,7 @@
 }
 
 struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
-				int *scan_done_once)
+				unsigned *scan_done_once)
 {
 	struct label *label;
 	struct lvmcache_info *info;
--- LVM2/lib/cache/lvmcache.h	2010/03/16 17:30:01	1.29
+++ LVM2/lib/cache/lvmcache.h	2010/03/17 02:11:18	1.30
@@ -94,7 +94,7 @@
 struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
-				int *scan_done_once);
+				unsigned *scan_done_once);
 int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 
--- LVM2/lib/format_text/import-export.h	2009/11/24 22:55:56	1.23
+++ LVM2/lib/format_text/import-export.h	2010/03/17 02:11:19	1.24
@@ -46,7 +46,8 @@
 struct text_vg_version_ops {
 	int (*check_version) (struct config_tree * cf);
 	struct volume_group *(*read_vg) (struct format_instance * fid,
-					 struct config_tree * cf);
+					 struct config_tree * cf,
+					 unsigned use_cached_pvs);
 	void (*read_desc) (struct dm_pool * mem, struct config_tree * cf,
 			   time_t *when, char **desc);
 	const char *(*read_vgname) (const struct format_type *fmt,
--- LVM2/lib/format_text/import.c	2009/11/24 22:55:56	1.48
+++ LVM2/lib/format_text/import.c	2010/03/17 02:11:19	1.49
@@ -111,7 +111,7 @@
 		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(vg = (*vsn)->read_vg(fid, cft)))
+		if (!(vg = (*vsn)->read_vg(fid, cft, 0)))
 			goto_out;
 
 		(*vsn)->read_desc(fid->fmt->cmd->mem, cft, when, desc);
@@ -146,7 +146,11 @@
 	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
 		if (!(*vsn)->check_version(cft))
 			continue;
-		if (!(vg = (*vsn)->read_vg(fid, cft)))
+		/*
+		 * The only path to this point uses cached vgmetadata,
+		 * so it can use cached PV state too.
+		 */
+		if (!(vg = (*vsn)->read_vg(fid, cft, 1)))
 			stack;
 		break;
 	}
--- LVM2/lib/format_text/import_vsn1.c	2010/03/16 17:30:01	1.68
+++ LVM2/lib/format_text/import_vsn1.c	2010/03/17 02:11:19	1.69
@@ -28,7 +28,8 @@
 			   struct volume_group * vg, struct config_node * pvn,
 			   struct config_node * vgn,
 			   struct dm_hash_table * pv_hash,
-			   int *scan_done_once);
+			   unsigned *scan_done_once,
+			   unsigned report_missing_devices);
 
 #define _read_int32(root, path, result) \
 	get_config_uint32(root, path, (uint32_t *) result)
@@ -154,7 +155,8 @@
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		    struct volume_group *vg, struct config_node *pvn,
 		    struct config_node *vgn __attribute((unused)),
-		    struct dm_hash_table *pv_hash, int *scan_done_once)
+		    struct dm_hash_table *pv_hash, unsigned *scan_done_once,
+		    unsigned report_missing_devices)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -191,10 +193,11 @@
 		char buffer[64] __attribute((aligned(8)));
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
-			log_error("Couldn't find device.");
+			buffer[0] = '\0';
+		if (report_missing_devices)
+			log_error("Couldn't find device with uuid %s.", buffer);
 		else
-			log_error("Couldn't find device with uuid '%s'.",
-				  buffer);
+			log_very_verbose("Couldn't find device with uuid %s.", buffer);
 	}
 
 	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name)))
@@ -492,7 +495,8 @@
 			 struct volume_group *vg, struct config_node *lvn,
 			 struct config_node *vgn __attribute((unused)),
 			 struct dm_hash_table *pv_hash __attribute((unused)),
-			 int *scan_done_once __attribute((unused)))
+			 unsigned *scan_done_once __attribute((unused)),
+			 unsigned report_missing_devices __attribute((unused)))
 {
 	struct logical_volume *lv;
 	struct config_node *cn;
@@ -559,7 +563,8 @@
 			struct volume_group *vg, struct config_node *lvn,
 			struct config_node *vgn __attribute((unused)),
 			struct dm_hash_table *pv_hash,
-			int *scan_done_once __attribute((unused)))
+			unsigned *scan_done_once __attribute((unused)),
+			unsigned report_missing_devices __attribute((unused)))
 {
 	struct logical_volume *lv;
 	struct lv_list *lvl;
@@ -612,10 +617,12 @@
 			  const char *section, section_fn fn,
 			  struct dm_pool *mem,
 			  struct volume_group *vg, struct config_node *vgn,
-			  struct dm_hash_table *pv_hash, int optional)
+			  struct dm_hash_table *pv_hash, int optional,
+			  unsigned *scan_done_once)
 {
 	struct config_node *n;
-	int scan_done_once = 0;
+	/* Only report missing devices when doing a scan */
+	unsigned report_missing_devices = scan_done_once ? !*scan_done_once : 1;
 
 	if (!(n = find_config_node(vgn, section))) {
 		if (!optional) {
@@ -627,7 +634,7 @@
 	}
 
 	for (n = n->child; n; n = n->sib) {
-		if (!fn(fid, mem, vg, n, vgn, pv_hash, &scan_done_once))
+		if (!fn(fid, mem, vg, n, vgn, pv_hash, scan_done_once, report_missing_devices))
 			return_0;
 	}
 
@@ -635,12 +642,14 @@
 }
 
 static struct volume_group *_read_vg(struct format_instance *fid,
-				     struct config_tree *cft)
+				     struct config_tree *cft,
+				     unsigned use_cached_pvs)
 {
 	struct config_node *vgn, *cn;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL;
 	struct dm_pool *mem = dm_pool_create("lvm2 vg_read", VG_MEMPOOL_CHUNK);
+	unsigned scan_done_once = use_cached_pvs;
 
 	if (!mem)
 		return_NULL;
@@ -743,7 +752,7 @@
 
 	dm_list_init(&vg->pvs);
 	if (!_read_sections(fid, "physical_volumes", _read_pv, mem, vg,
-			    vgn, pv_hash, 0)) {
+			    vgn, pv_hash, 0, &scan_done_once)) {
 		log_error("Couldn't find all physical volumes for volume "
 			  "group %s.", vg->name);
 		goto bad;
@@ -761,14 +770,14 @@
 	}
 
 	if (!_read_sections(fid, "logical_volumes", _read_lvnames, mem, vg,
-			    vgn, pv_hash, 1)) {
+			    vgn, pv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
 	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, mem, vg,
-			    vgn, pv_hash, 1)) {
+			    vgn, pv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
 		goto bad;


