From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:14:45 +0000 (UTC)
Subject: master - dmeventd: limit thin_command usage
Message-ID: <20170213091445.8CED760DF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa0c735e2ccbea969bad846f3e89c91a81d88fbf
Commit:        aa0c735e2ccbea969bad846f3e89c91a81d88fbf
Parent:        416f9512830ff81e32852f2fce0ee7e36fcdb50f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 22:07:23 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 09:43:53 2017 +0100

dmeventd: limit thin_command usage

Require usable command string to begining with '/'
So 'thin_command = "/some/path/command"' is the only supported variant
to internal 'lvm' command.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   47 +++++++++++++++---------
 1 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index cf57d20..e447ba2 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -58,8 +58,8 @@ struct dso_state {
 	int restore_sigset;
 	sigset_t old_sigset;
 	pid_t pid;
-	char **argv;
-	char cmd_str[1024];
+	char *argv[3];
+	char *cmd_str;
 };
 
 DM_EVENT_LOG_FN("thin")
@@ -85,7 +85,7 @@ static int _run_command(struct dso_state *state)
 	} else {
 		/* For an error event it's for a user to check status and decide */
 		env[1] = NULL;
-		log_debug("Error event processing");
+		log_debug("Error event processing.");
 	}
 
 	log_verbose("Executing command: %s", state->cmd_str);
@@ -115,7 +115,7 @@ static int _use_policy(struct dm_task *dmt, struct dso_state *state)
 #if THIN_DEBUG
 	log_debug("dmeventd executes: %s.", state->cmd_str);
 #endif
-	if (state->argv)
+	if (state->argv[0])
 		return _run_command(state);
 
 	if (!dmeventd_lvm2_run_with_lock(state->cmd_str)) {
@@ -352,34 +352,43 @@ int register_device(const char *device,
 		    void **user)
 {
 	struct dso_state *state;
-	int maxcmd;
 	char *str;
+	char cmd_str[PATH_MAX + 128 + 2]; /* cmd ' ' vg/lv \0 */
 
 	if (!dmeventd_lvm2_init_with_pool("thin_pool_state", state))
 		goto_bad;
 
-	if (!dmeventd_lvm2_command(state->mem, state->cmd_str,
-				   sizeof(state->cmd_str),
+	if (!dmeventd_lvm2_command(state->mem, cmd_str, sizeof(cmd_str),
 				   "_dmeventd_thin_command", device)) {
 		dmeventd_lvm2_exit_with_pool(state);
 		goto_bad;
 	}
 
-	if (strncmp(state->cmd_str, "lvm ", 4)) {
-		maxcmd = 2; /* space for last NULL element */
-		for (str = state->cmd_str; *str; str++)
-			if (*str == ' ')
-				maxcmd++;
-		if (!(str = dm_pool_strdup(state->mem, state->cmd_str)) ||
-		    !(state->argv = dm_pool_zalloc(state->mem, maxcmd * sizeof(char *)))) {
-			log_error("Failed to allocate memory for command.");
+	if (strncmp(cmd_str, "lvm ", 4) == 0) {
+		if (!(state->cmd_str = dm_pool_strdup(state->mem, cmd_str + 4))) {
+			log_error("Failed to copy lvm command.");
+			goto bad;
+		}
+	} else if (cmd_str[0] == '/') {
+		if (!(state->cmd_str = dm_pool_strdup(state->mem, cmd_str))) {
+			log_error("Failed to copy thin command.");
 			goto bad;
 		}
 
-		dm_split_words(str, maxcmd - 1, 0, state->argv);
+		/* Find last space before 'vg/lv' */
+		if (!(str = strrchr(state->cmd_str, ' ')))
+			goto inval;
+
+		if (!(state->argv[0] = dm_pool_strndup(state->mem, state->cmd_str,
+						       str - state->cmd_str))) {
+			log_error("Failed to copy command.");
+			goto bad;
+		}
+
+		state->argv[1] = str + 1;  /* 1 argument - vg/lv */
 		_init_thread_signals(state);
-	} else
-		memmove(state->cmd_str, state->cmd_str + 4, strlen(state->cmd_str + 4) + 1);
+	} else /* Unuspported command format */
+		goto inval;
 
 	state->pid = -1;
 	*user = state;
@@ -387,6 +396,8 @@ int register_device(const char *device,
 	log_info("Monitoring thin pool %s.", device);
 
 	return 1;
+inval:
+	log_error("Invalid command for monitoring: %s.", cmd_str);
 bad:
 	log_error("Failed to monitor thin pool %s.", device);
 


