From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Jul 2008 11:30:58 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/export.c lib/ ...
Message-ID: <20080710113058.4303.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-07-10 11:30:58

Modified files:
	.              : WHATS_NEW 
	lib/format_text: export.c flags.c import-export.h import_vsn1.c 

Log message:
	Add "flags" metadata field (akin to "status") for backward-compatible flags.
	
	The "status" field is treated as it ever has been, unknown flags there are
	treated as fatal metadata errors. However, in the "flags" field, any unknown
	flags will be ignored and silently dropped. This improves
	backward-compatibility possibilities. (Any versions without support for this
	new "flag" field will drop the field altogether, which is same as ignoring all
	the flags there.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.927&r2=1.928
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import-export.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/WHATS_NEW	2008/07/10 09:50:23	1.927
+++ LVM2/WHATS_NEW	2008/07/10 11:30:57	1.928
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Add "flags" metadata field (akin to "status") for backward-compatible flags.
   Fix dmeventd monitoring libraries to link against liblvm2cmd again. (2.02.39)
 
 Version 2.02.39 - 27th June 2008
--- LVM2/lib/format_text/export.c	2008/04/01 22:40:12	1.63
+++ LVM2/lib/format_text/export.c	2008/07/10 11:30:57	1.64
@@ -321,6 +321,20 @@
 	return 1;
 }
 
