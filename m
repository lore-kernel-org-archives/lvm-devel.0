From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Dec 2007 02:13:01 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20071222021301.25123.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-22 02:13:00

Modified files:
	lib/metadata   : metadata-exported.h mirror.c 
	lib/report     : report.c 
	man            : lvs.8 
	tools          : lvconvert.c lvcreate.c toollib.c 

Log message:
	a few more changes/fixes to recent code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/lib/metadata/metadata-exported.h	2007/12/20 22:37:42	1.28
+++ LVM2/lib/metadata/metadata-exported.h	2007/12/22 02:12:59	1.29
@@ -41,6 +41,9 @@
 #define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 #define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 
+/* Layer suffix */
+#define MIRROR_SYNC_LAYER "_mimagetmp"
+
 /* Various flags */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */
 
--- LVM2/lib/metadata/mirror.c	2007/12/20 23:12:27	1.49
+++ LVM2/lib/metadata/mirror.c	2007/12/22 02:12:59	1.50
@@ -1030,7 +1030,8 @@
 static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
 						 struct alloc_handle *ah,
 						 alloc_policy_t alloc,
-						 const char *lv_name)
+						 const char *lv_name,
+						 const char *suffix)
 {
 	struct logical_volume *log_lv;
 	char *log_name;
@@ -1042,7 +1043,7 @@
 		return NULL;
 	}
 
-	if (dm_snprintf(log_name, len, "%s_mlog", lv->name) < 0) {
+	if (dm_snprintf(log_name, len, "%s%s", lv->name, suffix) < 0) {
 		log_error("log_name allocation failed.");
 		return NULL;
 	}
@@ -1075,7 +1076,9 @@
 		return NULL;
 	}
 
-	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv->name))) {
+	if (!(log_lv = _create_mirror_log(lv, ah, alloc, lv->name,
+					  strstr(lv->name, MIRROR_SYNC_LAYER)
+						? "_mlogtmp_%d" : "_mlog"))) {
 		log_error("Failed to create mirror log.");
 		return NULL;
 	}
--- LVM2/lib/report/report.c	2007/12/20 16:49:37	1.69
+++ LVM2/lib/report/report.c	2007/12/22 02:12:59	1.70
@@ -272,6 +272,24 @@
 	return dm_report_field_uint64(rh, field, &_minusone);
 }
 
+static int _lv_mimage_in_sync(struct logical_volume *lv)
+{
+	float percent;
+	struct lv_segment *seg = first_seg(lv);
+
+	if (!(lv->status & MIRROR_IMAGE) || !seg->mirror_seg)
+		return_0;
+
+	if (!lv_mirror_percent(lv->vg->cmd, seg->mirror_seg->lv, 0,
+			       &percent, NULL))
+		return_0;
+
+	if (percent >= 100.0)
+		return 1;
+
+	return 0;
+}
+
 static int _lvstatus_disp(struct dm_report *rh __attribute((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute((unused)))
@@ -294,7 +312,10 @@
 		else
 			repstr[0] = 'm';
 	}else if (lv->status & MIRROR_IMAGE)
-		repstr[0] = 'i';
+		if (_lv_mimage_in_sync(lv))
+			repstr[0] = 'i';
+		else
+			repstr[0] = 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
 	else if (lv->status & VIRTUAL)
--- LVM2/man/lvs.8	2007/03/27 13:35:33	1.6
+++ LVM2/man/lvs.8	2007/12/22 02:12:59	1.7
@@ -47,7 +47,7 @@
 .RS
 .IP 1 3
 Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin, (p)vmove, (s)napshot, 
-invalid (S)napshot, (v)irtual
+invalid (S)napshot, (v)irtual, mirror (i)mage, mirror (I)mage out-of-sync
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only
 .IP 3 3
--- LVM2/tools/lvconvert.c	2007/12/21 01:08:18	1.50
+++ LVM2/tools/lvconvert.c	2007/12/22 02:13:00	1.51
@@ -227,6 +227,50 @@
 	return 1;
 }
 
