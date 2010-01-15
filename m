From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 15 Jan 2010 16:35:27 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20100115163527.31179.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-15 16:35:26

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/metadata   : segtype.h 
	lib/snapshot   : snapshot.c 

Log message:
	Improve target type compatibility checking in _percent_run().
	Add 'target_status_compatible' method to 'struct segtype_handler'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1389&r2=1.1390
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW	2010/01/15 16:18:14	1.1389
+++ LVM2/WHATS_NEW	2010/01/15 16:35:26	1.1390
@@ -1,5 +1,7 @@
 Version 2.02.59 - 
 ===================================
+  Improve target type compatibility checking in _percent_run().
+  Add 'target_status_compatible' method to 'struct segtype_handler'.
   Fix difference between CTR table built and expected for cluster log.
 
 Version 2.02.58 - 14th January 2010
--- LVM2/lib/activate/dev_manager.c	2010/01/14 14:39:57	1.173
+++ LVM2/lib/activate/dev_manager.c	2010/01/15 16:35:26	1.174
@@ -443,19 +443,19 @@
 			seg = dm_list_item(segh, struct lv_segment);
 		}
 
-                /*
-                 * If target status doesn't have 'params' or 'type' is not in the same
-                 * target base class as 'target_type' (e.g. snapshot*, mirror*) skip it
-                 * - allows the situation when 'type' is "snapshot-merge" and
-                 *   'target_type' is "snapshot"
-                 */
-		/* FIXME Do this properly - relying on target prefixes is incorrect. (E.g. snapshot-origin)*/
-		if (!type || !params || strncmp(type, target_type, strlen(target_type)))
+		if (!type || !params)
 			continue;
 
 		if (!(segtype = get_segtype_from_string(dm->cmd, target_type)))
 			continue;
 
+		if (strcmp(type, target_type)) {
+			/* If kernel's type isn't an exact match is it compatible? */
+			if (!segtype->ops->target_status_compatible ||
+			    !segtype->ops->target_status_compatible(type))
+				continue;
+		}
+
 		if (segtype->ops->target_percent &&
 		    !segtype->ops->target_percent(&dm->target_state,
 						  &percent_range, dm->mem,
--- LVM2/lib/metadata/segtype.h	2009/10/16 17:41:52	1.26
+++ LVM2/lib/metadata/segtype.h	2010/01/15 16:35:26	1.27
@@ -77,6 +77,7 @@
                                 struct lv_segment *seg,
                                 struct dm_tree_node *node, uint64_t len,
                                 uint32_t *pvmove_mirror_count);
+	int (*target_status_compatible) (const char *type);
 	int (*target_percent) (void **target_state,
 			       percent_range_t *percent_range,
 			       struct dm_pool * mem,
--- LVM2/lib/snapshot/snapshot.c	2010/01/14 14:39:58	1.43
+++ LVM2/lib/snapshot/snapshot.c	2010/01/15 16:35:26	1.44
@@ -92,6 +92,11 @@
 	return 1;
 }
 
+static int _snap_target_status_compatible(const char *type)
+{
+	return (strcmp(type, "snapshot-merge") == 0);
+}
+
 #ifdef DEVMAPPER_SUPPORT
 static int _snap_target_percent(void **target_state __attribute((unused)),
 				percent_range_t *percent_range,
@@ -303,6 +308,7 @@
 	.name = _snap_name,
 	.text_import = _snap_text_import,
 	.text_export = _snap_text_export,
+	.target_status_compatible = _snap_target_status_compatible,
 #ifdef DEVMAPPER_SUPPORT
 	.target_percent = _snap_target_percent,
 	.target_present = _snap_target_present,


