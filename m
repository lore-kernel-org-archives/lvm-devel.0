From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:43 +0000 (UTC)
Subject: master - lv_update_and_reload: use proper lock holder
Message-ID: <20140924085643.9D5A36109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa6482344c9f2491d29008b00ac1a4089c883aa7
Commit:        fa6482344c9f2491d29008b00ac1a4089c883aa7
Parent:        9776979b02ddd6405e13208a74fedfee0e1cfec3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 13:57:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:48:02 2014 +0200

lv_update_and_reload: use proper lock holder

When requesting to reload an LV imrove this API to
automatically reload its lock holding LV as in cluster
only top-level LVs are addressable with lock.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   13 +++++++------
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9869130..dafa16f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Improve lv_update_and_reload() to find out proper lock holding LV.
   Improve search of LV in lv_ondisk().
   Do not scan sysfs in lv_check_not_in_use() when device is closed.
   Backup final metadata after resync of mirror/raid.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 968b8d0..277662e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5701,16 +5701,17 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 {
 	struct volume_group *vg = lv->vg;
 	int do_backup = 0, r = 0;
+	const struct logical_volume *lock_lv = lv_lock_holder(lv);
 
 	log_very_verbose("Updating logical volume %s on disk(s).",
-			 display_lvname(lv));
+			 display_lvname(lock_lv));
 
 	if (!vg_write(vg))
 		return_0;
 
-	if (!(origin_only ? suspend_lv_origin(vg->cmd, lv) : suspend_lv(vg->cmd, lv))) {
+	if (!(origin_only ? suspend_lv_origin(vg->cmd, lock_lv) : suspend_lv(vg->cmd, lock_lv))) {
 		log_error("Failed to lock logical volume %s.",
-			  display_lvname(lv));
+			  display_lvname(lock_lv));
 		vg_revert(vg);
 	} else if (!(r = vg_commit(vg)))
 		stack; /* !vg_commit() has implict vg_revert() */
@@ -5718,11 +5719,11 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 		do_backup = 1;
 
 	log_very_verbose("Updating logical volume %s in kernel.",
-			 display_lvname(lv));
+			 display_lvname(lock_lv));
 
-	if (!(origin_only ? resume_lv_origin(vg->cmd, lv) : resume_lv(vg->cmd, lv))) {
+	if (!(origin_only ? resume_lv_origin(vg->cmd, lock_lv) : resume_lv(vg->cmd, lock_lv))) {
 		log_error("Problem reactivating logical volume %s.",
-			  display_lvname(lv));
+			  display_lvname(lock_lv));
 		r = 0;
 	}
 


