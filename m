From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:47 -0500
Subject: [PATCH 07/15] lvm-merge-check-for-mounted-lv
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-8-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

Do not allow merging over mounted logical volumes.
When preserving origin, check that the snapshot is not mounted.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 tools/lvconvert.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 517b4f3..49b22a7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -920,6 +920,7 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	int r = 0;
 	struct logical_volume *origin = origin_from_cow(lv);
 	struct lv_segment *cow_seg = find_cow(lv);
+	struct lvinfo info;
 
 	/* Check if merge is possible */
 	if (cow_seg->status & SNAPSHOT_MERGE) {
@@ -932,6 +933,19 @@ static int lvconvert_merge(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (lv_info(cmd, origin, &info, 1, 0)) {
+		if (info.open_count) {
+			log_error("Can't merge over open origin volume");
+			return 0;
+		}
+	}
+	if (lv_info(cmd, lv, &info, 1, 0)) {
+		if (info.open_count) {
+			log_error("Can't merge when snapshot is open");
+			return 0;
+		}
+	}
+
 	/*
 	 * Even though lv_is_visible(cow_seg->lv) returns 0,
 	 * the cow_seg->lv (name: snapshotX) is _not_ hidden;
-- 
1.6.5.2


