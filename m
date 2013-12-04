From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:25 +0000 (UTC)
Subject: master - snapshots: use lv_check_not_in_use
Message-ID: <20131204133125.0BB0C60EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84b3852ee5ed6d6a254ec4ffa9254db034c902bc
Commit:        84b3852ee5ed6d6a254ec4ffa9254db034c902bc
Parent:        778de22d51aae736d6891920617191a41c236596
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 15:02:57 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:24 2013 +0100

snapshots: use lv_check_not_in_use

Switch from a simple 'open_count' test on opened snaphost
to a more 'skilled'  lv_check_not_in_use().
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   19 +++++++------------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0689b18..fa97962 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Replace open_count check with lv_check_not_in_use() for snapshot open test.
   Add error messages with LV names for failing lv refresh.
   Compile/link daemons with RELRO and PIE options to harden daemon security.
   Support per-object compilation cflags via CFLAGS_object.o.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 44dfeb6..f75f1cf 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1910,19 +1910,14 @@ static int _lv_has_open_snapshots(struct logical_volume *lv)
 	struct lvinfo info;
 	int r = 0;
 
-	dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list) {
-		if (!lv_info(lv->vg->cmd, snap_seg->cow, 0, &info, 1, 0)) {
-			r = 1;
-			continue;
-		}
+	dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list)
+		if (!lv_info(lv->vg->cmd, snap_seg->cow, 0, &info, 1, 0) ||
+		    !lv_check_not_in_use(lv->vg->cmd, snap_seg->cow, &info))
+			r++;
 
-		if (info.exists && info.open_count) {
-			log_error("LV %s/%s has open snapshot %s: "
-				  "not deactivating", lv->vg->name, lv->name,
-				  snap_seg->cow->name);
-			r = 1;
-		}
-	}
+	if (r)
+		log_error("LV %s/%s has open %d snapshot(s), not deactivating.",
+			  lv->vg->name, lv->name, r);
 
 	return r;
 }


