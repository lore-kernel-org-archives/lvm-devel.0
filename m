From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Dec 2014 16:32:09 +0000 (UTC)
Subject: master - cache: disallow cache lvs and cache pools in cluster vg
Message-ID: <20141216163209.E8B8660C44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40e1d5b269fa76b839e3e8e2e7c9beb2bbbfed5e
Commit:        40e1d5b269fa76b839e3e8e2e7c9beb2bbbfed5e
Parent:        2e905d454058ef17bbb2b9758c59a5505d1c95be
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 31 15:50:09 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 16 10:30:27 2014 -0600

cache: disallow cache lvs and cache pools in cluster vg

Disable this combination until problems are resolved.
---
 lib/metadata/segtype.c |    8 ++++++++
 lib/metadata/segtype.h |    2 ++
 tools/lvconvert.c      |   16 +++++++++++++++-
 tools/lvcreate.c       |    6 ++++++
 tools/vgchange.c       |   12 ++++++++++++
 5 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/segtype.c b/lib/metadata/segtype.c
index 02dff4c..c28c894 100644
--- a/lib/metadata/segtype.c
+++ b/lib/metadata/segtype.c
@@ -34,3 +34,11 @@ struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 
 	return segtype;
 }
+
+int segtype_allowed_in_cluster_vg(const struct segment_type *segtype)
+{
+	if (segtype_is_cache(segtype) || segtype_is_cache_pool(segtype))
+		return 0;
+
+	return 1;
+}
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index ecb598d..3c387e2 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -138,6 +138,8 @@ struct segtype_handler {
 struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
 					     const char *str);
 
+int segtype_allowed_in_cluster_vg(const struct segment_type *segtype);
+
 struct segtype_library;
 int lvm_register_segtype(struct segtype_library *seglib,
 			 struct segment_type *segtype);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c7acd5d..6f4a546 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3345,13 +3345,27 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 				return_ECMD_FAILED;
 		}
 	}
+
 	if (lp->merge) {
 		if ((lv_is_thin_volume(lv) && !_lvconvert_merge_thin_snapshot(cmd, lv, lp)) ||
 		    (!lv_is_thin_volume(lv) && !_lvconvert_merge_old_snapshot(cmd, lv, lp))) {
 			log_print_unless_silent("Unable to merge LV \"%s\" into its origin.", lv->name);
 			return ECMD_FAILED;
 		}
-	} else if (lp->snapshot) {
+		return ECMD_PROCESSED;
+	}
+
+	/*
+	 * Converting to a new type.
+	 */
+
+	if (vg_is_clustered(lv->vg) && !segtype_allowed_in_cluster_vg(lp->segtype)) {
+		log_error("LV segtype %s is not allowed in a cluster VG.",
+			  lp->segtype->name);
+		return ECMD_FAILED;
+	}
+
+	if (lp->snapshot) {
 		if (!_lvconvert_snapshot(cmd, lv, lp))
 			return_ECMD_FAILED;
 	} else if (segtype_is_pool(lp->segtype) || lp->thin || lp->cache) {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7236ffc..c4691dd 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1450,6 +1450,12 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (!_read_activation_params(cmd, vg, &lp))
 		goto_out;
 
+	if (vg_is_clustered(vg) && !segtype_allowed_in_cluster_vg(lp.segtype)) {
+		log_error("LV segtype %s is not allowed in a cluster VG.",
+			  lp.segtype->name);
+		goto_out;
+	}
+
 	/* Resolve segment types with opened VG */
 	if (lp.snapshot && lp.origin_name && !_determine_snapshot_type(vg, &lp, &lcp))
 		goto_out;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e5d700d..5e52a87 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -299,6 +299,7 @@ static int _vgchange_resizeable(struct cmd_context *cmd,
 static int _vgchange_clustered(struct cmd_context *cmd,
 			       struct volume_group *vg)
 {
+	struct lv_list *lvl;
 	int clustered = arg_int_value(cmd, clustered_ARG, 0);
 
 	if (clustered && (vg_is_clustered(vg))) {
@@ -313,6 +314,17 @@ static int _vgchange_clustered(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (clustered) {
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			if (!segtype_allowed_in_cluster_vg(first_seg(lvl->lv)->segtype)) {
+				log_error("LV %s segtype %s is not allowed in cluster VG.",
+					  display_lvname(lvl->lv),
+					  first_seg(lvl->lv)->segtype->name);
+				return 0;
+			}
+		}
+	}
+
 	if (clustered && !arg_count(cmd, yes_ARG)) {
 		if (!clvmd_is_running()) {
 			if (yes_no_prompt("LVM cluster daemon (clvmd) is not"


