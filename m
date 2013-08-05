From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon,  5 Aug 2013 15:03:17 -0500
Subject: [PATCH 6/6] Thin: Support moving thin sub-LVs with pvmove
In-Reply-To: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
References: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1375732997-23644-7-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Ignore top-level thin LVs while allowing processing of bottom-level
LVs.  This patch also enables pvmove of thin types which may be
on top of RAID or mirror LVs.
---
 tools/pvmove.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 7d3f518..956b848 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -310,7 +310,8 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 		}
 		seg = first_seg(lv);
-		if (seg_is_raid(seg) || seg_is_mirrored(seg)) {
+		if (seg_is_raid(seg) || seg_is_mirrored(seg) ||
+		    lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {
 			/*
 			 * Pass over top-level LVs - they were handled.
 			 * Allow sub-LVs to proceed.
@@ -319,13 +320,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 				  seg->segtype->ops->name(seg), lv->name);
 			continue;
 		}
-		if (lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping thin%s LV %s",
-						lv_is_thin_pool(lv) ? "-pool" : "",
-						lv->name);
-			continue;
-		}
+
 		if (lv->status & LOCKED) {
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping locked LV %s", lv->name);
-- 
1.7.7.6


