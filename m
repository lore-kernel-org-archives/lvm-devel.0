From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  1 Jun 2016 15:42:24 +0000 (UTC)
Subject: master - cleanup: use display_name
Message-ID: <20160601154224.AE23360F20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21cefd3f07f4c6408d5c59c5afd41d3056706513
Commit:        21cefd3f07f4c6408d5c59c5afd41d3056706513
Parent:        a5d65b4a513b322def4b6da1d498e4491c9da6d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 1 17:40:26 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 1 17:40:26 2016 +0200

cleanup: use display_name

---
 lib/locking/lvmlockd.c  |    7 +++----
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index d718ac9..9eb7f92 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -369,18 +369,17 @@ static int _extend_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 	struct lvresize_params lp = {
 		.lv_name = vg->sanlock_lv->name,
 		.sign = SIGN_NONE,
+		.size = lv->size + ((extend_mb * 1024 * 1024) / SECTOR_SIZE),
 		.percent = PERCENT_NONE,
 		.resize = LV_EXTEND,
 		.ac_force = 1,
 		.sizeargs = 1,
 	};
 
-	lp.size = lv->size + ((extend_mb * 1024 * 1024) / SECTOR_SIZE);
-
 	if (!lv_resize_prepare(cmd, lv, &lp, &vg->pvs) ||
 	    !lv_resize(cmd, lv, &lp, &vg->pvs)) {
-		log_error("Extend LV %s/%s to size %llu failed.",
-			  vg->name, lv->name, (unsigned long long)lp.size);
+		log_error("Extend LV %s to size %s failed.",
+			  display_lvname(lv), display_size(cmd, lp.size));
 		return 0;
 	}
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b31676d..a908e1e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5410,7 +5410,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	return 1;
 bad:
 	if (inactive && !deactivate_lv(cmd, lock_lv))
-		log_error("Problem deactivating %s.", lock_lv->name);
+		log_error("Problem deactivating %s.", display_lvname(lock_lv));
 
 	return 0;
 }


