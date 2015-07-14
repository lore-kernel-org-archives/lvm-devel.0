From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Jul 2015 19:40:15 +0000 (UTC)
Subject: master - vgchange: fix lock-start filtering and waiting
Message-ID: <20150714194015.82F8B6096D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ab6bdce01d7780a9c8f7194bc488032dbf3348f
Commit:        9ab6bdce01d7780a9c8f7194bc488032dbf3348f
Parent:        681f779a3cb711c32663e594242a3b28a64e9f27
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 14 14:30:01 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 14 14:39:34 2015 -0500

vgchange: fix lock-start filtering and waiting

Both lock_start filters were being skipped when any lock-opt
values were used.  The "auto" lock-opt should cause the
auto_lock_start_list to be used.  The lock_start_list should
always be used.

The behavior of lock_start_list/auto_lock_start_list are tested
and verified to behave like volume_list/auto_activation_volume_list.

Since the default was changed to wait for lock-start to finish,
the "wait" and "autowait" lock-opt values are not needed, but a
new "autonowait" is added to the existing "nowait" avoid the
default waiting.
---
 tools/vgchange.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 0ed8fec..72a5c1e 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -834,10 +834,17 @@ static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg
 	const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 	int auto_opt = 0;
 
-	if (!start_opt || arg_is_set(cmd, force_ARG))
+	if (!is_lockd_type(vg->lock_type))
+		return 1;
+
+	if (arg_is_set(cmd, force_ARG))
 		goto do_start;
 
-	if (!strcmp(start_opt, "auto") || !strcmp(start_opt, "autowait"))
+	/*
+	 * Recognize both "auto" and "autonowait" options.
+	 * Any waiting is done at the end of vgchange.
+	 */
+	if (start_opt && !strncmp(start_opt, "auto", 4))
 		auto_opt = 1;
 
 	if (!_passes_lock_start_filter(cmd, vg, activation_lock_start_list_CFG)) {
@@ -1201,12 +1208,12 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 		lockd_gl(cmd, "un", 0);
 
-		if (!start_opt || !strcmp(start_opt, "wait") || !strcmp(start_opt, "autowait")) {
+		if (!start_opt || !strcmp(start_opt, "auto")) {
 			log_print_unless_silent("Starting locking.  Waiting until locks are ready...");
 			lockd_start_wait(cmd);
 
-		} else if (!strcmp(start_opt, "nowait")) {
-			log_print_unless_silent("Starting locking.  VG is read-only until locks are ready.");
+		} else if (!strcmp(start_opt, "nowait") || !strcmp(start_opt, "autonowait")) {
+			log_print_unless_silent("Starting locking.  VG can only be read until locks are ready.");
 		}
 	}
 


