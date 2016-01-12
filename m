From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 Jan 2016 10:42:48 +0000 (UTC)
Subject: master - pvscan: restore polling in autoactivation handler
Message-ID: <20160112104248.E2E3760B3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40701af9696a302c904fad30951385eb5a5adb85
Commit:        40701af9696a302c904fad30951385eb5a5adb85
Parent:        d6cf83968cb0d397faec30ce54839a679e89dd14
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu Jan 7 15:17:08 2016 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Jan 12 11:40:43 2016 +0100

pvscan: restore polling in autoactivation handler

This commit fixes regression in auto-activation code introduced
in commit: c26d81d6e6939906729d91fae83cd8bbdd743bb7.

- resolves rhbz1295562
---
 WHATS_NEW        |    1 +
 tools/pvscan.c   |    9 +++++++++
 tools/tools.h    |    2 ++
 tools/vgchange.c |    4 ++--
 4 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f316054..93e0dd5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.140 -
 ===================================
+  Restore background polling processing during auto-activation (2.02.119).
   Use brackets to signify LVs which are not visible when reporting lv_parent.
   Fix invalid memory read when reporting cache LV policy_name (2.02.126).
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 68a074e..e9fb5d5 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -190,6 +190,15 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 		goto out;
 	}
 
+	/*
+	 * After sucessfull activation we need to initialise polling
+	 * for all activated LVs in a VG. Possible enhancement would
+	 * be adding --poll y|n cmdline option for pvscan and call
+	 * init_background_polling routine in autoactivation handler.
+	 */
+	if (!(vgchange_background_polling(vg->cmd, vg)))
+		goto_out;
+
 	r = 1;
 
 out:
diff --git a/tools/tools.h b/tools/tools.h
index 4179cc8..47dd35e 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -185,4 +185,6 @@ int mirror_remove_missing(struct cmd_context *cmd,
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		       activation_change_t activate);
 
+int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg);
+
 #endif
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 9e1b09e..3aea8a4 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -174,7 +174,7 @@ static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg
 	return r;
 }
 
-static int _vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg)
+int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg)
 {
 	int polled;
 
@@ -999,7 +999,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 
 	if (!arg_count(cmd, refresh_ARG) &&
 	    background_polling())
-		if (!_vgchange_background_polling(cmd, vg))
+		if (!vgchange_background_polling(cmd, vg))
 			return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, lockstart_ARG)) {


