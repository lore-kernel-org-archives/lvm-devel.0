From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:40 +0000 (UTC)
Subject: master - raid: fix delete on clustered vg
Message-ID: <20161211223440.EC20B60C4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8831a541a831a2d25cb96ee09f6739526d29e5c1
Commit:        8831a541a831a2d25cb96ee09f6739526d29e5c1
Parent:        0c8369099bc6105f39982b3e36dd9a53c347b07a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 10 20:00:32 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:18:22 2016 +0100

raid: fix delete on clustered vg

For clustered VG ensure lock is grabbed first,
so later deactivation works.

TODO: fix tree to solve device removal automatically.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 74627ba..b6f74ec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Fix deactivation of raid orphan devices for clustered VG.
   Fix lvconvert raid1 to mirror table reload order.
   Add internal function for separate mirror log preparation.
   Fix segfault in lvmetad from missing NULL in daemon_reply_simple.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5cbd819..661c39b 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -248,6 +248,12 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
 {
 	struct lv_list *lvl;
 
+	if (vg_is_clustered(vg))
+		/* Need to take lock for proper deactivation */
+		dm_list_iterate_items(lvl, removal_lvs)
+			if (!activate_lv_excl_local(vg->cmd, lvl->lv))
+				return_0;
+
 	dm_list_iterate_items(lvl, removal_lvs) {
 		if (!deactivate_lv(vg->cmd, lvl->lv))
 			return_0;
@@ -2968,6 +2974,12 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	    !lv_update_and_reload(lv))
 		return_0;
 
+	/* Note: detached rmeta are NOT renamed */
+	/* Grab locks first in case of clustered VG */
+	if (vg_is_clustered(lv->vg))
+		dm_list_iterate_items(lvl, &meta_lvs)
+			if (!activate_lv_excl_local(lv->vg->cmd, lvl->lv))
+				return_0;
 	/*
 	 * Now deactivate the MetaLVs before clearing, so
 	 * that _clear_lvs() will activate them visible.


