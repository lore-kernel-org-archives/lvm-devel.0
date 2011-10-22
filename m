From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Oct 2011 16:42:12 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20111022164212.7590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-22 16:42:11

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata.h 

Log message:
	Make move_lv_segment non-static
	
	This function could be useful for other _manip source files.
	
	Use dm_list manipulation function for provided functionality,
	which make the code more readable and avoid touching list
	internal details here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2166&r2=1.2167
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.300&r2=1.301
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.259&r2=1.260

--- LVM2/WHATS_NEW	2011/10/21 15:49:45	1.2166
+++ LVM2/WHATS_NEW	2011/10/22 16:42:10	1.2167
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Make move_lv_segment non-static function and use dm_list function.
   Pass exclusive LV locks to all nodes in the cluster.
   Improve lvcreate man documentation of the chunksize option.
   Improve man page style for lvcreate.
--- LVM2/lib/metadata/lv_manip.c	2011/10/21 11:38:35	1.300
+++ LVM2/lib/metadata/lv_manip.c	2011/10/22 16:42:11	1.301
@@ -3446,23 +3446,20 @@
 	return 1;
 }
 
-static int _move_lv_segments(struct logical_volume *lv_to,
-			     struct logical_volume *lv_from,
-			     uint64_t set_status, uint64_t reset_status)
+int move_lv_segments(struct logical_volume *lv_to,
+		     struct logical_volume *lv_from,
+		     uint64_t set_status, uint64_t reset_status)
 {
 	struct lv_segment *seg;
 
-	dm_list_iterate_items(seg, &lv_to->segments) {
+	dm_list_iterate_items(seg, &lv_to->segments)
 		if (seg->origin) {
-			log_error("Can't move snapshot segment");
+			log_error("Can't move snapshot segment.");
 			return 0;
 		}
-	}
 
-	if (!dm_list_empty(&lv_from->segments))
-		lv_to->segments = lv_from->segments;
-	lv_to->segments.n->p = &lv_to->segments;
-	lv_to->segments.p->n = &lv_to->segments;
+	dm_list_init(&lv_to->segments);
+	dm_list_splice(&lv_to->segments, &lv_from->segments);
 
 	dm_list_iterate_items(seg, &lv_to->segments) {
 		seg->lv = lv_to;
@@ -3470,8 +3467,6 @@
 		seg->status |= set_status;
 	}
 
-	dm_list_init(&lv_from->segments);
-
 	lv_to->le_count = lv_from->le_count;
 	lv_to->size = lv_from->size;
 
@@ -3512,7 +3507,7 @@
 	if (!lv_empty(parent))
 		return_0;
 
-	if (!_move_lv_segments(parent, layer_lv, 0, 0))
+	if (!move_lv_segments(parent, layer_lv, 0, 0))
 		return_0;
 
 	/* Replace the empty layer with error segment */
@@ -3602,7 +3597,7 @@
 	log_very_verbose("Inserting layer %s for %s",
 			 layer_lv->name, lv_where->name);
 
-	if (!_move_lv_segments(layer_lv, lv_where, 0, 0))
+	if (!move_lv_segments(layer_lv, lv_where, 0, 0))
 		return_NULL;
 
 	if (!(segtype = get_segtype_from_string(cmd, "striped")))
--- LVM2/lib/metadata/metadata.h	2011/10/19 16:39:09	1.259
+++ LVM2/lib/metadata/metadata.h	2011/10/22 16:42:11	1.260
@@ -420,6 +420,9 @@
                     int (*fn)(struct cmd_context *cmd,
                               struct logical_volume *lv, void *data),
                     void *data);
+int move_lv_segments(struct logical_volume *lv_to,
+		     struct logical_volume *lv_from,
+		     uint64_t set_status, uint64_t reset_status);
 
 /*
  * Calculate readahead from underlying PV devices


