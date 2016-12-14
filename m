From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Dec 2016 10:42:42 +0000 (UTC)
Subject: master - cleanup: use exiting function
Message-ID: <20161214104242.32A2F60C8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f98d5c2e6d103a46bb5eca75ac496622933c475
Commit:        0f98d5c2e6d103a46bb5eca75ac496622933c475
Parent:        fecd043cca4b5f4d5a244d715c60ce35ff1b62d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 14 11:34:28 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 14 11:41:42 2016 +0100

cleanup: use exiting function

Reuse existing code and some indent change.
---
 lib/metadata/lv_manip.c   |    4 ++--
 lib/metadata/raid_manip.c |    9 ++-------
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 211b190..1889998 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6258,12 +6258,12 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 
 int lv_update_and_reload(struct logical_volume *lv)
 {
-        return _lv_update_and_reload(lv, 0);
+	return _lv_update_and_reload(lv, 0);
 }
 
 int lv_update_and_reload_origin(struct logical_volume *lv)
 {
-        return _lv_update_and_reload(lv, 1);
+	return _lv_update_and_reload(lv, 1);
 }
 
 /*
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b48b959..5ec86a3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1464,13 +1464,8 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	/*
 	 * Eliminate the residual LVs
 	 */
-	dm_list_iterate_items(lvl, &removal_lvs) {
-		if (!deactivate_lv(cmd, lvl->lv))
-			return_0;
-
-		if (!lv_remove(lvl->lv))
-			return_0;
-	}
+	if (!_deactivate_and_remove_lvs(lv->vg, &removal_lvs))
+                return_0;
 
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;


