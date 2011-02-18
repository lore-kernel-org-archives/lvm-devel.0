From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:47:42 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c daemons ...
Message-ID: <20110218144742.5913.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:47:31

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c clvmd.h 
	lib/activate   : activate.c activate.h 
	lib/filters    : filter-regex.c 
	lib/metadata   : lv.h lv_manip.c metadata-exported.h metadata.c 
	                 mirror.c 
	lib/report     : properties.c report.c 
	lib/uuid       : uuid.c 
	liblvm         : lvm_vg.c 
	tools          : lvcreate.c reporter.c toollib.c toollib.h 
	                 vgcfgrestore.c vgcreate.c vgextend.c vgmerge.c 
	                 vgreduce.c vgrename.c vgsplit.c 

Log message:
	Const fixing
	
	Fixing some const warnings - with API change in:
	
	int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
	
	Change is needed - as lvm2api expects const behaviour here.
	So vg_extend() is doing local strdup for unescaping.
	
	skip_dev_dir return const char* from const char* vg_name.
	
	Rest of the patch is cleanup of related warnings.
	
	Also using dm_report_filed_string() API change to simplify
	casting in _string_disp and _lvname_disp.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1919&r2=1.1920
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.195&r2=1.196
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.247&r2=1.248
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.423&r2=1.424
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.228&r2=1.229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.219&r2=1.220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2011/02/18 14:34:41	1.1919
+++ LVM2/WHATS_NEW	2011/02/18 14:47:28	1.1920
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fixing some const cast gcc warnings in the code.
   Use char* arithmetic in _text_write(), _text_read() & send_message().
   Fix compilation when devmapper is dissabled.
   Remove fs_unlock() from lv_suspend error path.
--- LVM2/daemons/clvmd/clvmd.c	2011/02/18 14:34:41	1.94
+++ LVM2/daemons/clvmd/clvmd.c	2011/02/18 14:47:29	1.95
@@ -2091,7 +2091,7 @@
 	return -1;
 }
 
