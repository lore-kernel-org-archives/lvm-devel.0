From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Jan 2017 11:45:19 +0000 (UTC)
Subject: master - mirror: relax internal error for a while
Message-ID: <20170106114519.86DB160787@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a93cde75ef4a4b260d937c5924267d0eab31df3
Commit:        8a93cde75ef4a4b260d937c5924267d0eab31df3
Parent:        d90320f4f161658c6a004631c5685b40202af2cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 6 12:41:38 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 6 12:45:07 2017 +0100

mirror: relax internal error for a while

With recent commit d6a74025df1afb3d76bec435bc6a40d649217b42 using
INTERNAL_ERROR while cheking layer LV - it's been noticed mirror
logic currently doesn't do a correct thing during upconversion and
does a full-try instead of checking only allocator capabilities.
This leads to invalid usage of layer.

To keep existing code running before providing a fix, relax
INTERNAL_ERROR just an error and keep the 'code' running.

Once mirror code is fixed, these all check should be switched
to internal errors.
---
 lib/metadata/lv_manip.c |   42 +++++++++++++++++++++++++++++++++++-------
 1 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ad400b2..3feec20 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6533,13 +6533,41 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	 * Before removal, the layer should be cleaned up,
 	 * i.e. additional segments and areas should have been removed.
 	 */
-	if (dm_list_size(&parent_lv->segments) != 1 ||
-	    parent_seg->area_count != 1 ||
-	    seg_type(parent_seg, 0) != AREA_LV ||
-	    layer_lv != seg_lv(parent_seg, 0) ||
-	    parent_lv->le_count != layer_lv->le_count) {
-		log_error(INTERNAL_ERROR "Inconsistent sizes of layer %s.",
-			  display_lvname(lv));
+	/* FIXME:
+	 *    These are all INTERNAL_ERROR, but ATM there is
+	 *    some internal API problem and this code is wrongle
+	 *    executed with certain mirror manipulations.
+	 *    So we need to fix mirror code first, then switch...
+	 */
+	if (dm_list_size(&parent_lv->segments) != 1) {
+		log_error("Invalid %d segments in %s, expected only 1.",
+			  dm_list_size(&parent_lv->segments),
+			  display_lvname(parent_lv));
+		return 0;
+	}
+
+	if (parent_seg->area_count != 1) {
+		log_error("Invalid %d area count(s) in %s, expected only 1.",
+			  parent_seg->area_count, display_lvname(parent_lv));
+		return 0;
+	}
+
+	if (seg_type(parent_seg, 0) != AREA_LV) {
+		log_error("Invalid seg_type %d in %s, expected LV.",
+			  seg_type(parent_seg, 0), display_lvname(parent_lv));
+		return 0;
+	}
+
+	if (layer_lv != seg_lv(parent_seg, 0)) {
+		log_error("Layer doesn't match segment in %s.",
+			  display_lvname(parent_lv));
+		return 0;
+	}
+
+	if (parent_lv->le_count != layer_lv->le_count) {
+		log_error("Inconsistent extent count (%u != %u) of layer %s.",
+			  parent_lv->le_count, layer_lv->le_count,
+			  display_lvname(parent_lv));
 		return 0;
 	}
 


