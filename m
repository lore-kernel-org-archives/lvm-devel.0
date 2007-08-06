From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Aug 2007 20:35:48 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20070806203548.25477.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-06 20:35:48

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Add support for renaming mirrored LVs.
	Patch by Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/lib/metadata/lv_manip.c	2007/08/06 14:57:48	1.118
+++ LVM2/lib/metadata/lv_manip.c	2007/08/06 20:35:48	1.119
@@ -1461,6 +1461,126 @@
 }
 
 /*
+ * Minimal LV renaming function.
+ * Metadata transaction should be made by caller.
+ * Assumes new_name is allocated from cmd->mem pool.
+ */
+static int _rename_single_lv(struct logical_volume *lv, char *new_name)
+{
+	struct volume_group *vg = lv->vg;
+
+	if (find_lv_in_vg(vg, new_name)) {
+		log_error("Logical volume \"%s\" already exists in "
+			  "volume group \"%s\"", new_name, vg->name);
+		return_0;
+	}
+
+	if (lv->status & LOCKED) {
+		log_error("Cannot rename locked LV %s", lv->name);
+		return_0;
+	}
+
+	lv->name = new_name;
+
+	return 1;
+}
+
+/*
+ * Returns a pointer to LV name suffix.
+ * Returns NULL if the LV doesn't have suffix.
+ */
+static char * sub_lv_name_suffix(const char *lvname)
+{
+	char *s;
+
+	if ((s = strstr(lvname, "_mimage")))
+		return s;
+
+	if ((s = strstr(lvname, "_mlog")))
+		return s;
+
+	return NULL;
+}
+
+/*
+ * Rename sub LV.
+ * Returns 0 on failure, 1 on success.
+ * If a new name for the sub LV cannot be determined, 1 is returned.
+ * 'lv_main_old' and 'lv_main_new' are old and new names of the main LV.
+ */
+static int _rename_sub_lv(struct cmd_context *cmd,
+			  struct logical_volume *lv,
+			  char *lv_main_old, char *lv_main_new)
+{
+	char *suffix, *new_name;
+	size_t l;
+
+	/* Rename only if the lv has known suffix */
+	if (!(suffix = sub_lv_name_suffix(lv->name)))
+		return 1;
+
+	/* Make sure that lv->name is exactly a lv_main_old + suffix */
+	l = suffix - lv->name;
+	if (strlen(lv_main_old) != l || strncmp(lv->name, lv_main_old, l))
+		return 1;
+
+ 	/*
+	 * Compose a new name for sub lv:
+	 *   e.g. new name is "lvol1_mlog"
+	 *        if the sub LV is "lvol0_mlog" and
+	 *        a new name for main LV is "lvol1"
+	 */
+	l = strlen(lv_main_new) + strlen(suffix) + 1;
+	new_name = dm_pool_alloc(cmd->mem, l);
+	if (!new_name) {
+		log_error("Failed to allocate space for new name");
+		return_0;
+	}
+	if (!dm_snprintf(new_name, l, "%s%s", lv_main_new, suffix)) {
+		log_error("Failed to create new name");
+		return_0;
+	}
+
+	/* Rename it */
+	return _rename_single_lv(lv, new_name);
+}
+
+/* Callback for _for_each_sub_lv */
+static int _rename_cb(struct cmd_context *cmd, struct logical_volume *lv,
+		      void *data)
+{
+	char **names = (char **) data;
+
+	return _rename_sub_lv(cmd, lv, names[0], names[1]);
+}
+
+/*
+ * Loop down sub LVs and call "func" for each.
+ * "func" is responsible to log necessary information on failure.
+ */
+static int _for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
+			    int (*func)(struct cmd_context *cmd,
+				        struct logical_volume *lv,
+				        void *data),
+			    void *data)
+{
+	struct lv_segment *seg;
+	int s;
+
+	list_iterate_items(seg, &lv->segments) {
+		if (seg->log_lv && !func(cmd, seg->log_lv, data))
+			return_0;
+		for (s = 0; s < seg->area_count; s++)
+			if (seg_type(seg, s) == AREA_LV &&
+			    !func(cmd, seg_lv(seg, s), data))
+				return_0;
+	}
+
+	return 1;
+}
+
+
+/*
  * Core of LV renaming routine.
  * VG must be locked by caller.
  * Returns 0 on failure, 1 on success.
@@ -1469,6 +1589,13 @@
 	      const char *new_name)
 {
 	struct volume_group *vg = lv->vg;
+	const char *names[2];
+
+	/* rename is not allowed on sub LVs */
+	if ((lv->status & MIRROR_LOG) || (lv->status & MIRROR_IMAGE)) {
+		log_error("Cannot rename hidden LV \"%s\".", lv->name);
+		return 0;
+	}
 
 	if (find_lv_in_vg(vg, new_name)) {
 		log_error("Logical volume \"%s\" already exists in "
@@ -1481,17 +1608,16 @@
 		return 0;
 	}
 
-	if ((lv->status & MIRRORED) ||
-	    (lv->status & MIRROR_LOG) ||
-	    (lv->status & MIRROR_IMAGE)) {
-		log_error("Mirrored LV, \"%s\" cannot be renamed: %s",
-			  lv->name, strerror(ENOSYS));
-		return 0;
-	}
-
 	if (!archive(vg))
 		return_0;
 
+	/* rename sub LVs */
+	names[0] = lv->name;
+	names[1] = new_name;
+	if (!_for_each_sub_lv(cmd, lv, _rename_cb, (void *) names))
+		return 0;
+
+	/* rename main LV */
 	if (!(lv->name = dm_pool_strdup(cmd->mem, new_name))) {
 		log_error("Failed to allocate space for new name");
 		return 0;


