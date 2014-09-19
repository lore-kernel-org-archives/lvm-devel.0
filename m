From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Sep 2014 13:57:42 +0000 (UTC)
Subject: master - cleanup: lvchange remove some extra code.
Message-ID: <20140919135742.DD69F60317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=702b6482154b0d8a9488c304081992f2d569f005
Commit:        702b6482154b0d8a9488c304081992f2d569f005
Parent:        3adc50ac22f5a3e355db5d143303c8b7dfb7c828
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 15:10:21 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:55:46 2014 +0200

cleanup: lvchange remove some extra code.

We do not need to restore LV content on error path - since
for reactivation we always use  ondisk/commited metadata,
so passed data are never used.

Drop some unneded extra message, since the called function
repeated logs same info.
---
 tools/lvchange.c |   20 ++------------------
 1 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index b196591..e520157 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -399,19 +399,8 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	if (!vg_write(lv->vg)) {
-		log_error("Failed to write intermediate VG metadata.");
-		if (!attach_metadata_devices(seg, &device_list))
-			stack;
-		if (!_reactivate_lv(lv, active, exclusive))
-			stack;
-		return 0;
-	}
-
-	if (!vg_commit(lv->vg)) {
-		log_error("Failed to commit intermediate VG metadata.");
-		if (!attach_metadata_devices(seg, &device_list))
-			stack;
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
+		log_error("Failed to update intermediate VG metadata on disk.");
 		if (!_reactivate_lv(lv, active, exclusive))
 			stack;
 		return 0;
@@ -428,10 +417,6 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 			return 0;
 		}
 
-		log_very_verbose("Clearing %s device %s",
-				 (seg_is_raid(seg)) ? "metadata" : "log",
-				 lvl->lv->name);
-
 		if (!wipe_lv(lvl->lv, (struct wipe_params)
 			     { .do_zero = 1, .zero_sectors = lvl->lv->size })) {
 			log_error("Unable to reset sync status for %s",
@@ -460,7 +445,6 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 		return 0;
 	}
 
-	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
 		log_error("Failed to update metadata on disk.");
 		return 0;


