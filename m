From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:04 +0000 (UTC)
Subject: master - pools: prompt only when metadata lv exists
Message-ID: <20141110210604.8BED760AA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09e32e4addd63d232ea98b0c6d633efbfc503daf
Commit:        09e32e4addd63d232ea98b0c6d633efbfc503daf
Parent:        138c2417c070eef5cdb9839a88efae5b601f4a49
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 8 13:53:13 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 21:35:56 2014 +0100

pools: prompt only when metadata lv exists

If the VG has no pool metadata volume, don't prompt about
removal of _pmspare.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   18 ++++++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 06d3b9b..8c0a85d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Don't prompt for removal of _pmspare in VG without pool metadata LV.
   Deactivation of snapshot origin detects and deactivates left-over snapshots.
   Properly report error when taking snapshot of any cache type LV.
   Add basic thread debugging messages to dmeventd.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index bedf4b6..b029395 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5570,6 +5570,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	dm_percent_t snap_percent;
 	struct dm_list *snh, *snht;
 	struct lvinfo info;
+	struct lv_list *lvl;
 	struct logical_volume *origin;
 
 	if (lv_is_cow(lv)) {
@@ -5649,12 +5650,17 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 		return_0;
 
 	if (lv_is_pool_metadata_spare(lv) &&
-	    (force == PROMPT) &&
-	    (yes_no_prompt("Removal of pool metadata spare logical volume"
-			   " \"%s\" disables automatic recovery attempts"
-			   " after damage to a thin or cache pool."
-			   " Proceed? [y/n]: ", lv->name) == 'n'))
-		goto no_remove;
+	    (force == PROMPT)) {
+		dm_list_iterate_items(lvl, &lv->vg->lvs)
+			if (lv_is_pool_metadata(lvl->lv)) {
+				if (yes_no_prompt("Removal of pool metadata spare logical volume"
+						  " \"%s\" disables automatic recovery attempts"
+						  " after damage to a thin or cache pool."
+						  " Proceed? [y/n]: ", lv->name) == 'n')
+					goto no_remove;
+				break;
+			}
+	}
 
 	return lv_remove_single(cmd, lv, force, 0);
 


