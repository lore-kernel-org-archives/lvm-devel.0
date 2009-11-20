From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:52 -0500
Subject: [PATCH 12/15] lvm-merge-reload-if-stopped-merging
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-13-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

Reload origin if merging has stopped.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/metadata/lv_manip.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ecaab29..7990863 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2061,6 +2061,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct volume_group *vg;
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
+	int was_merging = 0;
 
 	vg = lv->vg;
 
@@ -2122,6 +2123,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lv_is_cow(lv)) {
 		origin = origin_from_cow(lv);
+		was_merging = !!origin->merging_snapshot;
 		log_verbose("Removing snapshot %s", lv->name);
 		if (!vg_remove_snapshot(lv))
 			return_0;
@@ -2139,8 +2141,8 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	backup(vg);
 
-	/* If no snapshots left, reload without -real. */
-	if (origin && !lv_is_origin(origin)) {
+	/* If no snapshots left or if we stopped merging, reload */
+	if (origin && (!lv_is_origin(origin) || was_merging)) {
 		if (!suspend_lv(cmd, origin))
 			log_error("Failed to refresh %s without snapshot.", origin->name);
 		else if (!resume_lv(cmd, origin))
-- 
1.6.5.2


