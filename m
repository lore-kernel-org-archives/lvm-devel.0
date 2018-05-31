From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:20 -0400
Subject: master - lvmlockd: enable lvcreate of thin pool and thin lv in one command
Message-ID: <201805311414.w4VEEKAn031179@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=948f2d997990048ad6759bfb25f042a4ddbb6a83
Commit:        948f2d997990048ad6759bfb25f042a4ddbb6a83
Parent:        db8d3bdfa93bb08a85953f2f3150ee27dffaa5fe
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 25 12:53:53 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

lvmlockd: enable lvcreate of thin pool and thin lv in one command

Previously, thin pools and thin lvs need needed to be
created with separate commands, now the combined command
is permitted.
---
 lib/metadata/lv_manip.c |    6 ++++++
 tools/lvcreate.c        |    3 +--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8c76a38..4aefea0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8025,8 +8025,14 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 			if (!(lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_THIN_POOL)))
 				return_NULL;
 
+			/* We want a lockd lock for the new thin pool, but not the thin lv. */
+			lp->needs_lockd_init = 1;
+
 			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
 				return_NULL;
+
+			lp->needs_lockd_init = 0;
+
 		} else if (seg_is_cache(lp)) {
 			if (!lp->origin_name) {
 				/* Until we have --pooldatasize we are lost */
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index e901968..39170dd 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1638,8 +1638,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 			    lp->snapshot ? lp->origin_name : "", lp->segtype->name);
 
 	if (is_lockd_type(vg->lock_type)) {
-		if (cmd->command->command_enum == lvcreate_thin_vol_and_thinpool_CMD ||
-		    cmd->command->command_enum == lvcreate_cachepool_CMD ||
+		if (cmd->command->command_enum == lvcreate_cachepool_CMD ||
 		    cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_CMD ||
 		    cmd->command->command_enum == lvcreate_thin_vol_with_thinpool_or_sparse_snapshot_CMD ||
 		    cmd->command->command_enum == lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool_CMD) {


