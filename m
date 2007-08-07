From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Aug 2007 16:57:09 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20070807165709.9377.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-07 16:57:09

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Some simple fixups for last checkin:
	* remove "_" from "return_0"
	* improve some naming and terminology
	* add 'const'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/lib/metadata/lv_manip.c	2007/08/06 20:35:48	1.119
+++ LVM2/lib/metadata/lv_manip.c	2007/08/07 16:57:09	1.120
@@ -1472,12 +1472,12 @@
 	if (find_lv_in_vg(vg, new_name)) {
 		log_error("Logical volume \"%s\" already exists in "
 			  "volume group \"%s\"", new_name, vg->name);
-		return_0;
+		return 0;
 	}
 
 	if (lv->status & LOCKED) {
 		log_error("Cannot rename locked LV %s", lv->name);
-		return_0;
+		return 0;
 	}
 
 	lv->name = new_name;
@@ -1489,7 +1489,7 @@
  * Returns a pointer to LV name suffix.
  * Returns NULL if the LV doesn't have suffix.
  */
-static char * sub_lv_name_suffix(const char *lvname)
+static char *_sub_lv_name_suffix(const char *lvname)
 {
 	char *s;
 
@@ -1504,24 +1504,23 @@
 
 /*
  * Rename sub LV.
- * Returns 0 on failure, 1 on success.
  * If a new name for the sub LV cannot be determined, 1 is returned.
- * 'lv_main_old' and 'lv_main_new' are old and new names of the main LV.
+ * 'lv_name_old' and 'lv_name_new' are old and new names of the main LV.
  */
 static int _rename_sub_lv(struct cmd_context *cmd,
 			  struct logical_volume *lv,
-			  char *lv_main_old, char *lv_main_new)
+			  const char *lv_name_old, const char *lv_name_new)
 {
 	char *suffix, *new_name;
-	size_t l;
+	size_t len;
 
 	/* Rename only if the lv has known suffix */
-	if (!(suffix = sub_lv_name_suffix(lv->name)))
+	if (!(suffix = _sub_lv_name_suffix(lv->name)))
 		return 1;
 
-	/* Make sure that lv->name is exactly a lv_main_old + suffix */
-	l = suffix - lv->name;
-	if (strlen(lv_main_old) != l || strncmp(lv->name, lv_main_old, l))
+	/* Make sure that lv->name is exactly a lv_name_old + suffix */
+	len = suffix - lv->name;
+	if (strlen(lv_name_old) != len || strncmp(lv->name, lv_name_old, len))
 		return 1;
 
  	/*
@@ -1530,15 +1529,15 @@
 	 *        if the sub LV is "lvol0_mlog" and
 	 *        a new name for main LV is "lvol1"
 	 */
-	l = strlen(lv_main_new) + strlen(suffix) + 1;
-	new_name = dm_pool_alloc(cmd->mem, l);
+	len = strlen(lv_name_new) + strlen(suffix) + 1;
+	new_name = dm_pool_alloc(cmd->mem, len);
 	if (!new_name) {
 		log_error("Failed to allocate space for new name");
-		return_0;
+		return 0;
 	}
-	if (!dm_snprintf(new_name, l, "%s%s", lv_main_new, suffix)) {
+	if (!dm_snprintf(new_name, len, "%s%s", lv_name_new, suffix)) {
 		log_error("Failed to create new name");
-		return_0;
+		return 0;
 	}
 
 	/* Rename it */
@@ -1569,11 +1568,11 @@
 
 	list_iterate_items(seg, &lv->segments) {
 		if (seg->log_lv && !func(cmd, seg->log_lv, data))
-			return_0;
+			return 0;
 		for (s = 0; s < seg->area_count; s++)
 			if (seg_type(seg, s) == AREA_LV &&
 			    !func(cmd, seg_lv(seg, s), data))
-				return_0;
+				return 0;
 	}
 
 	return 1;
@@ -1593,7 +1592,7 @@
 
 	/* rename is not allowed on sub LVs */
 	if ((lv->status & MIRROR_LOG) || (lv->status & MIRROR_IMAGE)) {
-		log_error("Cannot rename hidden LV \"%s\".", lv->name);
+		log_error("Cannot rename internal LV \"%s\".", lv->name);
 		return 0;
 	}
 
@@ -1609,7 +1608,7 @@
 	}
 
 	if (!archive(vg))
-		return_0;
+		return 0;
 
 	/* rename sub LVs */
 	names[0] = lv->name;
@@ -1625,7 +1624,7 @@
 
 	log_verbose("Writing out updated volume group");
 	if (!vg_write(vg))
-		return_0;
+		return 0;
 
 	backup(vg);
 


