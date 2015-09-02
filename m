From: okozina <okozina@fedoraproject.org>
Date: Wed,  2 Sep 2015 15:27:38 +0000 (UTC)
Subject: master - lvmpolld: make lvpoll error messages visible
Message-ID: <20150902152738.1B34E60D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7bbc128c3dd6e75524a4447c29ed7be2ace8e3b3
Commit:        7bbc128c3dd6e75524a4447c29ed7be2ace8e3b3
Parent:        cb57f4f89b908ad3d7149ce18204b71448c9d259
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Sep 2 16:50:14 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Sep 2 17:24:26 2015 +0200

lvmpolld: make lvpoll error messages visible

Previously all stderr messages issued by spawned lvpoll command were reported
as INFO only. This made all such messages invisible in syslog or lvmpolld log
while running default configuration.

All lvpoll stderr messages are loged with WARN priority now and lvpoll
command exiting with retcode != 0 is logged with ERROR priority in
syslog and lvmpolld log
---
 WHATS_NEW                        |    1 +
 daemons/lvmpolld/lvmpolld-core.c |   20 +++++++++++++++-----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b5e8414..48b2a07 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.130 - 
 ===================================
+  Make lvpoll error messages visible in lvmpolld's stderr and in syslog.
   Add 'make install_full_man' to install all man pages regardless of config.
 
 Version 2.02.129 - 26th August 2015
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 7d2a98b..68072d9 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -83,6 +83,12 @@ static int _init(struct daemon_state *s)
 	struct lvmpolld_state *ls = s->private;
 	ls->log = s->log;
 
+	/*
+	 * log warnings to stderr by default. Otherwise we would miss any lvpoll
+	 * error messages in default configuration
+	 */
+	daemon_log_enable(ls->log, DAEMON_LOG_OUTLET_STDERR, DAEMON_LOG_WARN,  1);
+
 	if (!daemon_log_parse(ls->log, DAEMON_LOG_OUTLET_STDERR, ls->log_config, 1))
 		return 0;
 
@@ -284,7 +290,7 @@ static int poll_for_output(struct lvmpolld_lv *pdlv, struct lvmpolld_thread_data
 				 "caught input data in STDERR");
 
 			assert(read_single_line(data, 1)); /* may block indef. anyway */
-			INFO(pdlv->ls, "%s: PID %d: %s: '%s'", LVM2_LOG_PREFIX,
+			WARN(pdlv->ls, "%s: PID %d: %s: '%s'", LVM2_LOG_PREFIX,
 			     pdlv->cmd_pid, "STDERR", data->line);
 		} else if (fds[1].revents) {
 			if (fds[1].revents & POLLHUP)
@@ -327,15 +333,19 @@ static int poll_for_output(struct lvmpolld_lv *pdlv, struct lvmpolld_thread_data
 	if (fds[1].fd >= 0)
 		while (read_single_line(data, 1)) {
 			assert(r > 0);
-			INFO(pdlv->ls, "%s: PID %d: %s: %s", LVM2_LOG_PREFIX, pdlv->cmd_pid, "STDERR", data->line);
+			WARN(pdlv->ls, "%s: PID %d: %s: %s", LVM2_LOG_PREFIX, pdlv->cmd_pid, "STDERR", data->line);
 		}
 
 	if (WIFEXITED(ch_stat)) {
-		INFO(pdlv->ls, "%s: %s (PID %d) %s (%d)", PD_LOG_PREFIX,
-		     "lvm2 cmd", pdlv->cmd_pid, "exited with", WEXITSTATUS(ch_stat));
 		cmd_state.retcode = WEXITSTATUS(ch_stat);
+		if (cmd_state.retcode)
+			ERROR(pdlv->ls, "%s: %s (PID %d) %s (retcode: %d)", PD_LOG_PREFIX,
+			     "lvm2 cmd", pdlv->cmd_pid, "failed", cmd_state.retcode);
+		else
+			INFO(pdlv->ls, "%s: %s (PID %d) %s", PD_LOG_PREFIX,
+			     "lvm2 cmd", pdlv->cmd_pid, "finished successfully");
 	} else if (WIFSIGNALED(ch_stat)) {
-		WARN(pdlv->ls, "%s: %s (PID %d) %s (%d)", PD_LOG_PREFIX,
+		ERROR(pdlv->ls, "%s: %s (PID %d) %s (%d)", PD_LOG_PREFIX,
 		     "lvm2 cmd", pdlv->cmd_pid, "got terminated by signal",
 		     WTERMSIG(ch_stat));
 		cmd_state.signal = WTERMSIG(ch_stat);


