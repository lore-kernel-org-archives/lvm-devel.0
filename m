From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 11 Jan 2010 19:19:17 -0000
Subject: LVM2/tools lvm2cmdline.h lvmcmdline.c polldaemon.c
Message-ID: <20100111191917.6434.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-11 19:19:17

Modified files:
	tools          : lvm2cmdline.h lvmcmdline.c polldaemon.c 

Log message:
	Only allow one return from poll_daemon().  If a child polldaemon was
	successfully created it must _exit() once it completes.
	
	Update _become_daemon() to differentiate between a failed fork() and a
	successful fork().
	
	Added lvm_return_code() to lvmcmdline.[ch]

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmdline.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/tools/lvm2cmdline.h	2008/12/19 18:51:02	1.8
+++ LVM2/tools/lvm2cmdline.h	2010/01/11 19:19:17	1.9
@@ -35,6 +35,7 @@
 void lvm_register_commands(void);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
+int lvm_return_code(int ret);
 int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline);
 
 #endif
--- LVM2/tools/lvmcmdline.c	2010/01/11 15:40:04	1.110
+++ LVM2/tools/lvmcmdline.c	2010/01/11 19:19:17	1.111
@@ -1070,6 +1070,11 @@
 	return ret;
 }
 
+int lvm_return_code(int ret)
+{
+	return (ret == ECMD_PROCESSED ? 0 : ret);
+}
+
 int lvm_split(char *str, int *argc, char **argv, int max)
 {
 	char *b = str, *e;
@@ -1389,7 +1394,5 @@
 
       out:
 	lvm_fin(cmd);
-	if (ret == ECMD_PROCESSED)
-		ret = 0;
-	return ret;
+	return lvm_return_code(ret);
 }
--- LVM2/tools/polldaemon.c	2010/01/08 21:53:08	1.30
+++ LVM2/tools/polldaemon.c	2010/01/11 19:19:17	1.31
@@ -15,6 +15,7 @@
 
 #include "tools.h"
 #include "polldaemon.h"
+#include "lvm2cmdline.h"
 #include <signal.h>
 #include <sys/wait.h>
 
@@ -23,6 +24,12 @@
 	while (wait4(-1, NULL, WNOHANG | WUNTRACED, NULL) > 0) ;
 }
 
+/*
+ * returns:
+ * -1 if the fork failed
+ *  0 if the parent
+ *  1 if the child
+ */
 static int _become_daemon(struct cmd_context *cmd)
 {
 	pid_t pid;
@@ -37,7 +44,7 @@
 
 	if ((pid = fork()) == -1) {
 		log_error("fork failed: %s", strerror(errno));
-		return 1;
+		return -1;
 	}
 
 	/* Parent */
@@ -232,12 +239,20 @@
 	}
 }
 
+/*
+ * Only allow *one* return from poll_daemon() (the parent).
+ * If there is a child it must exit (ignoring the memory leak messages).
+ * - 'background' is advisory so a child polldaemon may not be used even
+ *   if it was requested.
+ */
 int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		unsigned background,
 		uint32_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title)
 {
 	struct daemon_parms parms;
+	int daemon_mode = 0;
+	int ret = ECMD_PROCESSED;
 
 	parms.aborting = arg_is_set(cmd, abort_ARG);
 	parms.background = background;
@@ -260,9 +275,11 @@
 	}
 
 	if (parms.background) {
-		if (!_become_daemon(cmd))
-			return ECMD_PROCESSED;	/* Parent */
-		parms.progress_display = 0;
+		daemon_mode = _become_daemon(cmd);
+		if (daemon_mode == 0)
+			return ECMD_PROCESSED;	    /* Parent */
+		else if (daemon_mode == 1)
+			parms.progress_display = 0; /* Child */
 		/* FIXME Use wait_event (i.e. interval = 0) and */
 		/*       fork one daemon per copy? */
 	}
@@ -273,10 +290,21 @@
 	if (name) {
 		if (!_wait_for_single_lv(cmd, name, uuid, &parms)) {
 			stack;
-			return ECMD_FAILED;
+			ret = ECMD_FAILED;
 		}
 	} else
 		_poll_for_all_vgs(cmd, &parms);
 
-	return ECMD_PROCESSED;
+	if (parms.background && daemon_mode == 1) {
+		/*
+		 * child was successfully forked:
+		 * background polldaemon must not return to the caller
+		 * because it will redundantly continue performing the
+		 * caller's task (that the parent already performed)
+		 */
+		/* FIXME Attempt proper cleanup */
+		_exit(lvm_return_code(ret));
+	}
+
+	return ret;
 }


