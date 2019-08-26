From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 09:34:17 -0400
Subject: master - snapshot: always activate
Message-ID: <201908261334.x7QDYHp2005491@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=af0b84ccc850d619eddef5112753731abce099ed
Commit:        af0b84ccc850d619eddef5112753731abce099ed
Parent:        7833c45fbe79e49ac22e50b90917b7d7ff2d78ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 15:13:55 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 15:23:44 2019 +0200

snapshot: always activate

Drop the 'cluster-only' optimization so we do resume ALL device
before we try to wait on cookie before 'removal' operation.

It's more correct order of operation - alhtough possibly slightly
less efficient - but until we have correct list of operations
'in-progress' we can't do anything better.
---
 lib/metadata/snapshot_manip.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 5ccf251..65d8dbd 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -361,13 +361,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 			return 0;
 		}
 
-		/*
-		 * For merged snapshot and clustered VG activate cow LV so
-		 * the following call to deactivate_lv() can clean-up table
-		 * entries. For this clustered lock need to be held.
-		 */
-		if (vg_is_clustered(cow->vg) &&
-		    merging_snapshot && !activate_lv(cow->vg->cmd, cow)) {
+		if (merging_snapshot && !activate_lv(cow->vg->cmd, cow)) {
 			log_error("Failed to activate %s.", cow->name);
 			return 0;
 		}


