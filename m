From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Dec 2007 23:12:28 -0000
Subject: LVM2/lib/metadata lv_manip.c mirror.c
Message-ID: <20071220231228.4260.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-20 23:12:27

Modified files:
	lib/metadata   : lv_manip.c mirror.c 

Log message:
	more fixes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/lib/metadata/lv_manip.c	2007/12/20 22:37:42	1.139
+++ LVM2/lib/metadata/lv_manip.c	2007/12/20 23:12:27	1.140
@@ -1410,6 +1410,8 @@
 		sub_lvs[m - old_area_count]->status &= ~VISIBLE_LV;
 	}
 
+	lv->status |= MIRRORED;
+
 	return 1;
 }
 
@@ -2176,12 +2178,19 @@
 	return 1;
 }
 
-static void _move_lv_segments(struct logical_volume *lv_to,
-			      struct logical_volume *lv_from,
-			      uint32_t set_status, uint32_t reset_status)
+static int _move_lv_segments(struct logical_volume *lv_to,
+			     struct logical_volume *lv_from,
+			     uint32_t set_status, uint32_t reset_status)
 {
 	struct lv_segment *seg;
 
+	list_iterate_items(seg, &lv_to->segments) {
+		if (seg->origin) {
+			log_error("Can't move snapshot segment");
+			return 0;
+		}
+	}
+
 	lv_to->segments = lv_from->segments;
 	lv_to->segments.n->p = &lv_to->segments;
 	lv_to->segments.p->n = &lv_to->segments;
@@ -2192,8 +2201,6 @@
 		seg->status |= set_status;
 	}
 
-	/* FIXME: how to handle snapshot segments? */
-
 	list_init(&lv_from->segments);
 
 	lv_to->le_count = lv_from->le_count;
@@ -2201,6 +2208,8 @@
 
 	lv_from->le_count = 0;
 	lv_from->size = 0;
+
+	return 1;
 }
 
 /*
@@ -2253,7 +2262,8 @@
 	    parent->le_count != layer_lv->le_count)
 		return_0;
 
-	_move_lv_segments(parent, layer_lv, 0, 0);
+	if (!_move_lv_segments(parent, layer_lv, 0, 0))
+		return_0;
 
 	/* Replace the empty layer with error segment */
 	segtype = get_segtype_from_string(lv->vg->cmd, "error");
@@ -2307,7 +2317,8 @@
 	log_very_verbose("Inserting layer %s for %s",
 			 layer_lv->name, lv_where->name);
 
-	_move_lv_segments(layer_lv, lv_where, 0, 0);
+	if (!_move_lv_segments(layer_lv, lv_where, 0, 0))
+		return_NULL;
 
 	/* allocate a new linear segment */
 	if (!(mapseg = alloc_lv_segment(cmd->mem, segtype,
--- LVM2/lib/metadata/mirror.c	2007/12/20 22:37:42	1.48
+++ LVM2/lib/metadata/mirror.c	2007/12/20 23:12:27	1.49
@@ -1238,8 +1238,6 @@
 	if (log_count)
 		_add_mirror_log(lv, log_lv);
 
-	lv->status |= MIRRORED;
-
 	alloc_destroy(ah);
 	return 1;
 


