From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 May 2011 08:45:47 -0000
Subject: LVM2/daemons/common daemon-server.h daemon-ser ...
Message-ID: <20110513084547.4622.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-13 08:45:47

Modified files:
	daemons/common : daemon-server.h 
Added files:
	daemons/common : daemon-server.c 

Log message:
	Start filling in some of the common daemon (server-side) functionality, taking
	dmeventd code as a starting point.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-server.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

/cvs/lvm2/LVM2/daemons/common/daemon-server.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/common/daemon-server.c
+++ -	2011-05-13 08:45:47.525615000 +0000
@@ -0,0 +1,204 @@
+/*
+ * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <dlfcn.h>
+#include <errno.h>
+#include <pthread.h>
+#include <sys/file.h>
+#include <sys/stat.h>
+#include <sys/wait.h>
+#include <sys/time.h>
+#include <sys/resource.h>
+#include <unistd.h>
+#include <signal.h>
+
+#include <syslog.h>
+
+/* Create a device monitoring thread. */
+static int _pthread_create(pthread_t *t, void *(*fun)(void *), void *arg, int stacksize)
+{
+	pthread_attr_t attr;
+	pthread_attr_init(&attr);
+	/*
+	 * We use a smaller stack since it gets preallocated in its entirety
+	 */
+	pthread_attr_setstacksize(&attr, stacksize);
+	return pthread_create(t, &attr, fun, arg);
+}
+
+static volatile sig_atomic_t _shutdown_requested = 0;
+
+static void _exit_handler(int sig __attribute__((unused)))
+{
+	_shutdown_requested = 1;
+}
+
+#ifdef linux
+#  define OOM_ADJ_FILE "/proc/self/oom_adj"
+
+/* From linux/oom.h */
+#  define OOM_DISABLE (-17)
+#  define OOM_ADJUST_MIN (-16)
+
+/*
+ * Protection against OOM killer if kernel supports it
+ */
+static int _set_oom_adj(int val)
+{
+	FILE *fp;
+
+	struct stat st;
+
+	if (stat(OOM_ADJ_FILE, &st) == -1) {
+		if (errno == ENOENT)
+			perror(OOM_ADJ_FILE " not found");
+		else
+			perror(OOM_ADJ_FILE ": stat failed");
+		return 1;
+	}
+
+	if (!(fp = fopen(OOM_ADJ_FILE, "w"))) {
+		perror(OOM_ADJ_FILE ": fopen failed");
+		return 0;
+	}
+
+	fprintf(fp, "%i", val);
+	if (dm_fclose(fp))
+		perror(OOM_ADJ_FILE ": fclose failed");
+
+	return 1;
+}
+#endif
+
+static void remove_lockfile(const char *file)
+{
+	if (unlink(file))
+		perror(file ": unlink failed");
+}
+
+static void _daemonise(void)
+{
+	int child_status;
+	int fd;
+	pid_t pid;
+	struct rlimit rlim;
+	struct timeval tval;
+	sigset_t my_sigset;
+
+	sigemptyset(&my_sigset);
+	if (sigprocmask(SIG_SETMASK, &my_sigset, NULL) < 0) {
+		fprintf(stderr, "Unable to restore signals.\n");
+		exit(EXIT_FAILURE);
+	}
+	signal(SIGTERM, &_exit_handler);
+
+	switch (pid = fork()) {
+	case -1:
+		perror("fork failed:");
+		exit(EXIT_FAILURE);
+
+	case 0:		/* Child */
+		break;
+
+	default:
+		/* Wait for response from child */
+		while (!waitpid(pid, &child_status, WNOHANG) && !_exit_now) {
+			tval.tv_sec = 0;
+			tval.tv_usec = 250000;	/* .25 sec */
+			select(0, NULL, NULL, NULL, &tval);
+		}
+
+		if (_shutdown_requested) /* Child has signaled it is ok - we can exit now */
+			exit(0);
+
+		/* Problem with child.  Determine what it is by exit code */
+		switch (WEXITSTATUS(child_status)) {
+		case EXIT_DESC_CLOSE_FAILURE:
+		case EXIT_DESC_OPEN_FAILURE:
+		case EXIT_FIFO_FAILURE:
+		case EXIT_CHDIR_FAILURE:
+		default:
+			fprintf(stderr, "Child exited with code %d\n", WEXITSTATUS(child_status));
+			break;
+		}
+
+		exit(WEXITSTATUS(child_status));
+	}
+
+	if (chdir("/"))
+		exit(1);
+
+	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0)
+		fd = 256; /* just have to guess */
+	else
+		fd = rlim.rlim_cur;
+
+	for (--fd; fd >= 0; fd--)
+		close(fd);
+
+	if ((open("/dev/null", O_RDONLY) < 0) ||
+	    (open("/dev/null", O_WRONLY) < 0) ||
+	    (open("/dev/null", O_WRONLY) < 0))
+		exit(1);
+
+	setsid();
+}
+
+void daemon_start(daemon_state s, handle_request r)
+{
+	/*
+	 * Switch to C locale to avoid reading large locale-archive file used by
+	 * some glibc (on some distributions it takes over 100MB). Some daemons
+	 * need to use mlockall().
+	 */
+	if (setenv("LANG", "C", 1))
+		perror("Cannot set LANG to C");
+
+	if (!s.foreground)
+		_daemonise();
+
+	/* TODO logging interface should be somewhat more elaborate */
+	openlog(s.name, LOG_PID, LOG_DAEMON);
+
+	(void) dm_prepare_selinux_context(s.pidfile, S_IFREG);
+
+	/*
+	 * NB. Past this point, exit is not allowed. You have to return to this
+	 * function at all costs. More or less.
+	 */
+	if (dm_create_lockfile(s.pidfile) == 0)
+		exit(1);
+
+	(void) dm_prepare_selinux_context(NULL, 0);
+
+	/* Set normal exit signals to request shutdown instead of dying. */
+	signal(SIGINT, &_exit_handler);
+	signal(SIGHUP, &_exit_handler);
+	signal(SIGQUIT, &_exit_handler);
+
+#ifdef linux
+	if (s.avoid_oom && !_set_oom_adj(OOM_DISABLE) && !_set_oom_adj(OOM_ADJUST_MIN))
+		syslog(LOG_ERR, "Failed to set oom_adj to protect against OOM killer");
+#endif
+
+	/* Signal parent, letting them know we are ready to go. */
+	if (!s.foreground)
+		kill(getppid(), SIGTERM);
+
+	while (!_shutdown_requested) {
+		/* TODO: do work */
+	}
+
+	syslog(LOG_NOTICE, "%s shutting down", s.name);
+	closelog();
+	remove_lockfile(s.pidfile);
+}
--- LVM2/daemons/common/daemon-server.h	2011/05/13 08:07:28	1.1
+++ LVM2/daemons/common/daemon-server.h	2011/05/13 08:45:46	1.2
@@ -23,6 +23,19 @@
 } client_handle;
 
 typedef struct {
+	/*
+	 * The maximal stack size for individual daemon threads. This is
+	 * essential for daemons that need to be locked into memory, since
+	 * pthread's default is 10M per thread.
+	 */
+	int thread_stack_size;
+
+	/* Flags & attributes affecting the behaviour of the daemon. */
+	unsigned avoid_oom:1;
+	unsigned foreground:1;
+	const char *name;
+	const char *pidfile;
+
 	void *private; /* the global daemon state */
 } daemon_state;
 
@@ -45,7 +58,8 @@
 
 /*
  * Start serving the requests. This does all the daemonisation, socket setup
- * work and so on.
+ * work and so on. This function takes over the process, and upon failure, it
+ * will terminate execution. It may be called@most once.
  */
 void daemon_start(daemon_state s, handle_request r);
 


