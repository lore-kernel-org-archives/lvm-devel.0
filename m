From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:32 +0000 (UTC)
Subject: master - lockd: check for failing unlock
Message-ID: <20150818130132.BDD4760643@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae4db9f302701ccbde1409647a85f53feaa6e13b
Commit:        ae4db9f302701ccbde1409647a85f53feaa6e13b
Parent:        70db1d523db330cbdfc39163c30dc00cf16a1fdc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 11:46:42 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:00:07 2015 +0200

lockd: check for failing unlock

Avoid ignoring unlocking error.
---
 tools/lvconvert.c  |    5 ++++-
 tools/polldaemon.c |    9 +++++++--
 tools/pvmove.c     |   10 ++++++++--
 tools/toollib.c    |   15 ++++++++++++---
 tools/vgchange.c   |    3 ++-
 5 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 040272a..36c4593 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3450,7 +3450,10 @@ bad:
 	unlock_vg(cmd, lp->vg_name);
 
 	/* Unlock here so it's not held during polling. */
-	lockd_vg(cmd, lp->vg_name, "un", 0, &lockd_state);
+	if (!lockd_vg(cmd, lp->vg_name, "un", 0, &lockd_state)) {
+		stack;
+		ret = ECMD_FAILED;
+	}
 
 	release_vg(vg);
 out:
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 83928b7..c7f6795 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -202,7 +202,8 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 
 		unlock_and_release_vg(cmd, vg, vg->name);
 
-		lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state);
+		if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state))
+			return_0;
 
 		/*
 		 * FIXME Sleeping after testing, while preferred, also works around
@@ -225,7 +226,11 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 out:
 	if (vg)
 		unlock_and_release_vg(cmd, vg, vg->name);
-	lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state);
+	if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state)) {
+		stack;
+		ret = 0;
+	}
+
 	return ret;
 }
 
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 70826c6..849780a 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -712,7 +712,10 @@ out_ret:
 	 * for some time monitoring the progress, and we don not want
 	 * or need the lockd lock held over that.
 	 */
-	lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
+	if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+		stack;
+		r = ECMD_FAILED;
+	}
 
 	return r;
 }
@@ -762,7 +765,10 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 
 	unlock_and_release_vg(cmd, vg, vg_name);
 out:
-	lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
+	if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+		stack;
+		ret = 0;
+	}
 	free_pv_fid(pv);
 	return ret;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index fde6c36..8a85739 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1957,7 +1957,10 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 			unlock_vg(cmd, vg_name);
 endvg:
 		release_vg(vg);
-		lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
+		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+			stack;
+			ret_max = ECMD_FAILED;
+		}
 	}
 
 	/* the VG is selected if at least one LV is selected */
@@ -2438,7 +2441,10 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		unlock_vg(cmd, vg_name);
 endvg:
 		release_vg(vg);
-		lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
+		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+			stack;
+			ret_max = ECMD_FAILED;
+		}
 	}
 
 	return ret_max;
@@ -2942,7 +2948,10 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			unlock_vg(cmd, vg->name);
 endvg:
 		release_vg(vg);
-		lockd_vg(cmd, vg_name, "un", 0, &lockd_state);
+		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+			stack;
+			ret_max = ECMD_FAILED;
+		}
 
 		/* Quit early when possible. */
 		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 7aecd98..32a8a7f 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1227,7 +1227,8 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, lockstart_ARG)) {
 		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 
-		lockd_gl(cmd, "un", 0);
+		if (!lockd_gl(cmd, "un", 0))
+			return_ECMD_FAILED;
 
 		if (!start_opt || !strcmp(start_opt, "auto")) {
 			log_print_unless_silent("Starting locking.  Waiting until locks are ready...");


