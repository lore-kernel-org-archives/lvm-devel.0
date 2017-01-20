From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:16 +0000 (UTC)
Subject: master - dmeventd_thin: SIGCHLD handler
Message-ID: <20170120230416.1E89460DA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46c23dfb874ab8cebf1b335ef517095ff7bfdd81
Commit:        46c23dfb874ab8cebf1b335ef517095ff7bfdd81
Parent:        bc7a1d70d4936fd892223686388fd6fe5c8c3934
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 18 09:55:46 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:55:51 2017 +0100

dmeventd_thin: SIGCHLD handler

To improve reaction time on when child is finished,
lets handle SIGCHLD in particular thread.
Let's hope kernel will route SIGCHLD to matching thread.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   40 +++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 86a2115..bdccac6 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -55,6 +55,8 @@ struct dso_state {
 	uint64_t known_metadata_size;
 	uint64_t known_data_size;
 	unsigned fails;
+	int restore_sigset;
+	sigset_t old_sigset;
 	pid_t pid;
 	char **argv;
 	char cmd_str[1024];
@@ -542,6 +544,41 @@ out:
 		dm_task_destroy(new_dmt);
 }
 
+/* Handle SIGCHLD for a thread */
+static void _sig_child(int signum __attribute__((unused)))
+{
+	/* empty SIG_IGN */;
+}
+
+/* Setup handler for SIGCHLD when executing external command
+ * to get quick 'waitpid()' reaction
+ * It will interrupt syscall just like SIGALRM and
+ * invoke process_event().
+ */
+static void _init_thread_signals(struct dso_state *state)
+{
+	struct sigaction act = { .sa_handler = _sig_child };
+	sigset_t my_sigset;
+
+	sigemptyset(&my_sigset);
+
+	if (sigaction(SIGCHLD, &act, NULL))
+		log_warn("WARNING: Failed to set SIGCHLD action.");
+	else if (sigaddset(&my_sigset, SIGCHLD))
+		log_warn("WARNING: Failed to add SIGCHLD to set.");
+	else if (pthread_sigmask(SIG_UNBLOCK, &my_sigset, &state->old_sigset))
+		log_warn("WARNING: Failed to unblock SIGCHLD.");
+	else
+		state->restore_sigset = 1;
+}
+
+static void _restore_thread_signals(struct dso_state *state)
+{
+	if (state->restore_sigset &&
+	    pthread_sigmask(SIG_SETMASK, &state->old_sigset, NULL))
+		log_warn("WARNING: Failed to block SIGCHLD.");
+}
+
 int register_device(const char *device,
 		    const char *uuid __attribute__((unused)),
 		    int major __attribute__((unused)),
@@ -575,6 +612,7 @@ int register_device(const char *device,
 		}
 
 		dm_split_words(str, maxcmd - 1, 0, state->argv);
+		_init_thread_signals(state);
 	}
 
 	state->metadata_percent_check = CHECK_MINIMUM;
@@ -619,6 +657,8 @@ int unregister_device(const char *device,
 	if (state->pid != -1)
 		log_warn("WARNING: Cannot kill child %d!", state->pid);
 
+	_restore_thread_signals(state);
+
 	dmeventd_lvm2_exit_with_pool(state);
 	log_info("No longer monitoring thin pool %s.", device);
 


