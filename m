From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Jul 2015 18:16:52 +0000 (UTC)
Subject: master - lockd: allow nolocking and readonly options
Message-ID: <20150713181652.18E3C611F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9cfa27f9c56edad26c2830562233b48e06bb4802
Commit:        9cfa27f9c56edad26c2830562233b48e06bb4802
Parent:        c39f3026a8280bb4c62c785138302cd1475facb6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 10 17:20:22 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 13 13:15:51 2015 -0500

lockd: allow nolocking and readonly options

When --nolocking is used (by vgs, lvs, pvs):

. don't use lvmlockd at all (set use_lvmlockd to 0)
. allow lockd VGs to be read

When --readonly is used (by vgs, lvs, pvs, vgdisplay, lvdisplay,
pvdisplay, lvmdiskscan, lvscan, pvscan, vgcfgbackup):

. skip actual lvmlockd locking calls
. allow lockd VGs to be read
. check that only shared gl/vg locks are being requested
  (even though the actually locking is being skipped)
. check that no LV locks are requested, because no LVs
  should be activated or used in readonly mode
. disable using lvmetad so VGs are read from disk

It is important to note the limited commands that accept
the --nolocking and --readonly options, i.e. no commands
that change/write a VG or change/activate LVs accept these
options, only commands that read VGs.
---
 lib/locking/lvmlockd.c |   26 ++++++++++++++++++++++++++
 tools/lvmcmdline.c     |   22 +++++++++++++++++++++-
 2 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 99fc047..a0dff8a 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1346,6 +1346,14 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	if (!_use_lvmlockd)
 		return 1;
 
+	/*
+	 * Verify that when --readonly is used, no ex locks should be used.
+	 */
+	if (cmd->metadata_read_only && def_mode && !strcmp(def_mode, "ex")) {
+		log_error("Exclusive locks are not allowed with readonly option.");
+		return 0;
+	}
+
 	if (cmd->lockd_gl_disable)
 		return 1;
 
@@ -1529,6 +1537,16 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 		return 1;
 
 	/*
+	 * Verify that when --readonly is used, no ex locks should be used.
+	 */
+	if (cmd->metadata_read_only &&
+	    ((def_mode && !strcmp(def_mode, "ex")) ||
+	     (!def_mode && !cmd->lockd_vg_default_sh))) {
+		log_error("Exclusive locks are not allowed with readonly option.");
+		return 0;
+	}
+
+	/*
 	 * Some special cases need to disable the vg lock.
 	 */
 	if (cmd->lockd_vg_disable)
@@ -1799,6 +1817,14 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 	int refreshed = 0;
 	int result;
 
+	/*
+	 * Verify that when --readonly is used, no LVs should be activated or used.
+	 */
+	if (cmd->metadata_read_only) {
+		log_error("LV locks are not allowed with readonly option.");
+		return 0;
+	}
+
 	if (cmd->lockd_lv_disable)
 		return 1;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c4a78b0..6dbc189 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1435,6 +1435,14 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 	const char *lvmlockd_socket;
 	int use_lvmlockd = find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL);
 
+	if (use_lvmlockd && arg_count(cmd, nolocking_ARG)) {
+		/* --nolocking is only allowed with vgs/lvs/pvs commands */
+		cmd->lockd_gl_disable = 1;
+		cmd->lockd_vg_disable = 1;
+		cmd->lockd_lv_disable = 1;
+		return 1;
+	}
+
 	if (use_lvmlockd && locking_is_clustered()) {
 		log_error("ERROR: configuration setting use_lvmlockd cannot be used with clustered locking_type 3.");
 		return 0;
@@ -1567,7 +1575,19 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (arg_count(cmd, readonly_ARG)) {
-		locking_type = 5;
+		if (find_config_tree_bool(cmd, global_use_lvmlockd_CFG, NULL)) {
+			/*
+			 * FIXME: we could use locking_type 5 here if that didn't
+			 * cause CLUSTERED to be set, which conflicts with using lvmlockd.
+			 */
+			locking_type = 1;
+			cmd->lockd_gl_disable = 1;
+			cmd->lockd_vg_disable = 1;
+			cmd->lockd_lv_disable = 1;
+		} else {
+			locking_type = 5;
+		}
+
 		if (lvmetad_used()) {
 			lvmetad_set_active(cmd, 0);
 			log_verbose("Disabling use of lvmetad because read-only is set.");


