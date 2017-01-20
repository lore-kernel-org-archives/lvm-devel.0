From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:09 +0000 (UTC)
Subject: master - dmeventd_thin: add run_command
Message-ID: <20170120230409.D021B60D7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e935c0967e8bd3f97614c258619ad0c83fe0a48
Commit:        2e935c0967e8bd3f97614c258619ad0c83fe0a48
Parent:        e5bef508275f7d9889062f8e15e39aa63a9a938e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 21:41:23 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:55:50 2017 +0100

dmeventd_thin: add run_command

Implement forking of executable command.
When command is forked, dmeventd may continue monitor device.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   53 +++++++++++++++++++++++--
 1 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index b436524..3e044ff 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -55,6 +55,8 @@ struct dso_state {
 	uint64_t known_metadata_size;
 	uint64_t known_data_size;
 	unsigned fails;
+	pid_t pid;
+	char **argv;
 	char cmd_str[1024];
 };
 
@@ -302,19 +304,62 @@ out:
 		dm_bitset_destroy(data.minors);
 }
 
+static int _run_command(struct dso_state *state)
+{
+	char val[2][36];
+	char *env[] = { val[0], val[1], NULL };
+	int i;
+
+	if (state->data_percent) {
+		/* Prepare some known data to env vars for easy use */
+		(void) dm_snprintf(val[0], sizeof(val[0]), "DMEVENTD_THIN_POOL_DATA=%d",
+				   state->data_percent / DM_PERCENT_1);
+		(void) dm_snprintf(val[1], sizeof(val[1]), "DMEVENTD_THIN_POOL_METADATA=%d",
+				   state->metadata_percent / DM_PERCENT_1);
+	} else {
+		/* For an error event it's for a user to check status and decide */
+		env[0] = NULL;
+		log_debug("Error event processing");
+	}
+
+	log_verbose("Executing command: %s", state->cmd_str);
+
+	/* TODO:
+	 *   Support parallel run of 'task' and it's waitpid maintainence
+	 *   ATM we can't handle signaling of  SIGALRM
+	 *   as signalling is not allowed while 'process_event()' is running
+	 */
+	if (!(state->pid = fork())) {
+		/* child */
+		(void) close(0);
+		for (i = 3; i < 255; ++i) (void) close(i);
+		execve(state->argv[0], state->argv, env);
+		_exit(errno);
+	} else if (state->pid == -1) {
+		log_error("Can't fork command %s.", state->cmd_str);
+		state->fails = 1;
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _use_policy(struct dm_task *dmt, struct dso_state *state)
 {
 #if THIN_DEBUG
 	log_debug("dmeventd executes: %s.", state->cmd_str);
 #endif
+	if (state->argv)
+		return _run_command(state);
+
 	if (!dmeventd_lvm2_run_with_lock(state->cmd_str)) {
-		log_error("Failed to extend thin pool %s.",
-			  dm_task_get_name(dmt));
-		state->fails++;
+		log_error("Failed command for %s.", dm_task_get_name(dmt));
+		state->fails = 1;
 		return 0;
 	}
 
 	state->fails = 0;
+
 	return 1;
 }
 


