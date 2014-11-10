From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:17 +0000 (UTC)
Subject: master - lv_manip: remove_layer_from_lv restore lv name
Message-ID: <20141110210617.2562F602E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff30783a4f44c823544133260acb8c5171fbd0a6
Commit:        ff30783a4f44c823544133260acb8c5171fbd0a6
Parent:        979d12eb4a69ad328a8583eaafc4d3d30e4d1771
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 9 19:48:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

lv_manip: remove_layer_from_lv restore lv name

Since we 'layer' for cache origin which and we support dropping
cache layer - we need to restore origin name in case
the origin LV is more complex target  - i.e. raid.

Drop _corig from name

Cleanup and rename parent -> parent_lv.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   33 +++++++++++++++++++++++++--------
 2 files changed, 26 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6084ee7..f70c657 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  When remove_layer_from_lv() removes layer, restore subLV names.
   Cache-pool in use becomes invisible LV.
   Don't prompt for removal of _pmspare in VG without pool metadata LV.
   Deactivation of snapshot origin detects and deactivates left-over snapshots.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1943c07..99ed6d1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5948,9 +5948,12 @@ int move_lv_segments(struct logical_volume *lv_to,
 int remove_layer_from_lv(struct logical_volume *lv,
 			 struct logical_volume *layer_lv)
 {
-	struct logical_volume *parent;
+	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig" };
+	struct logical_volume *parent_lv;
 	struct lv_segment *parent_seg;
 	struct segment_type *segtype;
+	struct lv_names lv_names;
+	int r;
 
 	log_very_verbose("Removing layer %s for %s", layer_lv->name, lv->name);
 
@@ -5959,8 +5962,8 @@ int remove_layer_from_lv(struct logical_volume *lv,
 			  layer_lv->name, lv->name);
 		return 0;
 	}
-	parent = parent_seg->lv;
-	if (parent != lv) {
+	parent_lv = parent_seg->lv;
+	if (parent_lv != lv) {
 		log_error(INTERNAL_ERROR "Wrong layer %s in %s",
 			  layer_lv->name, lv->name);
 		return 0;
@@ -5970,25 +5973,39 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	 * Before removal, the layer should be cleaned up,
 	 * i.e. additional segments and areas should have been removed.
 	 */
-	if (dm_list_size(&parent->segments) != 1 ||
+	if (dm_list_size(&parent_lv->segments) != 1 ||
 	    parent_seg->area_count != 1 ||
 	    seg_type(parent_seg, 0) != AREA_LV ||
 	    layer_lv != seg_lv(parent_seg, 0) ||
-	    parent->le_count != layer_lv->le_count)
+	    parent_lv->le_count != layer_lv->le_count)
 		return_0;
 
-	if (!lv_empty(parent))
+	if (!lv_empty(parent_lv))
 		return_0;
 
-	if (!move_lv_segments(parent, layer_lv, 0, 0))
+	if (!move_lv_segments(parent_lv, layer_lv, 0, 0))
 		return_0;
 
 	/* Replace the empty layer with error segment */
 	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "error")))
 		return_0;
-	if (!lv_add_virtual_segment(layer_lv, 0, parent->le_count, segtype))
+	if (!lv_add_virtual_segment(layer_lv, 0, parent_lv->le_count, segtype))
 		return_0;
 
+	/*
+	 * recuresively rename sub LVs
+	 *   currently supported only for thin data layer
+	 *   FIXME: without strcmp it breaks mirrors....
+	 */
+	for (r = 0; r < DM_ARRAY_SIZE(_suffixes); ++r)
+		if (strstr(layer_lv->name, _suffixes[r]) == 0) {
+			lv_names.old = layer_lv->name;
+			lv_names.new = parent_lv->name;
+			if (!for_each_sub_lv(parent_lv, _rename_cb, (void *) &lv_names))
+				return_0;
+			break;
+		}
+
 	return 1;
 }
 


