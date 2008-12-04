From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: Thu, 04 Dec 2008 15:54:48 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/d ...
Message-ID: <20081204155429.27098.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2008-12-04 15:54:27

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/display    : display.c 
	lib/format_text: export.c 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	                 metadata.h snapshot_manip.c 
	lib/report     : report.c 
	tools          : lvchange.c lvdisplay.c lvscan.c reporter.c 

Log message:
	Added displayable_lvs_in_vg and lv_is_displayable functions to deal with
	the counts of visible LVs from user's perspective consistently throughout
	the code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1003&r2=1.1004
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.159&r2=1.160
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.195&r2=1.196
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvdisplay.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2008/12/01 20:14:33	1.1003
+++ LVM2/WHATS_NEW	2008/12/04 15:54:26	1.1004
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Use displayable_lvs_in_vg and lv_is_displayable for consistency throughout.
   Fix race in vgcreate that would result in second caller overwriting first.
   Fix uninitialised lv_count in vgdisplay -c.
   Don't skip updating pvid hash when lvmcache_info struct got swapped.
--- LVM2/lib/activate/activate.c	2008/11/03 22:14:27	1.140
+++ LVM2/lib/activate/activate.c	2008/12/04 15:54:26	1.141
@@ -666,7 +666,7 @@
 		return 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (lvl->lv->status & VISIBLE_LV)
+		if (lv_is_displayable(lvl->lv))
 			count += (_lv_open_count(vg->cmd, lvl->lv) > 0);
 	}
 
--- LVM2/lib/display/display.c	2008/12/01 17:38:35	1.95
+++ LVM2/lib/display/display.c	2008/12/04 15:54:27	1.96
@@ -574,8 +574,6 @@
 {
 	uint32_t access_str;
 	uint32_t active_pvs;
-	uint32_t lv_count = 0;
-	struct lv_list *lvl;
 	char uuid[64] __attribute((aligned(8)));
 
 	active_pvs = vg->pv_count - vg_missing_pv_count(vg);
@@ -607,12 +605,8 @@
 			  vg->status & SHARED ? "yes" : "no");
 	}
 
-	dm_list_iterate_items(lvl, &vg->lvs)
-		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
-			lv_count++;
-
 	log_print("MAX LV                %u", vg->max_lv);
-	log_print("Cur LV                %u", lv_count);
+	log_print("Cur LV                %u", displayable_lvs_in_vg(vg));
 	log_print("Open LV               %u", lvs_in_vg_opened(vg));
 /****** FIXME Max LV Size
       log_print ( "MAX LV Size           %s",
@@ -656,17 +650,11 @@
 void vgdisplay_colons(const struct volume_group *vg)
 {
 	uint32_t active_pvs;
-	uint32_t lv_count = 0;
-	struct lv_list *lvl;
 	const char *access_str;
 	char uuid[64] __attribute((aligned(8)));
 
 	active_pvs = vg->pv_count - vg_missing_pv_count(vg);
 
-	dm_list_iterate_items(lvl, &vg->lvs)
-		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
-			lv_count++;
-
 	switch (vg->status & (LVM_READ | LVM_WRITE)) {
 		case LVM_READ | LVM_WRITE:
 			access_str = "r/w";
@@ -693,7 +681,7 @@
 		vg->status,
 		/* internal volume group number; obsolete */
 		vg->max_lv,
-		vg->lv_count,
+		displayable_lvs_in_vg(vg),
 		lvs_in_vg_opened(vg),
 		/* FIXME: maximum logical volume size */
 		vg->max_pv,
--- LVM2/lib/format_text/export.c	2008/11/03 22:14:28	1.65
+++ LVM2/lib/format_text/export.c	2008/12/04 15:54:27	1.66
@@ -592,14 +592,14 @@
 	 * Write visible LVs first
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!(lvl->lv->status & VISIBLE_LV))
+		if (!(lv_is_displayable(lvl->lv)))
 			continue;
 		if (!_print_lv(f, lvl->lv))
 			return_0;
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if ((lvl->lv->status & VISIBLE_LV))
+		if ((lv_is_displayable(lvl->lv)))
 			continue;
 		if (!_print_lv(f, lvl->lv))
 			return_0;
--- LVM2/lib/metadata/lv_manip.c	2008/11/03 22:14:29	1.159
+++ LVM2/lib/metadata/lv_manip.c	2008/12/04 15:54:27	1.160
@@ -1715,7 +1715,7 @@
 	struct lv_names lv_names;
 
 	/* rename is not allowed on sub LVs */