+static int _print_flag_config(struct formatter *f, int status, int type)
+{
+	char buffer[4096];
+	if (!print_flags(status, type | STATUS_FLAG, buffer, sizeof(buffer)))
+		return_0;
+	outf(f, "status = %s", buffer);
+
+	if (!print_flags(status, type, buffer, sizeof(buffer)))
+		return_0;
+	outf(f, "flags = %s", buffer);
+
+	return 1;
+}
+
 static int _print_vg(struct formatter *f, struct volume_group *vg)
 {
 	char buffer[4096];
@@ -332,9 +346,8 @@
 
 	outf(f, "seqno = %u", vg->seqno);
 
-	if (!print_flags(vg->status, VG_FLAGS, buffer, sizeof(buffer)))
+	if (!_print_flag_config(f, vg->status, VG_FLAGS))
 		return_0;
-	outf(f, "status = %s", buffer);
 
 	if (!list_empty(&vg->tags)) {
 		if (!print_tags(&vg->tags, buffer, sizeof(buffer)))
@@ -408,9 +421,8 @@
 			return_0;
 		outnl(f);
 
-		if (!print_flags(pv->status, PV_FLAGS, buffer, sizeof(buffer)))
+		if (!_print_flag_config(f, pv->status, PV_FLAGS))
 			return_0;
-		outf(f, "status = %s", buffer);
 
 		if (!list_empty(&pv->tags)) {
 			if (!print_tags(&pv->tags, buffer, sizeof(buffer)))
@@ -520,9 +532,8 @@
 
 	outf(f, "id = \"%s\"", buffer);
 
-	if (!print_flags(lv->status, LV_FLAGS, buffer, sizeof(buffer)))
+	if (!_print_flag_config(f, lv->status, LV_FLAGS))
 		return_0;
-	outf(f, "status = %s", buffer);
 
 	if (!list_empty(&lv->tags)) {
 		if (!print_tags(&lv->tags, buffer, sizeof(buffer)))
--- LVM2/lib/format_text/flags.c	2008/01/30 13:59:59	1.33
+++ LVM2/lib/format_text/flags.c	2008/07/10 11:30:57	1.34
@@ -25,48 +25,49 @@
 struct flag {
 	const int mask;
 	const char *description;
+	int kind;
 };
 
 static struct flag _vg_flags[] = {
-	{EXPORTED_VG, "EXPORTED"},
-	{RESIZEABLE_VG, "RESIZEABLE"},
-	{PARTIAL_VG, "PARTIAL"},
-	{PVMOVE, "PVMOVE"},
-	{LVM_READ, "READ"},
-	{LVM_WRITE, "WRITE"},
-	{CLUSTERED, "CLUSTERED"},
-	{SHARED, "SHARED"},
-	{PRECOMMITTED, NULL},
-	{0, NULL}
+	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
+	{RESIZEABLE_VG, "RESIZEABLE", STATUS_FLAG},
+	{PARTIAL_VG, "PARTIAL", STATUS_FLAG},
+	{PVMOVE, "PVMOVE", STATUS_FLAG},
+	{LVM_READ, "READ", STATUS_FLAG},
+	{LVM_WRITE, "WRITE", STATUS_FLAG},
+	{CLUSTERED, "CLUSTERED", STATUS_FLAG},
+	{SHARED, "SHARED", STATUS_FLAG},
+	{PRECOMMITTED, NULL, 0},
+	{0, NULL, 0}
 };
 
 static struct flag _pv_flags[] = {
-	{ALLOCATABLE_PV, "ALLOCATABLE"},
-	{EXPORTED_VG, "EXPORTED"},
-	{0, NULL}
+	{ALLOCATABLE_PV, "ALLOCATABLE", STATUS_FLAG},
+	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
+	{0, NULL, 0}
 };
 
 static struct flag _lv_flags[] = {
-	{LVM_READ, "READ"},
-	{LVM_WRITE, "WRITE"},
-	{FIXED_MINOR, "FIXED_MINOR"},
-	{VISIBLE_LV, "VISIBLE"},
-	{PVMOVE, "PVMOVE"},
-	{LOCKED, "LOCKED"},
-	{MIRROR_NOTSYNCED, "NOTSYNCED"},
-	{MIRROR_IMAGE, NULL},
-	{MIRROR_LOG, NULL},
-	{MIRRORED, NULL},
-	{VIRTUAL, NULL},
-	{SNAPSHOT, NULL},
-	{ACTIVATE_EXCL, NULL},
-	{CONVERTING, NULL},
-	{0, NULL}
+	{LVM_READ, "READ", STATUS_FLAG},
+	{LVM_WRITE, "WRITE", STATUS_FLAG},
+	{FIXED_MINOR, "FIXED_MINOR", STATUS_FLAG},
+	{VISIBLE_LV, "VISIBLE", STATUS_FLAG},
+	{PVMOVE, "PVMOVE", STATUS_FLAG},
+	{LOCKED, "LOCKED", STATUS_FLAG},
+	{MIRROR_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
+	{MIRROR_IMAGE, NULL, 0},
+	{MIRROR_LOG, NULL, 0},
+	{MIRRORED, NULL, 0},
+	{VIRTUAL, NULL, 0},
+	{SNAPSHOT, NULL, 0},
+	{ACTIVATE_EXCL, NULL, 0},
+	{CONVERTING, NULL, 0},
+	{0, NULL, 0}
 };
 
 static struct flag *_get_flags(int type)
 {
-	switch (type) {
+	switch (type & ~STATUS_FLAG) {
 	case VG_FLAGS:
 		return _vg_flags;
 
@@ -101,6 +102,9 @@
 		if (status & flags[f].mask) {
 			status &= ~flags[f].mask;
 
+			if ((type & STATUS_FLAG) != flags[f].kind)
+				continue;
+
 			/* Internal-only flag? */
 			if (!flags[f].description)
 				continue;
@@ -151,7 +155,7 @@
 				break;
 			}
 
-		if (!flags[f].description) {
+		if (!flags[f].description && (type & STATUS_FLAG)) {
 			log_err("Unknown status flag '%s'.", cv->v.str);
 			return 0;
 		}
@@ -160,6 +164,6 @@
 	}
 
       out:
-	*status = s;
+	*status |= s;
 	return 1;
 }
--- LVM2/lib/format_text/import-export.h	2007/08/20 20:55:26	1.20
+++ LVM2/lib/format_text/import-export.h	2008/07/10 11:30:57	1.21
@@ -36,9 +36,11 @@
  * common code for reading and writing them.
  */
 enum {
+	COMPATIBLE_FLAG = 0x0,
 	VG_FLAGS,
 	PV_FLAGS,
-	LV_FLAGS
+	LV_FLAGS,
+	STATUS_FLAG = 0x8,
 };
 
 struct text_vg_version_ops {
--- LVM2/lib/format_text/import_vsn1.c	2008/01/31 12:35:31	1.50
+++ LVM2/lib/format_text/import_vsn1.c	2008/07/10 11:30:57	1.51
@@ -125,6 +125,31 @@
 	return 1;
 }
 
+static int _read_flag_config(struct config_node *n, int *status, int type)
+{
+	struct config_node *cn;
+	*status = 0;
+
+	if (!(cn = find_config_node(n, "status"))) {
+		log_error("Could not find status flags.");
+		return 0;
+	}
+
+	if (!(read_flags(status, type | STATUS_FLAG, cn->v))) {
+		log_error("Could not read status flags.");
+		return 0;
+	}
+
+	if (cn = find_config_node(n, "flags")) {
+		if (!(read_flags(status, type, cn->v))) {
+			log_error("Could not read flags.");
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 		    struct volume_group *vg, struct config_node *pvn,
 		    struct config_node *vgn __attribute((unused)),
@@ -181,12 +206,7 @@
 
 	memcpy(&pv->vgid, &vg->id, sizeof(vg->id));
 
-	if (!(cn = find_config_node(pvn, "status"))) {
-		log_error("Couldn't find status flags for physical volume.");
-		return 0;
-	}
-
-	if (!(read_flags(&pv->status, PV_FLAGS, cn->v))) {
+	if (!_read_flag_config(pvn, &pv->status, PV_FLAGS)) {
 		log_error("Couldn't read status flags for physical volume.");
 		return 0;
 	}
@@ -493,13 +513,9 @@
 		return 0;
 	}
 
-	if (!(cn = find_config_node(lvn, "status"))) {
-		log_error("Couldn't find status flags for logical volume.");
-		return 0;
-	}
-
-	if (!(read_flags(&lv->status, LV_FLAGS, cn->v))) {
-		log_error("Couldn't read status flags for logical volume.");
+	if (!_read_flag_config(lvn, &lv->status, LV_FLAGS)) {
+		log_error("Couldn't read status flags for logical volume %s.",
+			  lv->name);
 		return 0;
 	}
 
@@ -692,14 +708,8 @@
 		goto bad;
 	}
 
-	if (!(cn = find_config_node(vgn, "status"))) {
-		log_error("Couldn't find status flags for volume group %s.",
-			  vg->name);
-		goto bad;
-	}
-
-	if (!(read_flags(&vg->status, VG_FLAGS, cn->v))) {
-		log_error("Couldn't read status flags for volume group %s.",
+	if (!_read_flag_config(vgn, &vg->status, VG_FLAGS)) {
+		log_error("Error reading flags of volume group %s.",
 			  vg->name);
 		goto bad;
 	}
@@ -855,18 +865,12 @@
 		return 0;
 	}
 
-	if (!(cn = find_config_node(vgn, "status"))) {
+	if (!_read_flag_config(vgn, vgstatus, VG_FLAGS)) {
 		log_error("Couldn't find status flags for volume group %s.",
 			  vgname);
 		return 0;
 	}
 
-	if (!(read_flags(vgstatus, VG_FLAGS, cn->v))) {
-		log_error("Couldn't read status flags for volume group %s.",
-			  vgname);
-		return 0;
-	}
-
 	return vgname;
 }
 


