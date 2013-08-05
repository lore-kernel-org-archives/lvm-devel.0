From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon,  5 Aug 2013 15:03:16 -0500
Subject: [PATCH 5/6] Mirror: Support moving mirror sub-LVs with pvmove
In-Reply-To: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
References: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1375732997-23644-6-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow pvmove to process mirror sub-LVs while using the top-level
mirror to inform it about which PVs should be avoided.
---
 man/pvmove.8.in |    4 ++--
 tools/pvmove.c  |   20 +++-----------------
 2 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index de20abb..485a35d 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -75,7 +75,7 @@ is updated so that the Logical Volumes reflect the new data locations.
 Note that this new process cannot support the original LVM1
 type of on-disk metadata.  Metadata can be converted using \fBvgconvert\fP(8).
 
-N.B. The moving of mirrors, snapshots and their origins is not yet supported.
+N.B. The moving of snapshots and their origins is not yet supported.
 
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
@@ -109,7 +109,7 @@ To move all Physical Extents that are used by simple Logical Volumes on
 .sp
 .B pvmove /dev/sdb1
 .P
-Any mirrors, snapshots and their origins are left unchanged.
+Any snapshots and their origins are left unchanged.
 .P
 Additionally, a specific destination device /dev/sdc1
 can be specified like this:
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 64db144..7d3f518 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -268,7 +268,8 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 		dm_list_init(&trim_list);
 
-		if (seg_is_raid(first_seg(lv))) {
+		if (seg_is_raid(first_seg(lv)) ||
+		    seg_is_mirrored(first_seg(lv))) {
 			if (!get_pv_list_for_lv(lv->vg->cmd->mem,
 						lv, &trim_list))
 				return_NULL;
@@ -309,7 +310,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 		}
 		seg = first_seg(lv);
-		if (seg_is_raid(seg)) {
+		if (seg_is_raid(seg) || seg_is_mirrored(seg)) {
 			/*
 			 * Pass over top-level LVs - they were handled.
 			 * Allow sub-LVs to proceed.
@@ -318,21 +319,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 				  seg->segtype->ops->name(seg), lv->name);
 			continue;
 		}
-		if (lv->status & MIRRORED) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping mirror LV %s", lv->name);
-			continue;
-		}
-		if (lv->status & MIRROR_LOG) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping mirror log LV %s", lv->name);
-			continue;
-		}
-		if (lv->status & MIRROR_IMAGE) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping mirror image LV %s", lv->name);
-			continue;
-		}
 		if (lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping thin%s LV %s",
-- 
1.7.7.6


