From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jun 2017 06:36:46 -0400
Subject: master - raid: more origin_only updates
Message-ID: <201706211036.v5LAakm9021013@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49fa2bea1c82c4763fb87785683040fc0fe093d7
Commit:        49fa2bea1c82c4763fb87785683040fc0fe093d7
Parent:        1766eaec4b65a3e6d0cd54bca5ed11d73f675d90
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 21 11:17:03 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 21 12:35:16 2017 +0200

raid: more origin_only updates

Seems the code is multiplied - so keep it consistent for now.

TODO:  drop all uneeded code
---
 lib/metadata/raid_manip.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 290dec7..d3bbb60 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -650,6 +650,12 @@ static int _lv_update_and_reload_list(struct logical_volume *lv, int origin_only
 	struct lv_list *lvl;
 	int r;
 
+	if (lock_lv != lv) {
+		log_debug_activation("Dropping origin_only for %s as lock holds %s",
+				     display_lvname(lv), display_lvname(lock_lv));
+		origin_only = 0;
+	}
+
 	log_very_verbose("Updating logical volume %s on disk(s)%s.",
 			 display_lvname(lock_lv), origin_only ? " (origin only)": "");
 
@@ -2112,15 +2118,22 @@ static int _vg_write_lv_suspend_commit_backup(struct volume_group *vg,
 					      struct logical_volume *lv,
 					      int origin_only, int do_backup)
 {
+	const struct logical_volume *lock_lv = lv_lock_holder(lv);
 	int r = 1;
 
+	if (lock_lv != lv) {
+		log_debug_activation("Dropping origin_only for %s as lock holds %s",
+				     display_lvname(lv), display_lvname(lock_lv));
+		origin_only = 0;
+	}
+
 	if (!vg_write(vg)) {
 		log_error("Write of VG %s failed.", vg->name);
 		return_0;
 	}
 
-	if (lv && !(r = (origin_only ? suspend_lv_origin(vg->cmd, lv_lock_holder(lv)) :
-				       suspend_lv(vg->cmd, lv_lock_holder(lv))))) {
+	if (lv && !(r = (origin_only ? suspend_lv_origin(vg->cmd, lock_lv) :
+				       suspend_lv(vg->cmd, lock_lv)))) {
 		log_error("Failed to suspend %s before committing changes.",
 			  display_lvname(lv));
 		vg_revert(lv->vg);