+static int _insert_lvconvert_layer(struct cmd_context *cmd,
+				   struct logical_volume *lv)
+{
+	char *format, *layer_name;
+	size_t len;
+	int i;
+
+	/*
+ 	 * We would like to give the same number for this layer
+ 	 * and the newly added mimage.
+ 	 * However, LV name of newly added mimage is determined *after*
+	 * the LV name of this layer is determined.
+	 *
+	 * So, use generate_lv_name() to generate mimage name first
+	 * and take the number from it.
+	 */
+
+	len = strlen(lv->name) + 32;
+	if (!(format = alloca(len)) ||
+	    !(layer_name = alloca(len)) ||
+	    dm_snprintf(format, len, "%s_mimage_%%d", lv->name) < 0) {
+		log_error("lvconvert: layer name allocation failed.");
+		return 0;
+	}
+
+	if (!generate_lv_name(lv->vg, format, layer_name, len) ||
+	    sscanf(layer_name, format, &i) != 1) {
+		log_error("lvconvert: layer name generation failed.");
+		return 0;
+	}
+
+	if (dm_snprintf(layer_name, len, MIRROR_SYNC_LAYER "_%d", i) < 0) {
+		log_error("layer name allocation failed.");
+		return 0;
+	}
+
+	if (!insert_layer_for_lv(cmd, lv, 0, layer_name)) {
+		log_error("Failed to insert resync layer");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int lvconvert_mirrors(struct cmd_context * cmd, struct logical_volume * lv,
 			     struct lvconvert_params *lp)
 {
@@ -376,9 +420,14 @@
 			return 1;
 		}
 	} else if (lp->mirrors > existing_mirrors) {
+		if (lv->status & MIRROR_NOTSYNCED) {
+			log_error("Not adding mirror to mirrored LV "
+				  "without initial resync");
+			return 0;
+		}
 		/* FIXME: can't have multiple mlogs. force corelog. */
 		corelog = 1;
-		if (!insert_layer_for_lv(cmd, lv, 0, "_resync%d")) {
+		if (!_insert_lvconvert_layer(cmd, lv)) {
 			log_error("Failed to insert resync layer");
 			return 0;
 		}
--- LVM2/tools/lvcreate.c	2007/12/20 15:42:55	1.164
+++ LVM2/tools/lvcreate.c	2007/12/22 02:13:00	1.165
@@ -525,7 +525,7 @@
 	uint32_t status = 0;
 	uint64_t tmp_size;
 	struct logical_volume *lv, *org = NULL;
-	struct list *pvh, tags;
+	struct list *pvh;
 	const char *tag = NULL;
 	int origin_active = 0;
 	char lv_name_buf[128];
@@ -744,6 +744,16 @@
 		}
 	}
 
+	if (lp->mirrors > 1) {
+		init_mirror_in_sync(lp->nosync);
+
+		if (lp->nosync) {
+			log_warn("WARNING: New mirror won't be synchronised. "
+				  "Don't read what you didn't write!");
+			status |= MIRROR_NOTSYNCED;
+		}
+	}
+
 	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
 				   status, lp->alloc, 0, vg))) {
 		stack;
@@ -774,18 +784,6 @@
 		return_0;
 
 	if (lp->mirrors > 1) {
-		init_mirror_in_sync(lp->nosync);
-
-		if (lp->nosync) {
-			log_warn("WARNING: New mirror won't be synchronised. "
-				  "Don't read what you didn't write!");
-			status |= MIRROR_NOTSYNCED;
-		}
-
-		list_init(&tags);
-		if (tag)
-			str_list_add(cmd->mem, &tags, tag);
-
 		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
 				    adjusted_mirror_region_size(
 						vg->extent_size,
--- LVM2/tools/toollib.c	2007/12/20 22:37:42	1.121
+++ LVM2/tools/toollib.c	2007/12/22 02:13:00	1.122
@@ -1222,12 +1222,6 @@
 		return 0;
 	}
 
-	if (strstr(name, "_resync")) {
-		log_error("Names including \"_resync\" are reserved. "
-			  "Please choose a different LV name.");
-		return 0;
-	}
-
 	return 1;
 }
 


