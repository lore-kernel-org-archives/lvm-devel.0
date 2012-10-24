From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 24 Oct 2012 02:20:56 +0000 (UTC)
Subject: master - mirror/raid: Move 'copy_percent' to common code (mirror.c -> lv_manip.c)
Message-ID: <20121024022056.F34681F3D@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6db461e3b0d3fbc394fe2ed2a7d6a3c070453874
Commit:        6db461e3b0d3fbc394fe2ed2a7d6a3c070453874
Parent:        8073ce16900def5a200fce44cb69862bfc50d4ce
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Oct 23 20:33:54 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Oct 23 20:33:54 2012 -0500

mirror/raid:  Move 'copy_percent' to common code (mirror.c -> lv_manip.c)

The 'copy_percent' function takes the 'extents_copied' field from each
segment in an LV to create the numerator for the ratio that is to
become the copy_percent.  (Otherwise known as the 'sync' percent for
non-pvmove uses, like mirror LVs and RAID LVs.)  This function safely
works on RAID - not just mirrors - so it is better to have it in
lv_manip.c rather than mirror.c.

There's a lot of different functions that do a lot of different things
in lv_manip.c, so I placed the function near a function in lv_manip.c
that it was close to in metadata-exported.h.  Different placement in the
file or a different name for the function may be useful.
---
 lib/metadata/lv_manip.c          |   18 ++++++++++++++++++
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/mirror.c            |   17 -----------------
 3 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 32a207d..9f87854 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -199,6 +199,24 @@ uint32_t find_free_lvnum(struct logical_volume *lv)
 	return i;
 }
 
+percent_t copy_percent(const struct logical_volume *lv)
+{
+	uint32_t numerator = 0u, denominator = 0u;
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		denominator += seg->area_len;
+
+		if ((seg_is_raid(seg) || seg_is_mirrored(seg))
+		    && (seg->area_count > 1))
+			numerator += seg->extents_copied;
+		else
+			numerator += seg->area_len;
+	}
+
+	return denominator ? make_percent( numerator, denominator ) : 100.0;
+}
+
 /*
  * All lv_segments get created here.
  */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d149f95..00be606 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -831,11 +831,11 @@ struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
 struct logical_volume *find_pvmove_lv_in_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
-percent_t copy_percent(const struct logical_volume *lv_mirr);
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv);
 
 uint32_t find_free_lvnum(struct logical_volume *lv);
+percent_t copy_percent(const struct logical_volume *lv_mirr);
 char *generate_lv_name(struct volume_group *vg, const char *format,
 		       char *buffer, size_t len);
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 084c93a..4fee763 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1623,23 +1623,6 @@ struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 	return lvs;
 }
 
-percent_t copy_percent(const struct logical_volume *lv_mirr)
-{
-	uint32_t numerator = 0u, denominator = 0u;
-	struct lv_segment *seg;
-
-	dm_list_iterate_items(seg, &lv_mirr->segments) {
-		denominator += seg->area_len;
-
-		if (seg_is_mirrored(seg) && seg->area_count > 1)
-			numerator += seg->extents_copied;
-		else
-			numerator += seg->area_len;
-	}
-
-	return denominator ? make_percent( numerator, denominator ) : 100.0;
-}
-
 /*
  * Fixup mirror pointers after single-pass segment import
  */


