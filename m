From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Jul 2011 15:51:52 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20110725155152.1143.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-07-25 15:51:51

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	lvmetad: Check integrity of multiple metadata copies, i.e. ensure that seqno
	equality implies metadata equality. Signal error in response to any update
	requests that try to overwrite metadata without providing a higher seqno.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/25 15:33:04	1.20
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/07/25 15:51:51	1.21
@@ -96,6 +96,54 @@
 }
 
 /*
+ * TODO: Accept different flag permutations? Or else, ensure fixed ordering of
+ * flags in set_flag below (following the same order as we have in
+ * lib/format_text/flags.c).
+ */
+static int compare_value(struct config_value *a, struct config_value *b)
+{
+	if (a->type > b->type)
+		return 1;
+	if (a->type < b->type)
+		return -1;
+
+	switch (a->type) {
+	case CFG_STRING: return strcmp(a->v.str, b->v.str);
+	case CFG_FLOAT: return a->v.r == b->v.r;
+	case CFG_INT: return a->v.i == b->v.i;
+	case CFG_EMPTY_ARRAY: return 0;
+	}
+
+	if (a->next && b->next)
+		return compare_value(a->next, b->next);
+}
+
+static int compare_config(struct config_node *a, struct config_node *b)
+{
+	int result = 0;
+	if (a->v && b->v)
+		result = compare_value(a->v, b->v);
+	if (a->v && !b->v)
+		result = 1;
+	if (!a->v && b->v)
+		result = -1;
+	if (a->child && b->child)
+		result = compare_config(a->child, b->child);
+
+	if (result)
+		return result;
+
+	if (a->sib && b->sib)
+		result = compare_config(a->sib, b->sib);
+	if (a->sib && !b->sib)
+		result = 1;
+	if (!a->sib && b->sib)
+		result = -1;
+
+	return result;
+}
+
+/*
  * TODO: This set_flag function is pretty generic and might make sense in a
  * library here or there.
  */
@@ -212,8 +260,10 @@
 		goto out;
 
 	if (seq == haveseq) {
-		// TODO: compare old->root with metadata to ensure equality
 		retval = 1;
+		// TODO: disregard the MISSING_PV flag status in this comparison
+		if (compare_config(metadata, old->root))
+			retval = 0;
 		goto out;
 	}
 


