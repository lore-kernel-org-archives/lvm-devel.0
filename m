From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 15:51:37 -0400
Subject: master - lvmlockd: enable lvcreate -H -L LV
Message-ID: <201805311951.w4VJpba7020757@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d9d32b315afd0fb2b674ca3bb857cb4ce2cbf2e
Commit:        8d9d32b315afd0fb2b674ca3bb857cb4ce2cbf2e
Parent:        fdaa7e2e87d4a59b39e701961da6961f371ca980
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 14:20:11 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 14:20:11 2018 -0500

lvmlockd: enable lvcreate -H -L LV

Allow this command in a shared VG which had previously been
disallowed.
---
 tools/lvcreate.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7f97ebd..867cde1 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1230,6 +1230,14 @@ static int _determine_cache_argument(struct volume_group *vg,
 				log_verbose("Skipping activation of cache origin %s.",
 					    display_lvname(lv));
 				return 1;
+
+			} else if (is_lockd_type(vg->lock_type)) {
+				if (!lv_active_change(cmd, lv, CHANGE_AEY, 0)) {
+					log_error("Cannot activate cache origin %s.",
+						   display_lvname(lv));
+					return 0;
+				}
+
 			} else if (!activate_lv_excl_local(cmd, lv)) {
 				log_error("Cannot activate cache origin %s.",
 					  display_lvname(lv));
@@ -1638,8 +1646,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 			    lp->snapshot ? lp->origin_name : "", lp->segtype->name);
 
 	if (is_lockd_type(vg->lock_type)) {
-		if (cmd->command->command_enum == lvcreate_thin_vol_with_thinpool_or_sparse_snapshot_CMD ||
-		    cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool_CMD) {
+		if (cmd->command->command_enum == lvcreate_thin_vol_with_thinpool_or_sparse_snapshot_CMD) {
 			log_error("Use lvconvert to create thin pools and cache pools in a shared VG.");
 			goto out;
 		}


