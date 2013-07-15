From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:03:01 +0000 (UTC)
Subject: master - thin: write back when command successfully finished
Message-ID: <20130715140301.80ABB60FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=925701d9f37e149a738aa4875f2933bee42ca8d0
Commit:        925701d9f37e149a738aa4875f2933bee42ca8d0
Parent:        42881c887777257de42acf695aa3da7693af33d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 11:39:03 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:48:32 2013 +0200

thin: write back when command successfully finished

Remove backup() call from update_pool_lv() as it's been there
duplicated and preperly order backup() call after lvresize,
so there is just one such call.
---
 WHATS_NEW                 |    1 +
 lib/metadata/lv_manip.c   |    4 ++--
 lib/metadata/thin_manip.c |    2 --
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4c662c1..deb0338 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Avoid generating metadata backup when calling update_pool_lv().
   Send thin messages also for active thin pool and inactive thin volume.
   Add activation/auto_set_activation_skip to control activation skip flagging.
   Add 's(k)ip activation' bit to lvs -o lv_attr to indicate skip flag attached.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 87f30f7..5ec2bd0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4053,8 +4053,6 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!monitor_dev_for_events(cmd, lv, 0, 0))
 			stack;
 
-	backup(vg);
-
 	/*
 	 * Update lvm pool metadata (drop messages) if the pool has been
 	 * resumed and do a pool active/deactivate in other case.
@@ -4067,6 +4065,8 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	    !update_pool_lv(lv, !lv_is_active(lv)))
 		return_0;
 
+	backup(vg);
+
 	log_print_unless_silent("Logical volume %s successfully resized", lp->lv_name);
 
 	if (lp->resizefs && (lp->resize == LV_EXTEND) &&
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 5b1b440..4f6e2ec 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -558,8 +558,6 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
-	backup(lv->vg);
-
 	return 1;
 }
 