-void process_message(struct local_client *client, const char *buf, int len,
+void process_message(struct local_client *client, char *buf, int len,
 		     const char *csid)
 {
 	struct clvm_header *inheader;
--- LVM2/daemons/clvmd/clvmd.h	2011/01/17 23:13:14	1.13
+++ LVM2/daemons/clvmd/clvmd.h	2011/02/18 14:47:29	1.14
@@ -112,7 +112,7 @@
 extern int add_client(struct local_client *new_client);
 
 extern void clvmd_cluster_init_completed(void);
-extern void process_message(struct local_client *client, const char *buf,
+extern void process_message(struct local_client *client, char *buf,
 			    int len, const char *csid);
 extern void debuglog(const char *fmt, ... )
   __attribute__ ((format(printf, 1, 2)));
--- LVM2/lib/activate/activate.c	2011/02/18 14:29:39	1.195
+++ LVM2/lib/activate/activate.c	2011/02/18 14:47:29	1.196
@@ -162,7 +162,7 @@
 {
 	return 0;
 }
-int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr)
 {
 	return 0;
@@ -568,7 +568,7 @@
 }
 
 /* FIXME Merge with snapshot_percent */
-int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr)
 {
 	int r;
--- LVM2/lib/activate/activate.h	2011/02/18 00:36:05	1.75
+++ LVM2/lib/activate/activate.h	2011/02/18 14:47:29	1.76
@@ -85,7 +85,7 @@
  * Returns 1 if percent has been set, else 0.
  */
 int lv_snapshot_percent(const struct logical_volume *lv, percent_t *percent);
-int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
+int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr);
 
 /*
--- LVM2/lib/filters/filter-regex.c	2010/12/20 13:45:40	1.30
+++ LVM2/lib/filters/filter-regex.c	2011/02/18 14:47:30	1.31
@@ -135,7 +135,7 @@
 	/*
 	 * build the matcher.
 	 */
-	if (!(rf->engine = dm_regex_create(rf->mem, (const char **) regex,
+	if (!(rf->engine = dm_regex_create(rf->mem, (const char * const*) regex,
 					   count)))
 		goto_out;
 	r = 1;
--- LVM2/lib/metadata/lv.h	2010/11/17 20:08:14	1.17
+++ LVM2/lib/metadata/lv.h	2011/02/18 14:47:30	1.18
@@ -23,7 +23,7 @@
 
 struct logical_volume {
 	union lvid lvid;
-	char *name;
+	const char *name;
 
 	struct volume_group *vg;
 
--- LVM2/lib/metadata/lv_manip.c	2011/02/04 20:30:18	1.247
+++ LVM2/lib/metadata/lv_manip.c	2011/02/18 14:47:30	1.248
@@ -1897,7 +1897,8 @@
 			  struct logical_volume *lv,
 			  const char *lv_name_old, const char *lv_name_new)
 {
-	char *suffix, *new_name;
+	const char *suffix;
+	char *new_name;
 	size_t len;
 
 	/*
--- LVM2/lib/metadata/metadata-exported.h	2011/02/18 14:11:23	1.175
+++ LVM2/lib/metadata/metadata-exported.h	2011/02/18 14:47:30	1.176
@@ -410,9 +410,9 @@
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
+int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
 	      struct pvcreate_params *pp);
-int vg_reduce(struct volume_group *vg, char *pv_name);
+int vg_reduce(struct volume_group *vg, const char *pv_name);
 int vg_change_tag(struct volume_group *vg, const char *tag, int add_tag);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
@@ -698,7 +698,7 @@
 						  uint32_t lv_type);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
-percent_t copy_percent(struct logical_volume *lv_mirr);
+percent_t copy_percent(const struct logical_volume *lv_mirr);
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
@@ -721,7 +721,7 @@
 int vg_has_unknown_segments(const struct volume_group *vg);
 
 struct vgcreate_params {
-	char *vg_name;
+	const char *vg_name;
 	uint32_t extent_size;
 	size_t max_pv;
 	size_t max_lv;
--- LVM2/lib/metadata/metadata.c	2011/02/18 14:16:12	1.423
+++ LVM2/lib/metadata/metadata.c	2011/02/18 14:47:30	1.424
@@ -662,33 +662,38 @@
  * - pp: parameters to pass to implicit pvcreate; if NULL, do not pvcreate
  *
  */
-int vg_extend(struct volume_group *vg, int pv_count, char **pv_names,
+int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
 	      struct pvcreate_params *pp)
 {
 	int i;
+	char *pv_name;
 
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
 		return 0;
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
-		unescape_colons_and_at_signs(pv_names[i], NULL, NULL);
-		if (!vg_extend_single_pv(vg, pv_names[i], pp))
-			goto bad;
+		if (!(pv_name = dm_strdup(pv_names[i]))) {
+			log_error("Failed to duplicate pv name %s.", pv_names[i]);
+			return 0;
+		}
+		unescape_colons_and_at_signs(pv_name, NULL, NULL);
+		if (!vg_extend_single_pv(vg, pv_name, pp)) {
+			log_error("Unable to add physical volume '%s' to "
+				  "volume group '%s'.", pv_name, vg->name);
+			dm_free(pv_name);
+			return 0;
+		}
+		dm_free(pv_name);
 	}
 
 /* FIXME Decide whether to initialise and add new mdahs to format instance */
 
 	return 1;
-
-      bad:
-	log_error("Unable to add physical volume '%s' to "
-		  "volume group '%s'.", pv_names[i], vg->name);
-	return 0;
 }
 
 /* FIXME: use this inside vgreduce_single? */
-int vg_reduce(struct volume_group *vg, char *pv_name)
+int vg_reduce(struct volume_group *vg, const char *pv_name)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -1875,7 +1880,7 @@
 {
 	struct lv_list *lvl1, *lvl2;
 	struct pv_list *pvl;
-	char *name1, *name2;
+	const char *name1, *name2;
 
 	if (lvs_in_vg_activated(vg_from)) {
 		log_error("Logical volumes in \"%s\" must be inactive",
--- LVM2/lib/metadata/mirror.c	2011/02/18 14:16:12	1.142
+++ LVM2/lib/metadata/mirror.c	2011/02/18 14:47:30	1.143
@@ -1514,7 +1514,7 @@
 	return lvs;
 }
 
-percent_t copy_percent(struct logical_volume *lv_mirr)
+percent_t copy_percent(const struct logical_volume *lv_mirr)
 {
 	uint32_t numerator = 0u, denominator = 0u;
 	struct lv_segment *seg;
@@ -1727,8 +1727,8 @@
 						 int in_sync)
 {
 	struct logical_volume *log_lv;
-	const char *suffix, *c;
-	char *lv_name;
+	const char *suffix, *lv_name;
+	char *tmp_name;
 	size_t len;
 	struct lv_segment *seg;
 
@@ -1747,21 +1747,21 @@
 	    strstr(seg_lv(seg, 0)->name, MIRROR_SYNC_LAYER)) {
 		lv_name = lv->name;
 		suffix = "_mlogtmp_%d";
-	} else if ((c = strstr(lv->name, MIRROR_SYNC_LAYER))) {
-		len = c - lv->name + 1;
-		if (!(lv_name = alloca(len)) ||
-		    !dm_snprintf(lv_name, len, "%s", lv->name)) {
+	} else if ((lv_name = strstr(lv->name, MIRROR_SYNC_LAYER))) {
+		len = lv_name - lv->name + 1;
+		if (!(tmp_name = alloca(len)) ||
+		    !dm_snprintf(tmp_name, len, "%s", lv->name)) {
 			log_error("mirror log name allocation failed");
 			return 0;
 		}
+		lv_name = tmp_name;
 		suffix = "_mlog";
 	} else {
 		lv_name = lv->name;
 		suffix = "_mlog";
 	}
 
-	if (!(log_lv = _create_mirror_log(lv, ah, alloc,
-					  (const char *) lv_name, suffix))) {
+	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv_name, suffix))) {
 		log_error("Failed to create mirror log.");
 		return NULL;
 	}
--- LVM2/lib/report/properties.c	2011/01/05 12:33:52	1.28
+++ LVM2/lib/report/properties.c	2011/02/18 14:47:30	1.29
@@ -88,8 +88,7 @@
 
 static percent_t _copy_percent(const struct logical_volume *lv) {
 	percent_t perc;
-	if (!lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv,
-			   0, &perc, NULL))
+	if (!lv_mirror_percent(lv->vg->cmd, lv, 0, &perc, NULL))
 		perc = PERCENT_INVALID;
 	return perc;
 }
--- LVM2/lib/report/report.c	2010/11/30 11:53:32	1.141
+++ LVM2/lib/report/report.c	2011/02/18 14:47:30	1.142
@@ -44,7 +44,7 @@
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
 {
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char * const *) data);
 }
 
 static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -307,10 +307,8 @@
 	char *repstr, *lvname;
 	size_t len;
 
-	if (lv_is_visible(lv)) {
-		repstr = lv->name;
-		return dm_report_field_string(rh, field, (const char **) &repstr);
-	}
+	if (lv_is_visible(lv))
+		return dm_report_field_string(rh, field, &lv->name);
 
 	len = strlen(lv->name) + 3;
 	if (!(repstr = dm_pool_zalloc(mem, len))) {
@@ -615,7 +613,7 @@
 {
 	char *repstr = NULL;
 
-	if (!(repstr = id_format_and_copy(mem, (struct id *)data)))
+	if (!(repstr = id_format_and_copy(mem, data)))
 		return_0;
 
 	dm_report_field_set_value(field, repstr, NULL);
@@ -853,7 +851,7 @@
 			     struct dm_report_field *field,
 			     const void *data, void *private __attribute__((unused)))
 {
-	struct logical_volume *lv = (struct logical_volume *) data;
+	const struct logical_volume *lv = (const struct logical_volume *) data;
 	percent_t percent;
 	uint64_t *sortval;
 	char *repstr;
@@ -899,7 +897,7 @@
 
 static struct volume_group _dummy_vg = {
 	.fid = &_dummy_fid,
-	.name = (char *) "",
+	.name = "",
 	.system_id = (char *) "",
 	.pvs = { &(_dummy_vg.pvs), &(_dummy_vg.pvs) },
 	.lvs = { &(_dummy_vg.lvs), &(_dummy_vg.lvs) },
--- LVM2/lib/uuid/uuid.c	2011/01/28 10:14:09	1.32
+++ LVM2/lib/uuid/uuid.c	2011/02/18 14:47:30	1.33
@@ -158,7 +158,7 @@
 {
 	int i, tot;
 
-	static unsigned group_size[] = { 6, 4, 4, 4, 4, 4, 6 };
+	static const unsigned group_size[] = { 6, 4, 4, 4, 4, 4, 6 };
 
 	assert(ID_LEN == 32);
 
--- LVM2/liblvm/lvm_vg.c	2010/12/14 23:20:58	1.50
+++ LVM2/liblvm/lvm_vg.c	2011/02/18 14:47:30	1.51
@@ -79,7 +79,7 @@
 	}
 
 	pvcreate_params_set_defaults(&pp);
-	if (!vg_extend(vg, 1, (char **) &device, &pp)) {
+	if (!vg_extend(vg, 1, &device, &pp)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return -1;
 	}
@@ -98,7 +98,7 @@
 	if (!vg_check_write_mode(vg))
 		return -1;
 
-	if (!vg_reduce(vg, (char *)device))
+	if (!vg_reduce(vg, device))
 		return -1;
 	return 0;
 }
--- LVM2/tools/lvcreate.c	2011/01/11 17:05:10	1.228
+++ LVM2/tools/lvcreate.c	2011/02/18 14:47:31	1.229
@@ -31,7 +31,7 @@
 {
 	int argc = *pargc;
 	char **argv = *pargv, *ptr;
-	char *vg_name;
+	const char *vg_name;
 
 	lp->lv_name = arg_str_value(cmd, name_ARG, NULL);
 
--- LVM2/tools/reporter.c	2010/12/08 20:50:51	1.64
+++ LVM2/tools/reporter.c	2011/02/18 14:47:31	1.65
@@ -61,7 +61,7 @@
 
 	struct volume_group _free_vg = {
 		.cmd = cmd,
-		.name = (char *)"",
+		.name = "",
 	};
 
         if (!(_free_vg.vgmem = dm_pool_create("_free_vg", 10240)))
@@ -69,7 +69,7 @@
 
 	struct logical_volume _free_logical_volume = {
 		.vg = vg ?: &_free_vg,
-		.name = (char *) "",
+		.name = "",
 		.snapshot = NULL,
 		.status = VISIBLE_LV,
 		.major = -1,
--- LVM2/tools/toollib.c	2011/01/24 13:38:32	1.219
+++ LVM2/tools/toollib.c	2011/02/18 14:47:31	1.220
@@ -28,7 +28,7 @@
 /*
  * Strip dev_dir if present
  */
-char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
+const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 		   unsigned *dev_dir_found)
 {
 	const char *dmdir = dm_dir();
@@ -54,7 +54,7 @@
 		    *layer) {
 			log_error("skip_dev_dir: Couldn't split up device name %s",
 				  vg_name);
-			return (char *) vg_name;
+			return vg_name;
 		}
 		vglv_sz = strlen(vgname) + strlen(lvname) + 2;
 		if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
@@ -62,7 +62,7 @@
 				 *lvname ? "/" : "",
 				 lvname) < 0) {
 			log_error("vg/lv string alloc failed");
-			return (char *) vg_name;
+			return vg_name;
 		}
 		return vglv;
 	}
@@ -76,7 +76,7 @@
 	} else if (dev_dir_found)
 		*dev_dir_found = 0;
 
-	return (char *) vg_name;
+	return vg_name;
 }
 
 /*
@@ -898,7 +898,7 @@
  */
 char *default_vgname(struct cmd_context *cmd)
 {
-	char *vg_path;
+	const char *vg_path;
 
 	/* Take default VG from environment? */
 	vg_path = getenv("LVM_VG_NAME");
--- LVM2/tools/toollib.h	2011/01/24 13:38:32	1.76
+++ LVM2/tools/toollib.h	2011/02/18 14:47:31	1.77
@@ -84,8 +84,8 @@
 
 char *default_vgname(struct cmd_context *cmd);
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
-char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
-		   unsigned *dev_dir_found);
+const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
+			 unsigned *dev_dir_found);
 
 /*
  * Builds a list of pv's from the names in argv.  Used in
--- LVM2/tools/vgcfgrestore.c	2009/10/16 17:41:53	1.24
+++ LVM2/tools/vgcfgrestore.c	2011/02/18 14:47:31	1.25
@@ -17,7 +17,7 @@
 
 int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *vg_name = NULL;
+	const char *vg_name = NULL;
 
 	if (argc == 1) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
--- LVM2/tools/vgcreate.c	2010/12/08 20:50:51	1.82
+++ LVM2/tools/vgcreate.c	2011/02/18 14:47:31	1.83
@@ -74,7 +74,7 @@
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc, argv, &pp))
+	if (!vg_extend(vg, argc, (const char* const*)argv, &pp))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
--- LVM2/tools/vgextend.c	2010/12/08 20:50:51	1.62
+++ LVM2/tools/vgextend.c	2011/02/18 14:47:31	1.63
@@ -40,7 +40,7 @@
 
 int vgextend(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *vg_name;
+	const char *vg_name;
 	struct volume_group *vg = NULL;
 	int r = ECMD_FAILED;
 	struct pvcreate_params pp;
@@ -107,7 +107,7 @@
 		}
 
 		/* extend vg */
