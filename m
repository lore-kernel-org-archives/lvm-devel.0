From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Feb 2017 14:41:10 +0000 (UTC)
Subject: master - snapshot: improve removal of active origin volume
Message-ID: <20170222144110.16EC560E67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9712995edd60220cd525c51b6bab9f7bd3b38b5a
Commit:        9712995edd60220cd525c51b6bab9f7bd3b38b5a
Parent:        6716f5a2f46f034f24d01918cc1dc78cd7bac9be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 22 15:12:54 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 22 15:35:04 2017 +0100

snapshot: improve removal of active origin volume

Previously when lvremove tried to remove 'active' origin,
it had been asking for every 'snapshot' LV separately
and doing individual single snapshot removals first.

To be faster it now deactivates origin before removal
all connected snapshots.

This avoids multiple reloads of dm table for origin volume
which were unnecessary as origin was meant to be removed as well.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   17 +++++++++++++----
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b0768cd..722b6f6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Deactivate active origin first before removal for improved workflow.
   Fix regression of accepting options --type and -m with lvresize (2.02.158).
   Add lvconvert --swapmetadata, new specific way to swap pool metadata LVs.
   Add lvconvert --startpoll, new specific way to start polling conversions.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d8f869d..78cc30e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6229,12 +6229,21 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 		/* Remove snapshot LVs first */
 		if ((force == PROMPT) &&
 		    /* Active snapshot already needs to confirm each active LV */
-		    !lv_is_active(lv) &&
-		    yes_no_prompt("Removing origin %s will also remove %u "
-				  "snapshots(s). Proceed? [y/n]: ",
-				  lv->name, lv->origin_count) == 'n')
+		    (yes_no_prompt("Do you really want to remove%s "
+				   "%sorigin logical volume %s with %u snapshot(s)? [y/n]: ",
+				   lv_is_active(lv) ? " active" : "",
+				   vg_is_clustered(lv->vg) ? "clustered " : "",
+				   display_lvname(lv),
+				   lv->origin_count) == 'n'))
 			goto no_remove;
 
+		if (!deactivate_lv(cmd, lv)) {
+			stack;
+			goto no_remove;
+		}
+		log_verbose("Removing origin logical volume %s with %u snapshots(s).",
+			    display_lvname(lv), lv->origin_count);
+
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
 										  origin_list)->cow,


