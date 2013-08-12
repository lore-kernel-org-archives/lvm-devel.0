From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 12 Aug 2013 17:44:04 +0000 (UTC)
Subject: master - RAID: Fix bug making lvchange unable to change recovery rate for RAID
Message-ID: <20130812174404.8E43860F0E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bb457adbb6d625a5f942faf8498bb5ee87645ec3
Commit:        bb457adbb6d625a5f942faf8498bb5ee87645ec3
Parent:        28760275e69f16d43b8cb1a31dd5b5e14ff232b6
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Aug 12 12:40:52 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Aug 12 12:43:47 2013 -0500

RAID: Fix bug making lvchange unable to change recovery rate for RAID

Commit ID 8615234c0fa331852a11e1bf595bf1d4b858f4bc failed to include
the actual code changes that were made to fix the bug.  Instead, all
tests went in to validate the bug fix.  This patch adds the missing
code changes.
---
 tools/lvchange.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4973406..525022f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -823,7 +823,7 @@ static int lvchange_recovery_rate(struct logical_volume *lv)
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *raid_seg = first_seg(lv);
 
-	if (strcmp(raid_seg->segtype->name, "raid1")) {
+	if (!seg_is_raid(raid_seg)) {
 		log_error("Unable to change the recovery rate of non-RAID"
 			  " logical volume.");
 		return 0;
@@ -831,10 +831,10 @@ static int lvchange_recovery_rate(struct logical_volume *lv)
 
 	if (arg_count(cmd, minrecoveryrate_ARG))
 		raid_seg->min_recovery_rate =
-			arg_uint_value(cmd, minrecoveryrate_ARG, 0);
+			arg_uint_value(cmd, minrecoveryrate_ARG, 0) / 2;
 	if (arg_count(cmd, maxrecoveryrate_ARG))
 		raid_seg->max_recovery_rate =
-			arg_uint_value(cmd, maxrecoveryrate_ARG, 0);
+			arg_uint_value(cmd, maxrecoveryrate_ARG, 0) / 2;
 
 	if (raid_seg->max_recovery_rate &&
 	    (raid_seg->max_recovery_rate < raid_seg->min_recovery_rate)) {
@@ -1145,9 +1145,9 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	int update_partial_unsafe =
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, discards_ARG) ||
+		arg_count(cmd, minrecoveryrate_ARG) ||
+		arg_count(cmd, maxrecoveryrate_ARG) ||
 		arg_count(cmd, resync_ARG) ||
-		arg_count(cmd, raidminrecoveryrate_ARG) ||
-		arg_count(cmd, raidmaxrecoveryrate_ARG) ||
 		arg_count(cmd, syncaction_ARG) ||
 		arg_count(cmd, writebehind_ARG) ||
 		arg_count(cmd, writemostly_ARG) ||