-	if (!lv_is_visible(lv)) {
+	if (!lv_is_displayable(lv)) {
 		log_error("Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
 	}
--- LVM2/lib/metadata/metadata-exported.h	2008/11/03 22:14:29	1.55
+++ LVM2/lib/metadata/metadata-exported.h	2008/12/04 15:54:27	1.56
@@ -483,6 +483,9 @@
 int lv_is_cow(const struct logical_volume *lv);
 int lv_is_visible(const struct logical_volume *lv);
 
+/* Test if given LV is visible from user's perspective */
+int lv_is_displayable(const struct logical_volume *lv);
+
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
 /* Given a cow LV, return return the snapshot lv_segment that uses it */
--- LVM2/lib/metadata/metadata.c	2008/11/03 22:14:29	1.195
+++ LVM2/lib/metadata/metadata.c	2008/12/04 15:54:27	1.196
@@ -337,6 +337,7 @@
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
+	unsigned lv_count;
 	int ret = 1;
 
 	if (!vg || !consistent || vg_missing_pv_count(vg)) {
@@ -350,22 +351,26 @@
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return 0;
 
-	if (vg->lv_count) {
+	lv_count = displayable_lvs_in_vg(vg);
+
+	if (lv_count) {
 		if ((force == PROMPT) &&
 		    (yes_no_prompt("Do you really want to remove volume "
-				   "group \"%s\" containing %d "
+				   "group \"%s\" containing %u "
 				   "logical volumes? [y/n]: ",
-				   vg_name, vg->lv_count) == 'n')) {
+				   vg_name, lv_count) == 'n')) {
 			log_print("Volume group \"%s\" not removed", vg_name);
 			return 0;
 		}
 		if (!remove_lvs_in_vg(cmd, vg, force))
 			return 0;
 	}
+
+	lv_count = displayable_lvs_in_vg(vg);
 	
-	if (vg->lv_count) {
-		log_error("Volume group \"%s\" still contains %d "
-			  "logical volume(s)", vg_name, vg->lv_count);
+	if (lv_count) {
+		log_error("Volume group \"%s\" still contains %u "
+			  "logical volume(s)", vg_name, lv_count);
 		return 0;
 	}
 
@@ -1098,6 +1103,18 @@
 	return 1;
 }
 
+unsigned displayable_lvs_in_vg(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned lv_count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lv_is_displayable(lvl->lv))
+			lv_count++;
+
+	return lv_count;
+}
+
 /*
  * Determine whether two vgs are compatible for merging.
  */
--- LVM2/lib/metadata/metadata.h	2008/11/03 22:14:29	1.184
+++ LVM2/lib/metadata/metadata.h	2008/12/04 15:54:27	1.185
@@ -321,6 +321,11 @@
 struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 
 /*
+ * Count LVs that are visible from user's perspective.
+ */
+unsigned displayable_lvs_in_vg(const struct volume_group *vg);
+
+/*
  * For internal metadata caching.
  */
 int export_vg_to_buffer(struct volume_group *vg, char **buf);
--- LVM2/lib/metadata/snapshot_manip.c	2008/11/03 22:14:29	1.32
+++ LVM2/lib/metadata/snapshot_manip.c	2008/12/04 15:54:27	1.33
@@ -36,6 +36,14 @@
 	return lv->status & VISIBLE_LV ? 1 : 0;
 }
 
+int lv_is_displayable(const struct logical_volume *lv)
+{
+	if (lv->status & SNAPSHOT)
+		return 0;
+
+	return (lv->status & VISIBLE_LV) || lv_is_cow(lv) ? 1 : 0;
+}
+
 /* Given a cow LV, return the snapshot lv_segment that uses it */
 struct lv_segment *find_cow(const struct logical_volume *lv)
 {
--- LVM2/lib/report/report.c	2008/11/03 22:14:29	1.89
+++ LVM2/lib/report/report.c	2008/12/04 15:54:27	1.90
@@ -511,7 +511,7 @@
 	char *repstr, *lvname;
 	size_t len;
 
-	if (lv_is_visible(lv)) {
+	if (lv_is_displayable(lv)) {
 		repstr = lv->name;
 		return dm_report_field_string(rh, field, (const char **) &repstr);
 	}
@@ -911,12 +911,9 @@
 			 const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-        struct lv_list *lvl;
-	uint32_t count = 0;
+	uint32_t count;
 
-        dm_list_iterate_items(lvl, &vg->lvs)
-		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
-			count++;
+	count = displayable_lvs_in_vg(vg);	
 
 	return _uint32_disp(rh, mem, field, &count, private);
 }
--- LVM2/tools/lvchange.c	2008/07/31 13:03:01	1.93
+++ LVM2/tools/lvchange.c	2008/12/04 15:54:27	1.94
@@ -590,7 +590,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!(lv->status & VISIBLE_LV)) {
+	if (!(lv_is_displayable(lv))) {
 		log_error("Unable to change internal LV %s directly",
 			  lv->name);
 		return ECMD_FAILED;
--- LVM2/tools/lvdisplay.c	2008/01/30 14:00:01	1.20
+++ LVM2/tools/lvdisplay.c	2008/12/04 15:54:27	1.21
@@ -18,7 +18,7 @@
 static int _lvdisplay_single(struct cmd_context *cmd, struct logical_volume *lv,
 			     void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
 		return ECMD_PROCESSED;
 
 	if (arg_count(cmd, colon_ARG))
--- LVM2/tools/lvscan.c	2008/11/03 22:14:30	1.36
+++ LVM2/tools/lvscan.c	2008/12/04 15:54:27	1.37
@@ -27,7 +27,7 @@
 
 	const char *active_str, *snapshot_str;
 
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
 		return ECMD_PROCESSED;
 
 	inkernel = lv_info(cmd, lv, &info, 1, 0) && info.exists;
--- LVM2/tools/reporter.c	2008/11/03 22:14:30	1.41
+++ LVM2/tools/reporter.c	2008/12/04 15:54:27	1.42
@@ -36,7 +36,7 @@
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
 		return ECMD_PROCESSED;
 
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
@@ -102,7 +102,7 @@
 static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 			  void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
+	if (!arg_count(cmd, all_ARG) && !lv_is_displayable(lv))
 		return ECMD_PROCESSED;
 
 	return process_each_segment_in_lv(cmd, lv, handle, _segs_single);


