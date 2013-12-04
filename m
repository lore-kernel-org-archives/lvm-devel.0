From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:43 +0000 (UTC)
Subject: master - thin: merge removal
Message-ID: <20131204133143.E3DB260FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5fc3352a1563f0fc5a14d163b03a357742e3987e
Commit:        5fc3352a1563f0fc5a14d163b03a357742e3987e
Parent:        664a695561c98645dd557428108766b702db530d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 21:21:00 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:26 2013 +0100

thin: merge removal

When thin is merged - properly handly device removal.
---
 lib/metadata/lv_manip.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2458447..9806758 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -775,11 +775,23 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 	uint32_t count = extents;
 	uint32_t reduction;
 
+	if (lv_is_merging_origin(lv)) {
+		log_debug_metadata("Dropping snapshot merge of %s to removed origin %s.",
+				   find_snapshot(lv)->lv->name, lv->name);
+		clear_snapshot_merge(lv);
+	}
+
 	dm_list_iterate_back_items(seg, &lv->segments) {
 		if (!count)
 			break;
 
 		if (seg->len <= count) {
+			if (seg->merge_lv) {
+				log_debug_metadata("Dropping snapshot merge of removed %s to origin %s.",
+						   seg->lv->name, seg->merge_lv->name);
+				clear_snapshot_merge(seg->merge_lv);
+			}
+
 			/* remove this segment completely */
 			/* FIXME Check this is safe */
 			if (seg->log_lv && !lv_remove(seg->log_lv))
@@ -4734,6 +4746,27 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 				return_0;
 	}
 
+	if (lv_is_merging_origin(lv)) {
+		if (!deactivate_lv(cmd, lv)) {
+			log_error("Unable to fully deactivate merging origin \"%s\".",
+				  lv->name);
+			return 0;
+		}
+		if (!lv_remove_with_dependencies(cmd, find_snapshot(lv)->lv,
+						 force, level + 1)) {
+			log_error("Unable to remove merging origin \"%s\".",
+				  lv->name);
+			return 0;
+		}
+	}
+
+	if (!level && lv_is_merging_thin_snapshot(lv)) {
+		/* Merged snapshot LV is no longer available for the user */
+		log_error("Unable to remove \"%s\", volume is merged to \"%s\".",
+			  lv->name, first_seg(lv)->merge_lv->name);
+		return 0;
+	}
+
 	if (lv_is_external_origin(lv) &&
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "external origin"))
 		return_0;


