From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Jun 2008 16:52:28 -0000
Subject: LVM2 ./WHATS_NEW lib/Makefile.in lib/commands/ ...
Message-ID: <20080625165228.15946.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-25 16:52:27

Modified files:
	.              : WHATS_NEW 
	lib            : Makefile.in 
	lib/commands   : toolcontext.c 
	lib/metadata   : segtype.h 
	lib/report     : report.c 
	tools          : reporter.c 
Added files:
	lib/freeseg    : freeseg.c 

Log message:
	Fix reporting of LV fields alongside unallocated PV segments.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.916&r2=1.917
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/freeseg/freeseg.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW	2008/06/24 22:48:53	1.916
+++ LVM2/WHATS_NEW	2008/06/25 16:52:26	1.917
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Fix reporting of LV fields alongside unallocated PV segments.
   Add --unquoted and --rows to reporting tools.
   Add and use uninitialized_var() macro to suppress invalid compiler warnings.
   Introduce enum for md minor sb version to suppress compiler warning.
--- LVM2/lib/Makefile.in	2007/09/21 10:16:44	1.84
+++ LVM2/lib/Makefile.in	2008/06/25 16:52:26	1.85
@@ -61,6 +61,7 @@
 	format_text/import_vsn1.c \
 	format_text/tags.c \
 	format_text/text_label.c \
+	freeseg/freeseg.c \
 	label/label.c \
 	locking/file_locking.c \
 	locking/locking.c \
--- LVM2/lib/commands/toolcontext.c	2008/04/08 12:49:20	1.59
+++ LVM2/lib/commands/toolcontext.c	2008/06/25 16:52:26	1.60
@@ -755,6 +755,11 @@
 	segtype->library = NULL;
 	list_add(&cmd->segtypes, &segtype->list);
 
+	if (!(segtype = init_free_segtype(cmd)))
+		return 0;
+	segtype->library = NULL;
+	list_add(&cmd->segtypes, &segtype->list);
+
 #ifdef SNAPSHOT_INTERNAL
 	if (!(segtype = init_snapshot_segtype(cmd)))
 		return 0;
--- LVM2/lib/metadata/segtype.h	2008/04/07 10:23:46	1.19
+++ LVM2/lib/metadata/segtype.h	2008/06/25 16:52:26	1.20
@@ -95,6 +95,7 @@
 struct segment_type *init_striped_segtype(struct cmd_context *cmd);
 struct segment_type *init_zero_segtype(struct cmd_context *cmd);
 struct segment_type *init_error_segtype(struct cmd_context *cmd);
+struct segment_type *init_free_segtype(struct cmd_context *cmd);
 
 #ifdef SNAPSHOT_INTERNAL
 struct segment_type *init_snapshot_segtype(struct cmd_context *cmd);
--- LVM2/lib/report/report.c	2008/06/24 22:48:53	1.86
+++ LVM2/lib/report/report.c	2008/06/25 16:52:27	1.87
@@ -303,6 +303,10 @@
 		return 0;
 	}
 
+	/* Blank if this is a "free space" LV. */
+	if (!*lv->name)
+		goto out;
+
 	if (lv->status & PVMOVE)
 		repstr[0] = 'p';
 	else if (lv->status & CONVERTING)
@@ -332,8 +336,10 @@
 		repstr[1] = '-';
 	else if (lv->status & LVM_WRITE)
 		repstr[1] = 'w';
-	else
+	else if (lv->status & LVM_READ)
 		repstr[1] = 'r';
+	else
+		repstr[1] = '-';
 
 	repstr[2] = _alloc_policy_char(lv->alloc);
 
@@ -375,6 +381,7 @@
 		repstr[5] = '-';
 	}
 
+out:
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
--- LVM2/tools/reporter.c	2008/06/24 22:48:53	1.39
+++ LVM2/tools/reporter.c	2008/06/25 16:52:27	1.40
@@ -61,8 +61,39 @@
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
 
-	if (!report_object(handle, vg, seg ? seg->lv : NULL, pvseg->pv, seg,
-			   pvseg))
+	struct logical_volume _free_logical_volume = {
+		.vg = vg,
+		.name = (char *) "",
+	        .snapshot = NULL,
+		.status = VISIBLE_LV,
+		.major = -1,
+		.minor = -1,
+	};
+
+	struct lv_segment _free_lv_segment = {
+        	.lv = &_free_logical_volume,
+        	.le = 0,
+        	.status = 0,
+        	.stripe_size = 0,
+        	.area_count = 0,
+        	.area_len = 0,
+        	.origin = NULL,
+        	.cow = NULL,
+        	.chunk_size = 0,
+        	.region_size = 0,
+        	.extents_copied = 0,
+        	.log_lv = NULL,
+        	.areas = NULL,
+	};
+
+        _free_lv_segment.segtype = get_segtype_from_string(cmd, "free");
+	_free_lv_segment.len = pvseg->len;
+	list_init(&_free_logical_volume.tags);
+	list_init(&_free_logical_volume.segments);
+	list_init(&_free_logical_volume.segs_using_this_lv);
+
+	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
+			   seg ? : &_free_lv_segment, pvseg))
 		ret = ECMD_FAILED;
 
 	return ret;
/cvs/lvm2/LVM2/lib/freeseg/freeseg.c,v  -->  standard output
revision 1.1
--- LVM2/lib/freeseg/freeseg.c
+++ -	2008-06-25 16:52:28.144842000 +0000
@@ -0,0 +1,60 @@
+/*
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "toolcontext.h"
+#include "segtype.h"
+#include "display.h"
+#include "text_export.h"
+#include "text_import.h"
+#include "config.h"
+#include "str_list.h"
+#include "targets.h"
+#include "lvm-string.h"
+#include "activate.h"
+#include "str_list.h"
+#include "metadata.h"
+
+static const char *_freeseg_name(const struct lv_segment *seg)
+{
+	return seg->segtype->name;
+}
+
+static void _freeseg_destroy(const struct segment_type *segtype)
+{
+	dm_free((void *)segtype);
+}
+
+static struct segtype_handler _freeseg_ops = {
+	.name = _freeseg_name,
+	.destroy = _freeseg_destroy,
+};
+
+struct segment_type *init_free_segtype(struct cmd_context *cmd)
+{
+	struct segment_type *segtype = dm_malloc(sizeof(*segtype));
+
+	if (!segtype)
+		return_NULL;
+
+	segtype->cmd = cmd;
+	segtype->ops = &_freeseg_ops;
+	segtype->name = "free";
+	segtype->private = NULL;
+	segtype->flags = SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
+
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return segtype;
+}