-		if (!vg_extend(vg, argc, argv, &pp))
+		if (!vg_extend(vg, argc, (const char* const*)argv, &pp))
 			goto_bad;
 
 		if (arg_count(cmd, metadataignore_ARG) &&
--- LVM2/tools/vgmerge.c	2010/12/14 17:51:10	1.71
+++ LVM2/tools/vgmerge.c	2011/02/18 14:47:31	1.72
@@ -163,7 +163,7 @@
 
 int vgmerge(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *vg_name_to, *vg_name_from;
+	const char *vg_name_to, *vg_name_from;
 	int opt = 0;
 	int ret = 0, ret_max = 0;
 
--- LVM2/tools/vgreduce.c	2010/12/08 20:50:51	1.105
+++ LVM2/tools/vgreduce.c	2011/02/18 14:47:31	1.106
@@ -457,7 +457,7 @@
 int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct volume_group *vg;
-	char *vg_name;
+	const char *vg_name;
 	int ret = ECMD_FAILED;
 	int fixed = 1;
 	int repairing = arg_count(cmd, removemissing_ARG);
--- LVM2/tools/vgrename.c	2010/12/22 15:36:42	1.74
+++ LVM2/tools/vgrename.c	2011/02/18 14:47:31	1.75
@@ -63,7 +63,7 @@
 	int found_id = 0;
 	struct dm_list *vgids;
 	struct str_list *sl;
-	char *vg_name_new;
+	const char *vg_name_new;
 	const char *vgid = NULL, *vg_name, *vg_name_old;
 	char old_path[NAME_LEN], new_path[NAME_LEN];
 	struct volume_group *vg = NULL;
--- LVM2/tools/vgsplit.c	2010/12/14 17:51:10	1.104
+++ LVM2/tools/vgsplit.c	2011/02/18 14:47:31	1.105
@@ -281,7 +281,7 @@
 {
 	struct vgcreate_params vp_new;
 	struct vgcreate_params vp_def;
-	char *vg_name_from, *vg_name_to;
+	const char *vg_name_from, *vg_name_to;
 	struct volume_group *vg_to = NULL, *vg_from = NULL;
 	int opt;
 	int existing_vg = 0;


