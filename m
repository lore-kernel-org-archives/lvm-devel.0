From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:53 -0500
Subject: [PATCH 13/15] lvm-merge-reload-proper-order
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-14-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

When turning merging origin into non-merging origin, there is bad sequence:
snapshots are suspended, new origin is created, snapshots are resumed, new
origin is resumed.  So it allocates memory while suspended.

To fix it, move vg_commit after suspend_lv, so that the suspend code will
treat it as precommitted vg and will preload new origin prior to suspend.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/metadata/lv_manip.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7990863..a036022 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2136,19 +2136,28 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* store it on disks */
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg))
 		return_0;
 
-	backup(vg);
-
 	/* If no snapshots left or if we stopped merging, reload */
 	if (origin && (!lv_is_origin(origin) || was_merging)) {
-		if (!suspend_lv(cmd, origin))
+		if (!suspend_lv(cmd, origin)) {
 			log_error("Failed to refresh %s without snapshot.", origin->name);
-		else if (!resume_lv(cmd, origin))
+			return 0;
+		}
+		if (!vg_commit(vg))
+			return_0;
+		if (!resume_lv(cmd, origin)) {
 			log_error("Failed to resume %s.", origin->name);
+			return 0;
+		}
+	} else {
+		if (!vg_commit(vg))
+			return_0;
 	}
 
+	backup(vg);
+
 	if (lv_is_visible(lv))
 		log_print("Logical volume \"%s\" successfully removed", lv->name);
 
-- 
1.6.5.2


