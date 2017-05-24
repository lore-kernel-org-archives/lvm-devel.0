From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 24 May 2017 08:02:36 -0400
Subject: master - Proper dm_snprintf return checks
Message-ID: <201705241202.v4OC2aEk030293@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65b10281f8b10c51730ab74e2d384d5d03d32f96
Commit:        65b10281f8b10c51730ab74e2d384d5d03d32f96
Parent:        3da5cdc5dc5cca04dae105c5a33c87d1c99a5b6c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed May 24 14:00:44 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed May 24 14:00:44 2017 +0200

Proper dm_snprintf return checks

---
 lib/metadata/raid_manip.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e0e988c..8a70600 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1017,8 +1017,8 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
-			(alt_base_name) ? : lv->name, type_suffix)) {
+	if (dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
+			(alt_base_name) ? : lv->name, type_suffix) < 0) {
 		log_error("Component name for raid %s is too long.", display_lvname(lv));
 		return 0;
 	}
@@ -4483,7 +4483,7 @@ static const char *_get_segtype_alias_str(const struct logical_volume *lv, const
 		char *buf = dm_pool_alloc(lv->vg->cmd->mem, sz);
 
 		if (buf)
-			alias = dm_snprintf(buf, sz, "%s%s)", msg, alias) ? buf : "";
+			alias = (dm_snprintf(buf, sz, "%s%s)", msg, alias) < 0) ? "" : buf;
 	}
 
 	return alias;
@@ -4769,7 +4769,7 @@ static int _rename_area_lvs(struct logical_volume *lv, const char *suffix)
 	/* Create _generate_raid_name() suffixes w/ or w/o passed in @suffix */
 	for (s = 0; s < SLV_COUNT; s++)
 		if (!(sfx[s] = dm_pool_alloc(lv->vg->cmd->mem, sz)) ||
-		    !dm_snprintf(sfx[s], sz, suffix ? "%s%s" : "%s", s ? "rmeta" : "rimage", suffix))
+		    dm_snprintf(sfx[s], sz, suffix ? "%s%s" : "%s", s ? "rmeta" : "rimage", suffix) < 0)
 			return_0;
 
 	/* Change names (temporarily) to be able to shift numerical name suffixes */
@@ -4964,8 +4964,8 @@ static int _takeover_downconvert_wrapper(TAKEOVER_FN_ARGS)
 	}
 
 	if (seg->area_count > 2) {
-		if (!dm_snprintf(res_str, sizeof(res_str), " losing %s resilience",
-				segtype_is_striped(new_segtype) ? "all" : "some"))
+		if (dm_snprintf(res_str, sizeof(res_str), " losing %s resilience",
+				segtype_is_striped(new_segtype) ? "all" : "some") < 0)
 			return_0;
 	} else
 		*res_str = '\0';
@@ -6080,7 +6080,7 @@ static int _conversion_options_allowed(const struct lv_segment *seg_from,
 		if (!(fmt = dm_pool_alloc(seg_from->lv->vg->cmd->mem, sz)))
 			return_0;
 
-		if (!dm_snprintf(fmt, sz, "%s%s%s", basic_fmt, (seg_from->segtype == *segtype_to) ? "" : type_fmt, question_fmt)) {
+		if (dm_snprintf(fmt, sz, "%s%s%s", basic_fmt, (seg_from->segtype == *segtype_to) ? "" : type_fmt, question_fmt) < 0) {
 			log_error(INTERNAL_ERROR "dm_snprintf failed.");
 			return_0;
 		}


