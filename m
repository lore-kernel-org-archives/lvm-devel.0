From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:12 +0000 (GMT)
Subject: main - cleanup: indent
Message-ID: <20210423210612.3D5703945C04@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05eb90db68dcaa89fbfcce52cf122f25488ee69f
Commit:        05eb90db68dcaa89fbfcce52cf122f25488ee69f
Parent:        fccd6e034625dade9ca302f2fcd99eb32d90974f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 19:45:34 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cleanup: indent

---
 lib/label/label.c | 2 +-
 tools/vgsplit.c   | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 203c5b6bb..9ebbb4ec9 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1097,7 +1097,7 @@ int label_scan(struct cmd_context *cmd)
 		 * so this will usually do nothing.
 		 */
 		label_scan_invalidate(dev);
-	};
+	}
 	dev_iter_destroy(iter);
 
 	/*
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 8a785bdbd..296248e7c 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -311,7 +311,7 @@ static int _move_raids(struct volume_group *vg_from,
 		/* Ignore, if no allocations on PVs of @vg_to */
 		if (!lv_is_on_pvs(lv, &vg_to->pvs))
 			continue;
- 
+
 		/* If allocations are on PVs of @vg_to -> move RAID LV stack across */
 		if (!_move_one_lv(vg_from, vg_to, lvh, &lvht))
 			return_0;
@@ -460,7 +460,7 @@ static int _move_cache(struct volume_group *vg_from,
 			    !lv_is_on_pvs(meta, &vg_to->pvs))
 				continue;
 		}
-		
+
 		if (fast && orig &&
 		    !lv_is_on_pvs(orig, &vg_to->pvs) && !lv_is_on_pvs(fast, &vg_to->pvs))
 			continue;


