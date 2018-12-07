From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Dec 2018 14:13:29 -0500
Subject: master - lvmlockd: fix missing LV lock for lvconvert repair
Message-ID: <201812071913.wB7JDTsK001639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4b8377488f82c496b14ee6d644fc681968acaca
Commit:        a4b8377488f82c496b14ee6d644fc681968acaca
Parent:        21784e94d6f4308931fa497679f1a4e5e1966578
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 7 13:11:31 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Dec 7 13:11:31 2018 -0600

lvmlockd: fix missing LV lock for lvconvert repair

Add missing lvmlockd LV lock for lvconvert repair
on mirror and thin/cache pools.
---
 tools/lvconvert.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a29a66b..65a4ed3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3534,6 +3534,18 @@ static int _lvconvert_repair_pvs_mirror(struct cmd_context *cmd, struct logical_
 	int ret;
 
 	/*
+	 * We want to allow cmirror active on multiple nodes to be repaired,
+	 * but normal mirror to only be repaired if active exclusively here.
+	 * If the LV is active it already has the necessary lock, but if not
+	 * active, then require ex since we cannot know the active state on
+	 * other hosts.
+	 */
+	if (!lv_is_active(lv)) {
+		if (!lockd_lv(cmd, lv, "ex", 0))
+			return_0;
+	}
+
+	/*
 	 * FIXME: temporary use of lp because _lvconvert_mirrors_repair()
 	 * and _aux() still use lp fields everywhere.
 	 * Migrate them away from using lp (for the most part just use
@@ -3663,6 +3675,10 @@ static int _lvconvert_repair_cachepool_thinpool(struct cmd_context *cmd, struct
 	int poolmetadataspare = arg_int_value(cmd, poolmetadataspare_ARG, DEFAULT_POOL_METADATA_SPARE);
 	struct dm_list *use_pvh;
 
+	/* ensure it's not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		return_0;
+
 	if (cmd->position_argc > 1) {
 		/* First pos arg is required LV, remaining are optional PVs. */
 		if (!(use_pvh = create_pv_list(cmd->mem, lv->vg, cmd->position_argc - 1, cmd->position_argv + 1, 0)))


