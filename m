From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:58 +0000 (UTC)
Subject: master - thin: vgsplit and vgmerge spare support
Message-ID: <20130718162658.8C18B61019@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef3a1a0f8a7dc9656fa9269f08b36d1a9cb96d91
Commit:        ef3a1a0f8a7dc9656fa9269f08b36d1a9cb96d91
Parent:        aab53f46eedda64ca8cd73b25eaac9aea7894957
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 9 12:01:25 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:44 2013 +0200

thin: vgsplit and vgmerge spare support

When spliting a VG with spare, update to which VG it will belong.

When merging and both VGs have spare, unmark the smaller one first.
---
 tools/vgmerge.c |   30 ++++++++++++++++++++++++++++++
 tools/vgsplit.c |    6 ++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index fb3321d..3782779 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -28,6 +28,29 @@ static struct volume_group *_vgmerge_vg_read(struct cmd_context *cmd,
 	return vg;
 }
 
+/* Select bigger pool metadata spare volume */
+static int _vgmerge_select_pool_metadata_spare(struct cmd_context *cmd,
+					       struct volume_group *vg_to,
+					       struct volume_group *vg_from)
+{
+	struct volume_group *svg;
+
+	if (!vg_to->pool_metadata_spare_lv ||
+	    !vg_from->pool_metadata_spare_lv)
+		return 1; /* no problem */
+
+	/* Drop smaller pool metadata spare */
+	svg = (vg_to->pool_metadata_spare_lv->le_count <
+	       vg_from->pool_metadata_spare_lv->le_count) ? vg_to : vg_from;
+	vg_remove_pool_metadata_spare(svg);
+
+	/* Re-test lv name compatibility */
+	if (!vgs_are_compatible(cmd, vg_from, vg_to))
+		return_0;
+
+	return 1;
+}
+
 static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 			   const char *vg_name_from)
 {
@@ -73,6 +96,9 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	if (!drop_cached_metadata(vg_from))
 		stack;
 
+	if (!_vgmerge_select_pool_metadata_spare(cmd, vg_to, vg_from))
+		goto_bad;
+
 	/* Merge volume groups */
 	dm_list_iterate_items_safe(pvl, tpvl, &vg_from->pvs) {
 		del_pvl_from_vgs(vg_from, pvl);
@@ -127,6 +153,10 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 		dm_list_move(&vg_to->fid->metadata_areas_ignored, mdah);
 	}
 
+	if (!vg_to->pool_metadata_spare_lv)
+		vg_to->pool_metadata_spare_lv =
+			vg_from->pool_metadata_spare_lv;
+
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;
 
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index ed31a57..dfcb120 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -41,6 +41,12 @@ static int _move_one_lv(struct volume_group *vg_from,
 		return 0;
 	}
 
+	/* Moved pool metadata spare LV */
+	if (vg_from->pool_metadata_spare_lv == lv) {
+		vg_to->pool_metadata_spare_lv = lv;
+		vg_from->pool_metadata_spare_lv = NULL;
+	}
+
 	return 1;
 }
 


