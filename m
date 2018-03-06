From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:45:38 -0500
Subject: master - thin: pass environment to scripts
Message-ID: <201803061445.w26EjcuF026590@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9be086fbeef0a24fc6f441dec29ee2385bca0280
Commit:        9be086fbeef0a24fc6f441dec29ee2385bca0280
Parent:        406d6de651fd1ae3bda80f3597d7aa8733b0389a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 5 15:09:16 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:35:04 2018 +0100

thin: pass environment to scripts

When dmeventd thin plugin forks a configurable script, switch to use
execvp to pass whole environment present to dmeventd - so all configured
paths present at dmeventd startup are visible to script.

This was likely not a problem for common user enviroment,
however in test suite case variable like LVM_SYSTEM_DIR were
not actually used from test itself but rather from
a system present lvm.conf and this may have cause strange
behavior of a testing script.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   18 +++++++++---------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 52593c5..5c1f4a1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.147 - 
 =====================================
+  Configured command for thin pool threshold handling gets whole environment.
   Fix tests for failing dm_snprintf() in stats code.
   Parsing mirror status accepts 'userspace' keyword in status.
   Introduce dm_malloc_aligned for page alignment of buffers.
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 404519b..29b0391 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -64,23 +64,23 @@ DM_EVENT_LOG_FN("thin")
 
 static int _run_command(struct dso_state *state)
 {
-	char val[3][36];
-	char *env[] = { val[0], val[1], val[2], NULL };
+	char val[16];
 	int i;
 
 	/* Mark for possible lvm2 command we are running from dmeventd
 	 * lvm2 will not try to talk back to dmeventd while processing it */
-	(void) dm_snprintf(val[0], sizeof(val[0]), "LVM_RUN_BY_DMEVENTD=1");
+	(void) setenv("LVM_RUN_BY_DMEVENTD", "1", 1);
 
 	if (state->data_percent) {
 		/* Prepare some known data to env vars for easy use */
-		(void) dm_snprintf(val[1], sizeof(val[1]), "DMEVENTD_THIN_POOL_DATA=%d",
-				   state->data_percent / DM_PERCENT_1);
-		(void) dm_snprintf(val[2], sizeof(val[2]), "DMEVENTD_THIN_POOL_METADATA=%d",
-				   state->metadata_percent / DM_PERCENT_1);
+		if (dm_snprintf(val, sizeof(val), "%d",
+				state->data_percent / DM_PERCENT_1) != -1)
+			(void) setenv("DMEVENTD_THIN_POOL_DATA", val, 1);
+		if (dm_snprintf(val, sizeof(val), "%d",
+				state->metadata_percent / DM_PERCENT_1) != -1)
+			(void) setenv("DMEVENTD_THIN_POOL_METADATA", val, 1);
 	} else {
 		/* For an error event it's for a user to check status and decide */
-		env[1] = NULL;
 		log_debug("Error event processing.");
 	}
 
@@ -95,7 +95,7 @@ static int _run_command(struct dso_state *state)
 		/* child */
 		(void) close(0);
 		for (i = 3; i < 255; ++i) (void) close(i);
-		execve(state->argv[0], state->argv, env);
+		execvp(state->argv[0], state->argv);
 		_exit(errno);
 	} else if (state->pid == -1) {
 		log_error("Can't fork command %s.", state->cmd_str);


