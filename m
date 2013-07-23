From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Jul 2013 13:17:19 +0000 (UTC)
Subject: master - snapshot: update merging fix
Message-ID: <20130723131719.4CD1A613EB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=373f95a921223c1e4d36ae975ac685227369cf5b
Commit:        373f95a921223c1e4d36ae975ac685227369cf5b
Parent:        6311be29e40af21a53ef2a09a99867fc4460a73e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 23 15:15:04 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 23 15:15:04 2013 +0200

snapshot: update merging fix

Activation is needed only for clustered VG.
For non-clustered VG skip activation, since deactivate_lv()
is called without problems (no testing for lock presence).

(updates f6ded62291682e40c7976d27e48915d9d1538940)
---
 lib/metadata/snapshot_manip.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index ab28890..325a4e8 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -298,10 +298,12 @@ int vg_remove_snapshot(struct logical_volume *cow)
 		}
 
 		/*
-		 * For merged snapshot we activate cow so it can clean
-		 * left table entries and deactivate_lv() follows shortly.
+		 * For merged snapshot and clustered VG activate cow LV so
+		 * the following call to deactivate_lv() can clean-up table
+		 * entries. For this clustered lock need to be held.
 		 */
-		if (merging_snapshot && !activate_lv(cow->vg->cmd, cow)) {
+		if (vg_is_clustered(cow->vg) &&
+		    merging_snapshot && !activate_lv(cow->vg->cmd, cow)) {
 			log_error("Failed to activate %s.", cow->name);
 			return 0;
 		}


