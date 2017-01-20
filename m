From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:11 +0000 (UTC)
Subject: master - dmeventd_thin: add wait_pid
Message-ID: <20170120230411.E11BE60B39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14746a6c0025fad0d918bff7f1ee105e0eee10c3
Commit:        14746a6c0025fad0d918bff7f1ee105e0eee10c3
Parent:        2e935c0967e8bd3f97614c258619ad0c83fe0a48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 21:42:55 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:55:50 2017 +0100

dmeventd_thin: add wait_pid

Add support handling command exit.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   55 +++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 3e044ff..74b010a 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -363,6 +363,35 @@ static int _use_policy(struct dm_task *dmt, struct dso_state *state)
 	return 1;
 }
 
+/* Check if executed command has finished
+ * Only 1 command may run */
+static int _wait_for_pid(struct dso_state *state)
+{
+	int status = 0;
+
+	if (state->pid == -1)
+		return 1;
+
+	if (!waitpid(state->pid, &status, WNOHANG))
+		return 0;
+
+	/* Wait for finish */
+	if (WIFEXITED(status)) {
+		log_verbose("Child %d exited with status %d.",
+			    state->pid, WEXITSTATUS(status));
+		state->fails = WEXITSTATUS(status) ? 1 : 0;
+	} else {
+		if (WIFSIGNALED(status))
+			log_verbose("Child %d was terminated with status %d.",
+				    state->pid, WTERMSIG(status));
+		state->fails = 1;
+	}
+
+	state->pid = -1;
+
+	return 1;
+}
+
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
 		   void **user)
@@ -383,6 +412,11 @@ void process_event(struct dm_task *dmt,
 		  dm_percent_to_float(state->data_percent_check),
 		  dm_percent_to_float(state->metadata_percent_check));
 #endif
+	if (!_wait_for_pid(state)) {
+		log_warn("WARNING: Skipping event, child %d is still running (%s).",
+			 state->pid, state->cmd_str);
+		return;
+	}
 
 	if (event & DM_EVENT_DEVICE_ERROR) {
 		/* Error -> no need to check and do instant resize */
@@ -529,6 +563,7 @@ int register_device(const char *device,
 
 	state->metadata_percent_check = CHECK_MINIMUM;
 	state->data_percent_check = CHECK_MINIMUM;
+	state->pid = -1;
 	*user = state;
 
 	log_info("Monitoring thin pool %s.", device);
@@ -547,6 +582,26 @@ int unregister_device(const char *device,
 		      void **user)
 {
 	struct dso_state *state = *user;
+	int i;
+
+	for (i = 0; !_wait_for_pid(state) && (i < 6); ++i) {
+		if (i == 0)
+			/* Give it 2 seconds, then try to terminate & kill it */
+			log_verbose("Child %d still not finished (%s) waiting.",
+				    state->pid, state->cmd_str);
+		else if (i == 3) {
+			log_warn("WARNING: Terminating child %d.", state->pid);
+			kill(state->pid, SIGINT);
+			kill(state->pid, SIGTERM);
+		} else if (i == 5) {
+			log_warn("WARNING: Killing child %d.", state->pid);
+			kill(state->pid, SIGKILL);
+		}
+		sleep(1);
+	}
+
+	if (state->pid != -1)
+		log_warn("WARNING: Cannot kill child %d!", state->pid);
 
 	dmeventd_lvm2_exit_with_pool(state);
 	log_info("No longer monitoring thin pool %s.", device);


