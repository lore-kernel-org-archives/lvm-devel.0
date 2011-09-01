From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Sep 2011 17:58:27 -0000
Subject: LVM2/libdm libdm-string.c
Message-ID: <20110901175827.15982.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-01 17:58:27

Modified files:
	libdm          : libdm-string.c 

Log message:
	Add comments & remove always-included header.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/libdm/libdm-string.c	2011/08/30 14:55:16	1.15
+++ LVM2/libdm/libdm-string.c	2011/09/01 17:58:27	1.16
@@ -13,7 +13,6 @@
  */
 
 #include "dmlib.h"
-#include "libdevmapper.h"
 
 #include <ctype.h>
 
@@ -179,6 +178,12 @@
 			(*count)++;
 }
 
+/*
+ * Count occurrences of 'c' in 'str' of length 'size'.
+ *
+ * Returns:
+ *   Number of occurrences of 'c'
+ */
 unsigned dm_count_chars(const char *str, size_t len, const int c)
 {
 	size_t i;
@@ -191,6 +196,9 @@
 	return count;
 }
 
+/*
+ * Length of string after escaping double quotes and backslashes.
+ */
 size_t dm_escaped_len(const char *str)
 {
 	size_t len = 1;
@@ -289,6 +297,9 @@
 	_quote_characters(out, src, '-', '-', 0);
 }
 
+/*
+ * <vg>-<lv>-<layer> or if !layer just <vg>-<lv>.
+ */
 char *dm_build_dm_name(struct dm_pool *mem, const char *vgname,
 		       const char *lvname, const char *layer)
 {
@@ -328,7 +339,7 @@
 	return r;
 }
 
-char *dm_build_dm_uuid(struct dm_pool *mem, const char *prefix, const char *lvid, const char *layer)
+char *dm_build_dm_uuid(struct dm_pool *mem, const char *uuid_prefix, const char *lvid, const char *layer)
 {
 	char *dmuuid;
 	size_t len;
@@ -336,7 +347,7 @@
 	if (!layer)
 		layer = "";
 
-	len = strlen(prefix) + strlen(lvid) + strlen(layer) + 1;
+	len = strlen(uuid_prefix) + strlen(lvid) + strlen(layer) + 1;
 
 	if (!(dmuuid = dm_pool_alloc(mem, len))) {
 		log_error("build_dm_name: Allocation failed for %" PRIsize_t
@@ -344,7 +355,7 @@
 		return NULL;
 	}
 
-	sprintf(dmuuid, "%s%s%s%s", prefix, lvid, (*layer) ? "-" : "", layer);
+	sprintf(dmuuid, "%s%s%s%s", uuid_prefix, lvid, (*layer) ? "-" : "", layer);
 
 	return dmuuid;
 }
@@ -362,11 +373,20 @@
 	return out;
 }
 
+/*
+ * Undo quoting in situ.
+ */
 void dm_unescape_double_quotes(char *src)
 {
 	_unquote_one_character(src, '\"', '\\');
 }
 
+/*
+ * Unescape colons and "at" signs in situ and save the substrings
+ * starting at the position of the first unescaped colon and the
+ * first unescaped "at" sign. This is normally used to unescape
+ * device names used as PVs.
+ */
 void dm_unescape_colons_and_at_signs(char *src,
 				     char **substr_first_unquoted_colon,
 				     char **substr_first_unquoted_at_sign)


