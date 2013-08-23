From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 23 Aug 2013 14:14:19 +0000 (UTC)
Subject: master - pvmove: Ability to move thin volumes
Message-ID: <20130823141419.A46A7610BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=448ff0119fc0f4983917e10b663d9db896f8c5db
Commit:        448ff0119fc0f4983917e10b663d9db896f8c5db
Parent:        c59167ec132071d6ab53f928b0775c36a704fe7c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 23 09:13:14 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Aug 23 09:13:14 2013 -0500

pvmove: Ability to move thin volumes

The previous commit was missing the code to allow moving thin
volumes.
---
 tools/pvmove.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 34adc6d..8e95048 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -309,20 +309,15 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 		}
 		seg = first_seg(lv);
-		if (seg_is_raid(seg) || seg_is_mirrored(seg)) {
+		if (seg_is_raid(seg) || seg_is_mirrored(seg) ||
+		    lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {
 			/*
 			 * Pass over top-level LVs - they were handled.
 			 * Allow sub-LVs to proceed.
 			 */
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


