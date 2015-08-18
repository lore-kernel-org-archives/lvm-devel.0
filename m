From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 18 Aug 2015 16:20:00 +0000 (UTC)
Subject: master - lockd: no error when unlock fails
Message-ID: <20150818162000.90014602F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b570840cd5c503ff55a446e211ac30bb09ef3fd
Commit:        7b570840cd5c503ff55a446e211ac30bb09ef3fd
Parent:        c1bd76d6fcbbc7c07c99a5738dea99f830f79810
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 18 10:39:40 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 18 11:18:40 2015 -0500

lockd: no error when unlock fails

The unlock call will fail in expected and normal cases,
and should not cause the command to fail.  (An actual
unlock in the lock manager should never fail.)
---
 tools/lvconvert.c  |    4 +---
 tools/polldaemon.c |    6 ++----
 tools/pvmove.c     |    8 ++------
 tools/toollib.c    |   12 +++---------
 tools/vgchange.c   |    2 +-
 5 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 37ae197..95996b7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3450,10 +3450,8 @@ bad:
 	unlock_vg(cmd, lp->vg_name);
 
 	/* Unlock here so it's not held during polling. */
-	if (!lockd_vg(cmd, lp->vg_name, "un", 0, &lockd_state)) {
+	if (!lockd_vg(cmd, lp->vg_name, "un", 0, &lockd_state))
 		stack;
-		ret = ECMD_FAILED;
-	}
 
 	release_vg(vg);
 out:
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index c7f6795..cee1983 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -203,7 +203,7 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 		unlock_and_release_vg(cmd, vg, vg->name);
 
 		if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state))
-			return_0;
+			stack;
 
 		/*
 		 * FIXME Sleeping after testing, while preferred, also works around
@@ -226,10 +226,8 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 out:
 	if (vg)
 		unlock_and_release_vg(cmd, vg, vg->name);
-	if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state)) {
+	if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state))
 		stack;
-		ret = 0;
-	}
 
 	return ret;
 }
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 849780a..0e31764 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -712,10 +712,8 @@ out_ret:
 	 * for some time monitoring the progress, and we don not want
 	 * or need the lockd lock held over that.
 	 */
-	if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+	if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
 		stack;
-		r = ECMD_FAILED;
-	}
 
 	return r;
 }
@@ -765,10 +763,8 @@ static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_nam
 
 	unlock_and_release_vg(cmd, vg, vg_name);
 out:
-	if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+	if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
 		stack;
-		ret = 0;
-	}
 	free_pv_fid(pv);
 	return ret;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index 8a85739..01146a4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1957,10 +1957,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 			unlock_vg(cmd, vg_name);
 endvg:
 		release_vg(vg);
-		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
 			stack;
-			ret_max = ECMD_FAILED;
-		}
 	}
 
 	/* the VG is selected if at least one LV is selected */
@@ -2441,10 +2439,8 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		unlock_vg(cmd, vg_name);
 endvg:
 		release_vg(vg);
-		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
 			stack;
-			ret_max = ECMD_FAILED;
-		}
 	}
 
 	return ret_max;
@@ -2948,10 +2944,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			unlock_vg(cmd, vg->name);
 endvg:
 		release_vg(vg);
-		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state)) {
+		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
 			stack;
-			ret_max = ECMD_FAILED;
-		}
 
 		/* Quit early when possible. */
 		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 32a8a7f..cbdc29a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1228,7 +1228,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 
 		if (!lockd_gl(cmd, "un", 0))
-			return_ECMD_FAILED;
+			stack;
 
 		if (!start_opt || !strcmp(start_opt, "auto")) {
 			log_print_unless_silent("Starting locking.  Waiting until locks are ready...");


