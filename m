From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:51 +0000 (UTC)
Subject: dev-mornfall-lvmcache - vgchange: check for mounted fs
Message-ID: <20130605120351.9BFCE610C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ada982e73872e45215e68e57b2b6b4168dc26f8
Commit:        2ada982e73872e45215e68e57b2b6b4168dc26f8
Parent:        810bc4f8c1f2f28bf78ac538486d63317ba9b079
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 8 23:43:28 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 20 16:47:33 2013 +0200

vgchange: check for mounted fs

Check for mounted fs also for vgchange command, not just lvchange.

NOTE: Code is using lv_info() just like lvs_in_vg_opened().
It should be probably converted into  lv_is_active_locally().
---
 WHATS_NEW        |    1 +
 tools/vgchange.c |   13 ++++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2583e2d..e63e000 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add detection of mounted fs also for vgchange deactivation.
   Replace 'lv_is_active' with more correct/specific variants (e.g. *_locally).
   Refuse to init a snapshot merge in lvconvert if there's no kernel support.
   Fix exported symbols regex for non-GNU busybox sed.
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 5c0a6fc..71982f1 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -191,6 +191,8 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		      activation_change_t activate)
 {
 	int lv_open, active, monitored = 0, r = 1, do_activate = 1;
+	const struct lv_list *lvl;
+	struct lvinfo info;
 
 	if ((activate == CHANGE_AN) || (activate == CHANGE_ALN))
 		do_activate = 0;
@@ -203,9 +205,14 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 
 	/* FIXME: Force argument to deactivate them? */
 	if (!do_activate && (lv_open = lvs_in_vg_opened(vg))) {
-		log_error("Can't deactivate volume group \"%s\" with %d open "
-			  "logical volume(s)", vg->name, lv_open);
-		return 0;
+		dm_list_iterate_items(lvl, &vg->lvs)
+			if (lv_is_visible(lvl->lv) &&
+			    lv_info(cmd, lvl->lv, 0, &info, 1, 0) &&
+			    !lv_check_not_in_use(cmd, lvl->lv, &info)) {
+				log_error("Can't deactivate volume group \"%s\" with %d open "
+					  "logical volume(s)", vg->name, lv_open);
+				return 0;
+			}
 	}
 
 	/* FIXME Move into library where clvmd can use it */


