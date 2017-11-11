From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Nov 2017 19:03:21 -0500
Subject: master - lvremove: for unused cache deactive sublv
Message-ID: <201711110003.vAB03LlY009590@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52cee9dd83da0b9b6766a4b3ee6bdd3699bf4346
Commit:        52cee9dd83da0b9b6766a4b3ee6bdd3699bf4346
Parent:        55b8204ca3ca9fe05bc04cb1e1f3fc24ebbdfe48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 11 00:19:04 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 11 00:59:19 2017 +0100

lvremove: for unused cache deactive sublv

---
 lib/metadata/lv_manip.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d06b459..4fc9708 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6357,6 +6357,15 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
 
+	if (lv_is_cache_pool(lv) && !lv_is_used_cache_pool(lv)) {
+		if (!deactivate_lv(cmd, first_seg(lv)->metadata_lv) ||
+		    !deactivate_lv(cmd, seg_lv(first_seg(lv),0))) {
+			log_error("Unable to fully deactivate unused cache-pool %s.",
+				  display_lvname(lv));
+			return 0;
+		}
+	}
+
 	if (lv_is_pool_metadata_spare(lv) &&
 	    (force == PROMPT)) {
 		dm_list_iterate_items(lvl, &lv->vg->lvs)


