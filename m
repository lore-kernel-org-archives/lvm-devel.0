From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Sep 2009 17:36:50 -0000
Subject: LVM2/daemons Makefile.in cmirrord/Makefile.in ...
Message-ID: <20090902173650.31154.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-02 17:36:46

Modified files:
	daemons        : Makefile.in 
Added files:
	daemons/cmirrord: Makefile.in clogd.c cluster.c cluster.h 
	                  common.h functions.c functions.h link_mon.c 
	                  link_mon.h local.c local.h logging.c logging.h 
Removed files:
	daemons/clogd  : Makefile.in clogd.c cluster.c cluster.h 
	                 common.h functions.c functions.h link_mon.c 
	                 link_mon.h local.c local.h logging.c logging.h 

Log message:
	rename clogd dir to cmirrord

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/clogd.c.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=1.8&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.h.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/common.h.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.9&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.h.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/link_mon.c.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/link_mon.h.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.c.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.h.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.c.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.h.diff?cvsroot=lvm2&r1=1.4&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/common.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/link_mon.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/link_mon.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/local.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/logging.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/logging.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/daemons/Makefile.in	2009/09/02 11:49:03	1.10
+++ LVM2/daemons/Makefile.in	2009/09/02 17:36:46	1.11
@@ -15,14 +15,14 @@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
-.PHONY: dmeventd clvmd
+.PHONY: dmeventd clvmd cmirrord
 
 ifneq ("@CLVMD@", "none")
   SUBDIRS = clvmd
 endif
 
 ifeq ("@BUILD_CMIRRORD@", "yes")
-  SUBDIRS += clogd
+  SUBDIRS += cmirrord
 endif
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
/cvs/lvm2/LVM2/daemons/cmirrord/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/Makefile.in
+++ -	2009-09-02 17:36:49.435229000 +0000
@@ -0,0 +1,33 @@
+#
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+VPATH = @srcdir@
+
+SOURCES = clogd.c cluster.c functions.c link_mon.c local.c logging.c
+
+TARGETS = cmirrord
+
+include $(top_srcdir)/make.tmpl
+
+LDFLAGS += -L$(usrlibdir)/openais
+LIBS += -lcpg -lSaCkpt -ldevmapper
+
+cmirrord: $(OBJECTS) $(top_srcdir)/lib/liblvm-internal.a
+	$(CC) -o cmirrord $(OBJECTS) $(CFLAGS) $(LDFLAGS) \
+		$(LVMLIBS) $(LMLIBS) $(LIBS)
+
+install: $(TARGETS)
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) cmirrord \
+		$(usrsbindir)/cmirrord
/cvs/lvm2/LVM2/daemons/cmirrord/clogd.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/clogd.c
+++ -	2009-09-02 17:36:49.603897000 +0000
@@ -0,0 +1,276 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <string.h>
+#include <errno.h>
+#include <sched.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/stat.h>
+#include <signal.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <linux/types.h>
+#include <sys/socket.h>
+#include <linux/netlink.h>
+#include <linux/dm-ioctl.h>
+
+#include "dm-log-userspace.h"
+#include "functions.h"
+#include "local.h"
+#include "cluster.h"
+#include "common.h"
+#include "logging.h"
+#include "link_mon.h"
+
+static int exit_now = 0;
+static sigset_t signal_mask;
+static int signal_received;
+
+static void process_signals(void);
+static void daemonize(void);
+static void init_all(void);
+static void cleanup_all(void);
+
+int main(int argc, char *argv[])
+{
+	daemonize();
+
+	init_all();
+
+	/* Parent can now exit, we're ready to handle requests */
+	kill(getppid(), SIGTERM);
+
+	LOG_PRINT("Starting cmirrord:");
+	LOG_PRINT(" Built: "__DATE__" "__TIME__"\n");
+	LOG_DBG(" Compiled with debugging.");
+
+	while (!exit_now) {
+		links_monitor();
+
+		links_issue_callbacks();
+
+		process_signals();
+	}
+	exit(EXIT_SUCCESS);
+}
+
+/*
+ * parent_exit_handler: exit the parent
+ * @sig: the signal
+ *
+ */
+static void parent_exit_handler(int sig)
+{
+	exit_now = 1;
+}
+
+/*
+ * create_lockfile - create and lock a lock file
+ * @lockfile: location of lock file
+ *
+ * Returns: 0 on success, -1 otherwise
+ */
+static int create_lockfile(char *lockfile)
+{
+	int fd;
+	struct flock lock;
+	char buffer[50];
+
+	if((fd = open(lockfile, O_CREAT | O_WRONLY,
+		      (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH))) < 0)
+		return -errno;
+
+	lock.l_type = F_WRLCK;
+	lock.l_start = 0;
+	lock.l_whence = SEEK_SET;
+	lock.l_len = 0;
+
+	if (fcntl(fd, F_SETLK, &lock) < 0) {
+		close(fd);
+		return -errno;
+	}
+
+	if (ftruncate(fd, 0) < 0) {
+		close(fd);
+		return -errno;
+	}
+
+	sprintf(buffer, "%d\n", getpid());
+
+	if(write(fd, buffer, strlen(buffer)) < strlen(buffer)){
+		close(fd);
+		unlink(lockfile);
+		return -errno;
+	}
+
+	return 0;
+}
+
+static void sig_handler(int sig)
+{
+	sigaddset(&signal_mask, sig);
+	++signal_received;
+}
+
+static void process_signal(int sig){
+	int r = 0;
+
+	switch(sig) {
+	case SIGINT:
+	case SIGQUIT:
+	case SIGTERM:
+	case SIGHUP:
+		r += log_status();
+		break;
+	case SIGUSR1:
+	case SIGUSR2:
+		log_debug();
+		/*local_debug();*/
+		cluster_debug();
+		return;
+	default:
+		LOG_PRINT("Unknown signal received... ignoring");
+		return;
+	}
+
+	if (!r) {
+		LOG_DBG("No current cluster logs... safe to exit.");
+		cleanup_all();
+		exit(EXIT_SUCCESS);
+	}
+
+	LOG_ERROR("Cluster logs exist.  Refusing to exit.");
+}
+
+static void process_signals(void)
+{
+	int x;
+
+	if (!signal_received)
+		return;
+
+	signal_received = 0;
+
+	for (x = 1; x < _NSIG; x++) {
+		if (sigismember(&signal_mask, x)) {
+			sigdelset(&signal_mask, x);
+			process_signal(x);
+		}
+	}
+}
+
+/*
+ * daemonize
+ *
+ * Performs the steps necessary to become a daemon.
+ */
+static void daemonize(void)
+{
+	int pid;
+	int status;
+
+	signal(SIGTERM, &parent_exit_handler);
+
+	pid = fork();
+
+	if (pid < 0) {
+		LOG_ERROR("Unable to fork()");
+		exit(EXIT_FAILURE);
+	}
+
+	if (pid) {
+		/* Parent waits here for child to get going */
+		while (!waitpid(pid, &status, WNOHANG) && !exit_now);
+		if (exit_now)
+			exit(EXIT_SUCCESS);
+
+		switch (WEXITSTATUS(status)) {
+		case EXIT_LOCKFILE:
+			LOG_ERROR("Failed to create lockfile");
+			LOG_ERROR("Process already running?");
+			break;
+		case EXIT_KERNEL_SOCKET:
+			LOG_ERROR("Unable to create netlink socket");
+			break;
+		case EXIT_KERNEL_BIND:
+			LOG_ERROR("Unable to bind to netlink socket");
+			break;
+		case EXIT_KERNEL_SETSOCKOPT:
+			LOG_ERROR("Unable to setsockopt on netlink socket");
+			break;
+		case EXIT_CLUSTER_CKPT_INIT:
+			LOG_ERROR("Unable to initialize checkpoint service");
+			LOG_ERROR("Has the cluster infrastructure been started?");
+			break;
+		case EXIT_FAILURE:
+			LOG_ERROR("Failed to start: Generic error");
+			break;
+		default:
+			LOG_ERROR("Failed to start: Unknown error");
+			break;
+		}
+		exit(EXIT_FAILURE);
+	}
+
+	setsid();
+	chdir("/");
+	umask(0);
+
+	close(0); close(1); close(2);
+	open("/dev/null", O_RDONLY); /* reopen stdin */
+	open("/dev/null", O_WRONLY); /* reopen stdout */
+	open("/dev/null", O_WRONLY); /* reopen stderr */
+
+	LOG_OPEN("cmirrord", LOG_PID, LOG_DAEMON);
+
+	if (create_lockfile(CMIRRORD_PIDFILE))
+		exit(EXIT_LOCKFILE);
+
+	signal(SIGINT, &sig_handler);
+	signal(SIGQUIT, &sig_handler);
+	signal(SIGTERM, &sig_handler);
+	signal(SIGHUP, &sig_handler);
+	signal(SIGPIPE, SIG_IGN);
+	signal(SIGUSR1, &sig_handler);
+	signal(SIGUSR2, &sig_handler);
+	sigemptyset(&signal_mask);
+	signal_received = 0;
+}
+
+/*
+ * init_all
+ *
+ * Initialize modules.  Exit on failure.
+ */
+static void init_all(void)
+{
+	int r;
+
+	if ((r = init_local()) ||
+	    (r = init_cluster())) {
+		exit(r);
+	}
+}
+
+/*
+ * cleanup_all
+ *
+ * Clean up before exiting
+ */
+static void cleanup_all(void)
+{
+	cleanup_local();
+	cleanup_cluster();
+}
/cvs/lvm2/LVM2/daemons/cmirrord/cluster.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/cluster.c
+++ -	2009-09-02 17:36:49.728727000 +0000
@@ -0,0 +1,1661 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#include <errno.h>
+#include <string.h>
+#include <sys/types.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <stdlib.h>
+#include <signal.h>
+#include <sys/socket.h> /* These are for OpenAIS CPGs */
+#include <sys/select.h>
+#include <sys/un.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <openais/saAis.h>
+#include <openais/cpg.h>
+#include <openais/saCkpt.h>
+
+#include "dm-log-userspace.h"
+#include "libdevmapper.h"
+#include "functions.h"
+#include "local.h"
+#include "common.h"
+#include "logging.h"
+#include "link_mon.h"
+#include "cluster.h"
+
+/* Open AIS error codes */
+#define str_ais_error(x)						\
+	((x) == SA_AIS_OK) ? "SA_AIS_OK" :				\
+	((x) == SA_AIS_ERR_LIBRARY) ? "SA_AIS_ERR_LIBRARY" :		\
+	((x) == SA_AIS_ERR_VERSION) ? "SA_AIS_ERR_VERSION" :		\
+	((x) == SA_AIS_ERR_INIT) ? "SA_AIS_ERR_INIT" :			\
+	((x) == SA_AIS_ERR_TIMEOUT) ? "SA_AIS_ERR_TIMEOUT" :		\
+	((x) == SA_AIS_ERR_TRY_AGAIN) ? "SA_AIS_ERR_TRY_AGAIN" :	\
+	((x) == SA_AIS_ERR_INVALID_PARAM) ? "SA_AIS_ERR_INVALID_PARAM" : \
+	((x) == SA_AIS_ERR_NO_MEMORY) ? "SA_AIS_ERR_NO_MEMORY" :	\
+	((x) == SA_AIS_ERR_BAD_HANDLE) ? "SA_AIS_ERR_BAD_HANDLE" :	\
+	((x) == SA_AIS_ERR_BUSY) ? "SA_AIS_ERR_BUSY" :			\
+	((x) == SA_AIS_ERR_ACCESS) ? "SA_AIS_ERR_ACCESS" :		\
+	((x) == SA_AIS_ERR_NOT_EXIST) ? "SA_AIS_ERR_NOT_EXIST" :	\
+	((x) == SA_AIS_ERR_NAME_TOO_LONG) ? "SA_AIS_ERR_NAME_TOO_LONG" : \
+	((x) == SA_AIS_ERR_EXIST) ? "SA_AIS_ERR_EXIST" :		\
+	((x) == SA_AIS_ERR_NO_SPACE) ? "SA_AIS_ERR_NO_SPACE" :		\
+	((x) == SA_AIS_ERR_INTERRUPT) ? "SA_AIS_ERR_INTERRUPT" :	\
+	((x) == SA_AIS_ERR_NAME_NOT_FOUND) ? "SA_AIS_ERR_NAME_NOT_FOUND" : \
+	((x) == SA_AIS_ERR_NO_RESOURCES) ? "SA_AIS_ERR_NO_RESOURCES" :	\
+	((x) == SA_AIS_ERR_NOT_SUPPORTED) ? "SA_AIS_ERR_NOT_SUPPORTED" : \
+	((x) == SA_AIS_ERR_BAD_OPERATION) ? "SA_AIS_ERR_BAD_OPERATION" : \
+	((x) == SA_AIS_ERR_FAILED_OPERATION) ? "SA_AIS_ERR_FAILED_OPERATION" : \
+	((x) == SA_AIS_ERR_MESSAGE_ERROR) ? "SA_AIS_ERR_MESSAGE_ERROR" : \
+	((x) == SA_AIS_ERR_QUEUE_FULL) ? "SA_AIS_ERR_QUEUE_FULL" :	\
+	((x) == SA_AIS_ERR_QUEUE_NOT_AVAILABLE) ? "SA_AIS_ERR_QUEUE_NOT_AVAILABLE" : \
+	((x) == SA_AIS_ERR_BAD_FLAGS) ? "SA_AIS_ERR_BAD_FLAGS" :	\
+	((x) == SA_AIS_ERR_TOO_BIG) ? "SA_AIS_ERR_TOO_BIG" :		\
+	((x) == SA_AIS_ERR_NO_SECTIONS) ? "SA_AIS_ERR_NO_SECTIONS" :	\
+	"ais_error_unknown"
+
+#define DM_ULOG_RESPONSE 0x1000 /* in last byte of 32-bit value */
+#define DM_ULOG_CHECKPOINT_READY 21
+#define DM_ULOG_MEMBER_JOIN      22
+
+#define _RQ_TYPE(x)							\
+	((x) == DM_ULOG_CHECKPOINT_READY) ? "DM_ULOG_CHECKPOINT_READY": \
+	((x) == DM_ULOG_MEMBER_JOIN) ? "DM_ULOG_MEMBER_JOIN":		\
+	RQ_TYPE((x) & ~DM_ULOG_RESPONSE)
+
+static uint32_t my_cluster_id = 0xDEAD;
+static SaCkptHandleT ckpt_handle = 0;
+static SaCkptCallbacksT callbacks = { 0, 0 };
+static SaVersionT version = { 'B', 1, 1 };
+
+#define DEBUGGING_HISTORY 100
+//static char debugging[DEBUGGING_HISTORY][128];
+//static int idx = 0;
+#define LOG_SPRINT(cc, f, arg...) do {				\
+		cc->idx++;					\
+		cc->idx = cc->idx % DEBUGGING_HISTORY;		\
+		sprintf(cc->debugging[cc->idx], f, ## arg);	\
+	} while (0)
+
+static int log_resp_rec = 0;
+
+struct checkpoint_data {
+	uint32_t requester;
+	char uuid[CPG_MAX_NAME_LENGTH];
+
+	int bitmap_size; /* in bytes */
+	char *sync_bits;
+	char *clean_bits;
+	char *recovering_region;
+	struct checkpoint_data *next;
+};	
+
+#define INVALID 0
+#define VALID   1
+#define LEAVING 2
+
+#define MAX_CHECKPOINT_REQUESTERS 10
+struct clog_cpg {
+	struct dm_list list;
+
+	uint32_t lowest_id;
+	cpg_handle_t handle;
+	struct cpg_name name;
+	uint64_t luid;
+
+	/* Are we the first, or have we received checkpoint? */
+	int state;
+	int cpg_state;  /* FIXME: debugging */
+	int free_me;
+	int delay;
+	int resend_requests;
+	struct dm_list startup_list;
+	struct dm_list working_list;
+
+	int checkpoints_needed;
+	uint32_t checkpoint_requesters[MAX_CHECKPOINT_REQUESTERS];
+	struct checkpoint_data *checkpoint_list;
+	int idx;
+	char debugging[DEBUGGING_HISTORY][128];
+};
+
+static struct dm_list clog_cpg_list;
+
+/*
+ * cluster_send
+ * @rq
+ *
+ * Returns: 0 on success, -Exxx on error
+ */
+int cluster_send(struct clog_request *rq)
+{
+	int r;
+	int count=0;
+	int found;
+	struct iovec iov;
+	struct clog_cpg *entry;
+
+	dm_list_iterate_items(entry, &clog_cpg_list)
+		if (!strncmp(entry->name.value, rq->u_rq.uuid,
+			     CPG_MAX_NAME_LENGTH)) {
+			found = 1;
+			break;
+		}
+
+	if (!found) {
+		rq->u_rq.error = -ENOENT;
+		return -ENOENT;
+	}
+
+	/*
+	 * Once the request heads for the cluster, the luid looses
+	 * all its meaning.
+	 */
+	rq->u_rq.luid = 0;
+
+	iov.iov_base = rq;
+	iov.iov_len = sizeof(struct clog_request) + rq->u_rq.data_size;
+
+	if (entry->cpg_state != VALID)
+		return -EINVAL;
+
+	do {
+		r = cpg_mcast_joined(entry->handle, CPG_TYPE_AGREED, &iov, 1);
+		if (r != SA_AIS_ERR_TRY_AGAIN)
+			break;
+		count++;
+		if (count < 10)
+			LOG_PRINT("[%s]  Retry #%d of cpg_mcast_joined: %s",
+				  SHORT_UUID(rq->u_rq.uuid), count,
+				  str_ais_error(r));
+		else if ((count < 100) && !(count % 10))
+			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s",
+				  SHORT_UUID(rq->u_rq.uuid), count,
+				  str_ais_error(r));
+		else if ((count < 1000) && !(count % 100))
+			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s",
+				  SHORT_UUID(rq->u_rq.uuid), count,
+				  str_ais_error(r));
+		else if ((count < 10000) && !(count % 1000))
+			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s - "
+				  "OpenAIS not handling the load?",
+				  SHORT_UUID(rq->u_rq.uuid), count,
+				  str_ais_error(r));
+		usleep(1000);
+	} while (1);
+
+	if (r == CPG_OK)
+		return 0;
+
+	/* error codes found in openais/cpg.h */
+	LOG_ERROR("cpg_mcast_joined error: %s", str_ais_error(r));
+
+	rq->u_rq.error = -EBADE;
+	return -EBADE;
+}
+
+static struct clog_request *get_matching_rq(struct clog_request *rq,
+					    struct dm_list *l)
+{
+	struct clog_request *match, *n;
+
+	dm_list_iterate_items_safe(match, n, l)
+		if (match->u_rq.seq == rq->u_rq.seq) {
+			dm_list_del(&match->list);
+			return match;
+		}
+
+	return NULL;
+}
+
+static char rq_buffer[DM_ULOG_REQUEST_SIZE];
+static int handle_cluster_request(struct clog_cpg *entry,
+				  struct clog_request *rq, int server)
+{
+	int r = 0;
+	struct clog_request *tmp = (struct clog_request *)rq_buffer;
+
+	/*
+	 * We need a separate dm_ulog_request struct, one that can carry
+	 * a return payload.  Otherwise, the memory address after
+	 * rq will be altered - leading to problems
+	 */
+	memset(rq_buffer, 0, sizeof(rq_buffer));
+	memcpy(tmp, rq, sizeof(struct clog_request) + rq->u_rq.data_size);
+
+	/*
+	 * With resumes, we only handle our own.
+	 * Resume is a special case that requires
+	 * local action (to set up CPG), followed by
+	 * a cluster action to co-ordinate reading
+	 * the disk and checkpointing
+	 */
+	if (tmp->u_rq.request_type == DM_ULOG_RESUME) {
+		if (tmp->originator == my_cluster_id) {
+			r = do_request(tmp, server);
+
+			r = kernel_send(&tmp->u_rq);
+			if (r < 0)
+				LOG_ERROR("Failed to send resume response to kernel");
+		}
+		return r;
+	}
+
+	r = do_request(tmp, server);
+
+	if (server &&
+	    (tmp->u_rq.request_type != DM_ULOG_CLEAR_REGION) &&
+	    (tmp->u_rq.request_type != DM_ULOG_POSTSUSPEND)) {
+		tmp->u_rq.request_type |= DM_ULOG_RESPONSE;
+
+		/*
+		 * Errors from previous functions are in the rq struct.
+		 */
+		r = cluster_send(tmp);
+		if (r < 0)
+			LOG_ERROR("cluster_send failed: %s", strerror(-r));
+	}
+
+	return r;
+}
+
+static int handle_cluster_response(struct clog_cpg *entry,
+				   struct clog_request *rq)
+{
+	int r = 0;
+	struct clog_request *orig_rq;
+
+	/*
+	 * If I didn't send it, then I don't care about the response
+	 */
+	if (rq->originator != my_cluster_id)
+		return 0;
+
+	rq->u_rq.request_type &= ~DM_ULOG_RESPONSE;
+	orig_rq = get_matching_rq(rq, &entry->working_list);
+
+	if (!orig_rq) {
+		/* Unable to find match for response */
+
+		LOG_ERROR("[%s] No match for cluster response: %s:%u",
+			  SHORT_UUID(rq->u_rq.uuid),
+			  _RQ_TYPE(rq->u_rq.request_type),
+			  rq->u_rq.seq);
+
+		LOG_ERROR("Current local list:");
+		if (dm_list_empty(&entry->working_list))
+			LOG_ERROR("   [none]");
+
+		dm_list_iterate_items(orig_rq, &entry->working_list)
+			LOG_ERROR("   [%s]  %s:%u",
+				  SHORT_UUID(orig_rq->u_rq.uuid),
+				  _RQ_TYPE(orig_rq->u_rq.request_type),
+				  orig_rq->u_rq.seq);
+
+		return -EINVAL;
+	}
+
+	if (log_resp_rec > 0) {
+		LOG_COND(log_resend_requests,
+			 "[%s] Response received to %s/#%u",
+			 SHORT_UUID(rq->u_rq.uuid),
+			 _RQ_TYPE(rq->u_rq.request_type),
+			 rq->u_rq.seq);
+		log_resp_rec--;
+	}
+
+	/* FIXME: Ensure memcpy cannot explode */
+	memcpy(orig_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
+
+	r = kernel_send(&orig_rq->u_rq);
+	if (r)
+		LOG_ERROR("Failed to send response to kernel");
+
+	free(orig_rq);
+	return r;
+}
+
+static struct clog_cpg *find_clog_cpg(cpg_handle_t handle)
+{
+	struct clog_cpg *match;
+
+	dm_list_iterate_items(match, &clog_cpg_list)
+		if (match->handle == handle)
+			return match;
+
+	return NULL;
+}
+
+/*
+ * prepare_checkpoint
+ * @entry: clog_cpg describing the log
+ * @cp_requester: nodeid requesting the checkpoint
+ *
+ * Creates and fills in a new checkpoint_data struct.
+ *
+ * Returns: checkpoint_data on success, NULL on error
+ */
+static struct checkpoint_data *prepare_checkpoint(struct clog_cpg *entry,
+						  uint32_t cp_requester)
+{
+	int r;
+	struct checkpoint_data *new;
+
+	if (entry->state != VALID) {
+		/*
+		 * We can't store bitmaps yet, because the log is not
+		 * valid yet.
+		 */
+		LOG_ERROR("Forced to refuse checkpoint for nodeid %u - log not valid yet",
+			  cp_requester);
+		return NULL;
+	}
+
+	new = malloc(sizeof(*new));
+	if (!new) {
+		LOG_ERROR("Unable to create checkpoint data for %u",
+			  cp_requester);
+		return NULL;
+	}
+	memset(new, 0, sizeof(*new));
+	new->requester = cp_requester;
+	strncpy(new->uuid, entry->name.value, entry->name.length);
+
+	new->bitmap_size = push_state(entry->name.value, entry->luid,
+				      "clean_bits",
+				      &new->clean_bits, cp_requester);
+	if (new->bitmap_size <= 0) {
+		LOG_ERROR("Failed to store clean_bits to checkpoint for node %u",
+			  new->requester);
+		free(new);
+		return NULL;
+	}
+
+	new->bitmap_size = push_state(entry->name.value, entry->luid,
+				      "sync_bits",
+				      &new->sync_bits, cp_requester);
+	if (new->bitmap_size <= 0) {
+		LOG_ERROR("Failed to store sync_bits to checkpoint for node %u",
+			  new->requester);
+		free(new->clean_bits);
+		free(new);
+		return NULL;
+	}
+
+	r = push_state(entry->name.value, entry->luid,
+		       "recovering_region",
+		       &new->recovering_region, cp_requester);
+	if (r <= 0) {
+		LOG_ERROR("Failed to store recovering_region to checkpoint for node %u",
+			  new->requester);
+		free(new->sync_bits);
+		free(new->clean_bits);
+		free(new);
+		return NULL;
+	}
+	LOG_DBG("[%s] Checkpoint prepared for node %u:",
+		SHORT_UUID(new->uuid), new->requester);
+	LOG_DBG("  bitmap_size = %d", new->bitmap_size);
+
+	return new;
+}
+
+/*
+ * free_checkpoint
+ * @cp: the checkpoint_data struct to free
+ *
+ */
+static void free_checkpoint(struct checkpoint_data *cp)
+{
+	free(cp->recovering_region);
+	free(cp->sync_bits);
+	free(cp->clean_bits);
+	free(cp);
+}
+
+static int export_checkpoint(struct checkpoint_data *cp)
+{
+	SaCkptCheckpointCreationAttributesT attr;
+	SaCkptCheckpointHandleT h;
+	SaCkptSectionIdT section_id;
+	SaCkptSectionCreationAttributesT section_attr;
+	SaCkptCheckpointOpenFlagsT flags;
+	SaNameT name;
+	SaAisErrorT rv;
+	struct clog_request *rq;
+	int len, r = 0;
+	char buf[32];
+
+	LOG_DBG("Sending checkpointed data to %u", cp->requester);
+
+	len = snprintf((char *)(name.value), SA_MAX_NAME_LENGTH,
+		       "bitmaps_%s_%u", SHORT_UUID(cp->uuid), cp->requester);
+	name.length = len;
+
+	len = strlen(cp->recovering_region) + 1;
+
+	attr.creationFlags = SA_CKPT_WR_ALL_REPLICAS;
+	attr.checkpointSize = cp->bitmap_size * 2 + len;
+
+	attr.retentionDuration = SA_TIME_MAX;
+	attr.maxSections = 4;      /* don't know why we need +1 */
+
+	attr.maxSectionSize = (cp->bitmap_size > len) ?	cp->bitmap_size : len;
+	attr.maxSectionIdSize = 22;
+
+	flags = SA_CKPT_CHECKPOINT_READ |
+		SA_CKPT_CHECKPOINT_WRITE |
+		SA_CKPT_CHECKPOINT_CREATE;
+
+open_retry:
+	rv = saCkptCheckpointOpen(ckpt_handle, &name, &attr, flags, 0, &h);
+	if (rv == SA_AIS_ERR_TRY_AGAIN) {
+		LOG_ERROR("export_checkpoint: ckpt open retry");
+		usleep(1000);
+		goto open_retry;
+	}
+
+	if (rv == SA_AIS_ERR_EXIST) {
+		LOG_DBG("export_checkpoint: checkpoint already exists");
+		return -EEXIST;
+	}
+
+	if (rv != SA_AIS_OK) {
+		LOG_ERROR("[%s] Failed to open checkpoint for %u: %s",
+			  SHORT_UUID(cp->uuid), cp->requester,
+			  str_ais_error(rv));
+		return -EIO; /* FIXME: better error */
+	}
+
+	/*
+	 * Add section for sync_bits
+	 */
+	section_id.idLen = snprintf(buf, 32, "sync_bits");
+	section_id.id = (unsigned char *)buf;
+	section_attr.sectionId = &section_id;
+	section_attr.expirationTime = SA_TIME_END;
+
+sync_create_retry:
+	rv = saCkptSectionCreate(h, &section_attr,
+				 cp->sync_bits, cp->bitmap_size);
+	if (rv == SA_AIS_ERR_TRY_AGAIN) {
+		LOG_ERROR("Sync checkpoint section create retry");
+		usleep(1000);
+		goto sync_create_retry;
+	}
+
+	if (rv == SA_AIS_ERR_EXIST) {
+		LOG_DBG("Sync checkpoint section already exists");
+		saCkptCheckpointClose(h);
+		return -EEXIST;
+	}
+
+	if (rv != SA_AIS_OK) {
+		LOG_ERROR("Sync checkpoint section creation failed: %s",
+			  str_ais_error(rv));
+		saCkptCheckpointClose(h);
+		return -EIO; /* FIXME: better error */
+	}
+
+	/*
+	 * Add section for clean_bits
+	 */
+	section_id.idLen = snprintf(buf, 32, "clean_bits");
+	section_id.id = (unsigned char *)buf;
+	section_attr.sectionId = &section_id;
+	section_attr.expirationTime = SA_TIME_END;
+
+clean_create_retry:
+	rv = saCkptSectionCreate(h, &section_attr, cp->clean_bits, cp->bitmap_size);
+	if (rv == SA_AIS_ERR_TRY_AGAIN) {
+		LOG_ERROR("Clean checkpoint section create retry");
+		usleep(1000);
+		goto clean_create_retry;
+	}
+
+	if (rv == SA_AIS_ERR_EXIST) {
+		LOG_DBG("Clean checkpoint section already exists");
+		saCkptCheckpointClose(h);
+		return -EEXIST;
+	}
+
+	if (rv != SA_AIS_OK) {
+		LOG_ERROR("Clean checkpoint section creation failed: %s",
+			  str_ais_error(rv));
+		saCkptCheckpointClose(h);
+		return -EIO; /* FIXME: better error */
+	}
+
+	/*
+	 * Add section for recovering_region
+	 */
+	section_id.idLen = snprintf(buf, 32, "recovering_region");
+	section_id.id = (unsigned char *)buf;
+	section_attr.sectionId = &section_id;
+	section_attr.expirationTime = SA_TIME_END;
+
+rr_create_retry:
+	rv = saCkptSectionCreate(h, &section_attr, cp->recovering_region,
+				 strlen(cp->recovering_region) + 1);
+	if (rv == SA_AIS_ERR_TRY_AGAIN) {
+		LOG_ERROR("RR checkpoint section create retry");
+		usleep(1000);
+		goto rr_create_retry;
+	}
+
+	if (rv == SA_AIS_ERR_EXIST) {
+		LOG_DBG("RR checkpoint section already exists");
+		saCkptCheckpointClose(h);
+		return -EEXIST;
+	}
+
+	if (rv != SA_AIS_OK) {
+		LOG_ERROR("RR checkpoint section creation failed: %s",
+			  str_ais_error(rv));
+		saCkptCheckpointClose(h);
+		return -EIO; /* FIXME: better error */
+	}
+
+	LOG_DBG("export_checkpoint: closing checkpoint");
+	saCkptCheckpointClose(h);
+
+	rq = malloc(DM_ULOG_REQUEST_SIZE);
+	if (!rq) {
+		LOG_ERROR("export_checkpoint: Unable to allocate transfer structs");
+		return -ENOMEM;
+	}
+	memset(rq, 0, sizeof(*rq));
+
+	dm_list_init(&rq->list);
+	rq->u_rq.request_type = DM_ULOG_CHECKPOINT_READY;
+	rq->originator = cp->requester;  /* FIXME: hack to overload meaning of originator */
+	strncpy(rq->u_rq.uuid, cp->uuid, CPG_MAX_NAME_LENGTH);
+	rq->u_rq.seq = my_cluster_id;
+
+	r = cluster_send(rq);
+	if (r)
+		LOG_ERROR("Failed to send checkpoint ready notice: %s",
+			  strerror(-r));
+
+	free(rq);
+	return 0;
+}
+
+static int import_checkpoint(struct clog_cpg *entry, int no_read)
+{
+	int rtn = 0;
+	SaCkptCheckpointHandleT h;
+	SaCkptSectionIterationHandleT itr;
+	SaCkptSectionDescriptorT desc;
+	SaCkptIOVectorElementT iov;
+	SaNameT name;
+	SaAisErrorT rv;
+	char *bitmap = NULL;
+	int len;
+
+	bitmap = malloc(1024*1024);
+	if (!bitmap)
+		return -ENOMEM;
+
+	len = snprintf((char *)(name.value), SA_MAX_NAME_LENGTH, "bitmaps_%s_%u",
+		       SHORT_UUID(entry->name.value), my_cluster_id);
+	name.length = len;
+
+open_retry:
+	rv = saCkptCheckpointOpen(ckpt_handle, &name, NULL,
+				  SA_CKPT_CHECKPOINT_READ, 0, &h);
+	if (rv == SA_AIS_ERR_TRY_AGAIN) {
+		LOG_ERROR("import_checkpoint: ckpt open retry");
+		usleep(1000);
+		goto open_retry;
+	}
+
+	if (rv != SA_AIS_OK) {
+		LOG_ERROR("[%s] Failed to open checkpoint: %s",
+			  SHORT_UUID(entry->name.value), str_ais_error(rv));
+		return -EIO; /* FIXME: better error */
+	}
+
+unlink_retry:
+	rv = saCkptCheckpointUnlink(ckpt_handle, &name);
+	if (rv == SA_AIS_ERR_TRY_AGAIN) {
+		LOG_ERROR("import_checkpoint: ckpt unlink retry");
+		usleep(1000);
+		goto unlink_retry;
+	}
+
+	if (no_read) {
+		LOG_DBG("Checkpoint for this log already received");
+		goto no_read;
+	}
+
+init_retry:
+	rv = saCkptSectionIterationInitialize(h, SA_CKPT_SECTIONS_ANY,
+					      SA_TIME_END, &itr);
+	if (rv == SA_AIS_ERR_TRY_AGAIN) {
+		LOG_ERROR("import_checkpoint: sync create retry");
+		usleep(1000);
+		goto init_retry;
+	}
+
+	if (rv != SA_AIS_OK) {
+		LOG_ERROR("[%s] Sync checkpoint section creation failed: %s",
+			  SHORT_UUID(entry->name.value), str_ais_error(rv));
+		return -EIO; /* FIXME: better error */
+	}
+
+	len = 0;
+	while (1) {
+		rv = saCkptSectionIterationNext(itr, &desc);
+		if (rv == SA_AIS_OK)
+			len++;
+		else if ((rv == SA_AIS_ERR_NO_SECTIONS) && len)
+			break;
+		else if (rv != SA_AIS_ERR_TRY_AGAIN) {
+			LOG_ERROR("saCkptSectionIterationNext failure: %d", rv);
+			break;
+		}
+	}
+	saCkptSectionIterationFinalize(itr);
+	if (len != 3) {
+		LOG_ERROR("import_checkpoint: %d checkpoint sections found",
+			  len);
+		usleep(1000);
+		goto init_retry;
+	}
+	saCkptSectionIterationInitialize(h, SA_CKPT_SECTIONS_ANY,
+					 SA_TIME_END, &itr);
+
+	while (1) {
+		rv = saCkptSectionIterationNext(itr, &desc);
+		if (rv == SA_AIS_ERR_NO_SECTIONS)
+			break;
+
+		if (rv == SA_AIS_ERR_TRY_AGAIN) {
+			LOG_ERROR("import_checkpoint: ckpt iternext retry");
+			usleep(1000);
+			continue;
+		}
+
+		if (rv != SA_AIS_OK) {
+			LOG_ERROR("import_checkpoint: clean checkpoint section "
+				  "creation failed: %s", str_ais_error(rv));
+			rtn = -EIO; /* FIXME: better error */
+			goto fail;
+		}
+
+		if (!desc.sectionSize) {
+			LOG_ERROR("Checkpoint section empty");
+			continue;
+		}
+
+		memset(bitmap, 0, sizeof(*bitmap));
+		iov.sectionId = desc.sectionId;
+		iov.dataBuffer = bitmap;
+		iov.dataSize = desc.sectionSize;
+		iov.dataOffset = 0;
+
+	read_retry:
+		rv = saCkptCheckpointRead(h, &iov, 1, NULL);
+		if (rv == SA_AIS_ERR_TRY_AGAIN) {
+			LOG_ERROR("ckpt read retry");
+			usleep(1000);
+			goto read_retry;
+		}
+
+		if (rv != SA_AIS_OK) {
+			LOG_ERROR("import_checkpoint: ckpt read error: %s",
+				  str_ais_error(rv));
+			rtn = -EIO; /* FIXME: better error */
+			goto fail;
+		}
+
+		if (iov.readSize) {
+			if (pull_state(entry->name.value, entry->luid,
+				       (char *)desc.sectionId.id, bitmap,
+				       iov.readSize)) {
+				LOG_ERROR("Error loading state");
+				rtn = -EIO;
+				goto fail;
+			}
+		} else {
+			/* Need to request new checkpoint */
+			rtn = -EAGAIN;
+			goto fail;
+		}
+	}
+
+fail:
+	saCkptSectionIterationFinalize(itr);
+no_read:
+	saCkptCheckpointClose(h);
+
+	free(bitmap);
+	return rtn;
+}
+
+static void do_checkpoints(struct clog_cpg *entry, int leaving)
+{
+	struct checkpoint_data *cp;
+
+	for (cp = entry->checkpoint_list; cp;) {
+		/*
+		 * FIXME: Check return code.  Could send failure
+		 * notice in rq in export_checkpoint function
+		 * by setting rq->error
+		 */
+		switch (export_checkpoint(cp)) {
+		case -EEXIST:
+			LOG_SPRINT(entry, "[%s] Checkpoint for %u already handled%s",
+				   SHORT_UUID(entry->name.value), cp->requester,
+				   (leaving) ? "(L)": "");
+			LOG_COND(log_checkpoint,
+				 "[%s] Checkpoint for %u already handled%s",
+				 SHORT_UUID(entry->name.value), cp->requester,
+				 (leaving) ? "(L)": "");
+			entry->checkpoint_list = cp->next;
+			free_checkpoint(cp);
+			cp = entry->checkpoint_list;
+			break;
+		case 0:
+			LOG_SPRINT(entry, "[%s] Checkpoint data available for node %u%s",
+				   SHORT_UUID(entry->name.value), cp->requester,
+				   (leaving) ? "(L)": "");
+			LOG_COND(log_checkpoint,
+				 "[%s] Checkpoint data available for node %u%s",
+				 SHORT_UUID(entry->name.value), cp->requester,
+				 (leaving) ? "(L)": "");
+			entry->checkpoint_list = cp->next;
+			free_checkpoint(cp);
+			cp = entry->checkpoint_list;
+			break;
+		default:
+			/* FIXME: Skipping will cause list corruption */
+			LOG_ERROR("[%s] Failed to export checkpoint for %u%s",
+				  SHORT_UUID(entry->name.value), cp->requester,
+				  (leaving) ? "(L)": "");
+		}
+	}
+}
+
+static int resend_requests(struct clog_cpg *entry)
+{
+	int r = 0;
+	struct clog_request *rq, *n;
+
+	if (!entry->resend_requests || entry->delay)
+		return 0;
+
+	if (entry->state != VALID)
+		return 0;
+
+	entry->resend_requests = 0;
+
+	dm_list_iterate_items_safe(rq, n, &entry->working_list) {
+		dm_list_del(&rq->list);
+
+		if (strcmp(entry->name.value, rq->u_rq.uuid)) {
+			LOG_ERROR("[%s]  Stray request from another log (%s)",
+				  SHORT_UUID(entry->name.value),
+				  SHORT_UUID(rq->u_rq.uuid));
+			free(rq);
+			continue;
+		}
+
+		switch (rq->u_rq.request_type) {
+		case DM_ULOG_SET_REGION_SYNC:
+			/*
+			 * Some requests simply do not need to be resent.
+			 * If it is a request that just changes log state,
+			 * then it doesn't need to be resent (everyone makes
+			 * updates).
+			 */
+			LOG_COND(log_resend_requests,
+				 "[%s] Skipping resend of %s/#%u...",
+				 SHORT_UUID(entry->name.value),
+				 _RQ_TYPE(rq->u_rq.request_type),
+				 rq->u_rq.seq);
+			LOG_SPRINT(entry, "###  No resend: [%s] %s/%u ###",
+				   SHORT_UUID(entry->name.value),
+				   _RQ_TYPE(rq->u_rq.request_type),
+				   rq->u_rq.seq);
+
+			rq->u_rq.data_size = 0;
+			kernel_send(&rq->u_rq);
+				
+			break;
+			
+		default:
+			/*
+			 * If an action or a response is required, then
+			 * the request must be resent.
+			 */
+			LOG_COND(log_resend_requests,
+				 "[%s] Resending %s(#%u) due to new server(%u)",
+				 SHORT_UUID(entry->name.value),
+				 _RQ_TYPE(rq->u_rq.request_type),
+				 rq->u_rq.seq, entry->lowest_id);
+			LOG_SPRINT(entry, "***  Resending: [%s] %s/%u ***",
+				   SHORT_UUID(entry->name.value),
+				   _RQ_TYPE(rq->u_rq.request_type),
+				   rq->u_rq.seq);
+			r = cluster_send(rq);
+			if (r < 0)
+				LOG_ERROR("Failed resend");
+		}
+		free(rq);
+	}
+
+	return r;
+}
+
+static int do_cluster_work(void *data)
+{
+	int r = SA_AIS_OK;
+	struct clog_cpg *entry;
+
+	dm_list_iterate_items(entry, &clog_cpg_list) {
+		r = cpg_dispatch(entry->handle, CPG_DISPATCH_ALL);
+		if (r != SA_AIS_OK)
+			LOG_ERROR("cpg_dispatch failed: %s", str_ais_error(r));
+
+		if (entry->free_me) {
+			free(entry);
+			continue;
+		}
+		do_checkpoints(entry, 0);
+
+		resend_requests(entry);
+	}
+
+	return (r == SA_AIS_OK) ? 0 : -1;  /* FIXME: good error number? */
+}
+
+static int flush_startup_list(struct clog_cpg *entry)
+{
+	int r = 0;
+	int i_was_server;
+	struct clog_request *rq, *n;
+	struct checkpoint_data *new;
+
+	dm_list_iterate_items_safe(rq, n, &entry->startup_list) {
+		dm_list_del(&rq->list);
+
+		if (rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN) {
+			new = prepare_checkpoint(entry, rq->originator);
+			if (!new) {
+				/*
+				 * FIXME: Need better error handling.  Other nodes
+				 * will be trying to send the checkpoint too, and we
+				 * must continue processing the list; so report error
+				 * but continue.
+				 */
+				LOG_ERROR("Failed to prepare checkpoint for %u!!!",
+					  rq->originator);
+				free(rq);
+				continue;
+			}
+			LOG_SPRINT(entry, "[%s] Checkpoint prepared for %u",
+				   SHORT_UUID(entry->name.value), rq->originator);
+			LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u",
+				 SHORT_UUID(entry->name.value), rq->originator);
+			new->next = entry->checkpoint_list;
+			entry->checkpoint_list = new;
+		} else {
+			LOG_DBG("[%s] Processing delayed request: %s",
+				SHORT_UUID(rq->u_rq.uuid),
+				_RQ_TYPE(rq->u_rq.request_type));
+			i_was_server = (rq->pit_server == my_cluster_id) ? 1 : 0;
+			r = handle_cluster_request(entry, rq, i_was_server);
+
+			if (r)
+				/*
+				 * FIXME: If we error out here, we will never get
+				 * another opportunity to retry these requests
+				 */
+				LOG_ERROR("Error while processing delayed CPG message");
+		}
+		free(rq);
+	}
+
+	return 0;
+}
+
+static void cpg_message_callback(cpg_handle_t handle, struct cpg_name *gname,
+				 uint32_t nodeid, uint32_t pid,
+				 void *msg, int msg_len)
+{
+	int i;
+	int r = 0;
+	int i_am_server;
+	int response = 0;
+	struct clog_request *rq = msg;
+	struct clog_request *tmp_rq;
+	struct clog_cpg *match;
+
+	match = find_clog_cpg(handle);
+	if (!match) {
+		LOG_ERROR("Unable to find clog_cpg for cluster message");
+		return;
+	}
+
+	if ((nodeid == my_cluster_id) &&
+	    !(rq->u_rq.request_type & DM_ULOG_RESPONSE) &&
+	    (rq->u_rq.request_type != DM_ULOG_RESUME) &&
+	    (rq->u_rq.request_type != DM_ULOG_CLEAR_REGION) &&
+	    (rq->u_rq.request_type != DM_ULOG_CHECKPOINT_READY)) {
+		tmp_rq = malloc(DM_ULOG_REQUEST_SIZE);
+		if (!tmp_rq) {
+			/*
+			 * FIXME: It may be possible to continue... but we
+			 * would not be able to resend any messages that might
+			 * be necessary during membership changes
+			 */
+			LOG_ERROR("[%s] Unable to record request: -ENOMEM",
+				  SHORT_UUID(rq->u_rq.uuid));
+			return;
+		}
+		memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
+		dm_list_init(&tmp_rq->list);
+		dm_list_add( &match->working_list, &tmp_rq->list);
+	}
+
+	if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND) {
+		/*
+		 * If the server (lowest_id) indicates it is leaving,
+		 * then we must resend any outstanding requests.  However,
+		 * we do not want to resend them if the next server in
+		 * line is in the process of leaving.
+		 */
+		if (nodeid == my_cluster_id) {
+			LOG_COND(log_resend_requests, "[%s] I am leaving.1.....",
+				 SHORT_UUID(rq->u_rq.uuid));
+		} else {
+			if (nodeid < my_cluster_id) {
+				if (nodeid == match->lowest_id) {
+					match->resend_requests = 1;
+					LOG_COND(log_resend_requests, "[%s] %u is leaving, resend required%s",
+						 SHORT_UUID(rq->u_rq.uuid), nodeid,
+						 (dm_list_empty(&match->working_list)) ? " -- working_list empty": "");
+
+					dm_list_iterate_items(tmp_rq, &match->working_list)
+						LOG_COND(log_resend_requests,
+							 "[%s]                %s/%u",
+							 SHORT_UUID(tmp_rq->u_rq.uuid),
+							 _RQ_TYPE(tmp_rq->u_rq.request_type),
+							 tmp_rq->u_rq.seq);
+				}
+
+				match->delay++;
+				LOG_COND(log_resend_requests, "[%s] %u is leaving, delay = %d",
+					 SHORT_UUID(rq->u_rq.uuid), nodeid, match->delay);
+			}
+			rq->originator = nodeid; /* don't really need this, but nice for debug */
+			goto out;
+		}
+	}
+
+	/*
+	 * We can receive messages after we do a cpg_leave but before we
+	 * get our config callback.  However, since we can't respond after
+	 * leaving, we simply return.
+	 */
+	if (match->state == LEAVING)
+		return;
+
+	i_am_server = (my_cluster_id == match->lowest_id) ? 1 : 0;
+
+	if (rq->u_rq.request_type == DM_ULOG_CHECKPOINT_READY) {
+		if (my_cluster_id == rq->originator) {
+			/* Redundant checkpoints ignored if match->valid */
+			LOG_SPRINT(match, "[%s] CHECKPOINT_READY notification from %u",
+				   SHORT_UUID(rq->u_rq.uuid), nodeid);
+			if (import_checkpoint(match, (match->state != INVALID))) {
+				LOG_SPRINT(match,
+					   "[%s] Failed to import checkpoint from %u",
+					   SHORT_UUID(rq->u_rq.uuid), nodeid);
+				LOG_ERROR("[%s] Failed to import checkpoint from %u",
+					  SHORT_UUID(rq->u_rq.uuid), nodeid);
+				kill(getpid(), SIGUSR1);
+				/* Could we retry? */
+				goto out;
+			} else if (match->state == INVALID) {
+				LOG_SPRINT(match,
+					   "[%s] Checkpoint data received from %u.  Log is now valid",
+					   SHORT_UUID(match->name.value), nodeid);
+				LOG_COND(log_checkpoint,
+					 "[%s] Checkpoint data received from %u.  Log is now valid",
+					 SHORT_UUID(match->name.value), nodeid);
+				match->state = VALID;
+
+				flush_startup_list(match);
+			} else {
+				LOG_SPRINT(match,
+					   "[%s] Redundant checkpoint from %u ignored.",
+					   SHORT_UUID(rq->u_rq.uuid), nodeid);
+			}
+		}
+		goto out;
+	}
+
+	if (rq->u_rq.request_type & DM_ULOG_RESPONSE) {
+		response = 1;
+		r = handle_cluster_response(match, rq);
+	} else {
+		rq->originator = nodeid;
+
+		if (match->state == LEAVING) {
+			LOG_ERROR("[%s]  Ignoring %s from %u.  Reason: I'm leaving",
+				  SHORT_UUID(rq->u_rq.uuid), _RQ_TYPE(rq->u_rq.request_type),
+				  rq->originator);
+			goto out;
+		}
+
+		if (match->state == INVALID) {
+			LOG_DBG("Log not valid yet, storing request");
+			tmp_rq = malloc(DM_ULOG_REQUEST_SIZE);
+			if (!tmp_rq) {
+				LOG_ERROR("cpg_message_callback:  Unable to"
+					  " allocate transfer structs");
+				r = -ENOMEM; /* FIXME: Better error #? */
+				goto out;
+			}
+
+			memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
+			tmp_rq->pit_server = match->lowest_id;
+			dm_list_init(&tmp_rq->list);
+			dm_list_add(&match->startup_list, &tmp_rq->list);
+			goto out;
+		}
+
+		r = handle_cluster_request(match, rq, i_am_server);
+	}
+
+	/*
+	 * If the log is now valid, we can queue the checkpoints
+	 */
+	for (i = match->checkpoints_needed; i; ) {
+		struct checkpoint_data *new;
+
+		if (log_get_state(&rq->u_rq) != LOG_RESUMED) {
+			LOG_DBG("[%s] Withholding checkpoints until log is valid (%s from %u)",
+				SHORT_UUID(rq->u_rq.uuid), _RQ_TYPE(rq->u_rq.request_type), nodeid);
+			break;
+		}
+
+		i--;
+		new = prepare_checkpoint(match, match->checkpoint_requesters[i]);
+		if (!new) {
+			/* FIXME: Need better error handling */
+			LOG_ERROR("[%s] Failed to prepare checkpoint for %u!!!",
+				  SHORT_UUID(rq->u_rq.uuid), match->checkpoint_requesters[i]);
+			break;
+		}
+		LOG_SPRINT(match, "[%s] Checkpoint prepared for %u* (%s)",
+			   SHORT_UUID(rq->u_rq.uuid), match->checkpoint_requesters[i],
+			   (log_get_state(&rq->u_rq) != LOG_RESUMED)? "LOG_RESUMED": "LOG_SUSPENDED");
+		LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u*",
+			 SHORT_UUID(rq->u_rq.uuid), match->checkpoint_requesters[i]);
+		match->checkpoints_needed--;
+
+		new->next = match->checkpoint_list;
+		match->checkpoint_list = new;
+	}
+
+out:
+	/* nothing happens after this point.  It is just for debugging */
+	if (r) {
+		LOG_ERROR("[%s] Error while processing CPG message, %s: %s",
+			  SHORT_UUID(rq->u_rq.uuid),
+			  _RQ_TYPE(rq->u_rq.request_type & ~DM_ULOG_RESPONSE),
+			  strerror(-r));
+		LOG_ERROR("[%s]    Response  : %s", SHORT_UUID(rq->u_rq.uuid),
+			  (response) ? "YES" : "NO");
+		LOG_ERROR("[%s]    Originator: %u",
+			  SHORT_UUID(rq->u_rq.uuid), rq->originator);
+		if (response)
+			LOG_ERROR("[%s]    Responder : %u",
+				  SHORT_UUID(rq->u_rq.uuid), nodeid);
+
+		LOG_ERROR("HISTORY::");
+		for (i = 0; i < DEBUGGING_HISTORY; i++) {
+			match->idx++;
+			match->idx = match->idx % DEBUGGING_HISTORY;
+			if (match->debugging[match->idx][0] == '\0')
+				continue;
+			LOG_ERROR("%d:%d) %s", i, match->idx,
+				  match->debugging[match->idx]);
+		}
+	} else if (!(rq->u_rq.request_type & DM_ULOG_RESPONSE) ||
+		   (rq->originator == my_cluster_id)) {
+		if (!response)
+			LOG_SPRINT(match, "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s",
+				   rq->u_rq.seq, SHORT_UUID(rq->u_rq.uuid),
+				   _RQ_TYPE(rq->u_rq.request_type),
+				   rq->originator, (response) ? "YES" : "NO");
+		else
+			LOG_SPRINT(match, "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s, RSPR=%u",
+				   rq->u_rq.seq, SHORT_UUID(rq->u_rq.uuid),
+				   _RQ_TYPE(rq->u_rq.request_type),
+				   rq->originator, (response) ? "YES" : "NO",
+				   nodeid);
+	}
+}
+
+static void cpg_join_callback(struct clog_cpg *match,
+			      struct cpg_address *joined,
+			      struct cpg_address *member_list,
+			      int member_list_entries)
+{
+	int i;
+	int my_pid = getpid();
+	uint32_t lowest = match->lowest_id;
+	struct clog_request *rq;
+	char dbuf[32];
+
+	/* Assign my_cluster_id */
+	if ((my_cluster_id == 0xDEAD) && (joined->pid == my_pid))
+		my_cluster_id = joined->nodeid;
+
+	/* Am I the very first to join? */
+	if (member_list_entries == 1) {
+		match->lowest_id = joined->nodeid;
+		match->state = VALID;
+	}
+
+	/* If I am part of the joining list, I do not send checkpoints */
+	if (joined->nodeid == my_cluster_id)
+		goto out;
+
+	memset(dbuf, 0, sizeof(dbuf));
+	for (i = 0; i < (member_list_entries-1); i++)
+		sprintf(dbuf+strlen(dbuf), "%u-", member_list[i].nodeid);
+	sprintf(dbuf+strlen(dbuf), "(%u)", joined->nodeid);
+	LOG_COND(log_checkpoint, "[%s] Joining node, %u needs checkpoint [%s]",
+		 SHORT_UUID(match->name.value), joined->nodeid, dbuf);
+
+	/*
+	 * FIXME: remove checkpoint_requesters/checkpoints_needed, and use
+	 * the startup_list interface exclusively
+	 */
+	if (dm_list_empty(&match->startup_list) && (match->state == VALID) &&
+	    (match->checkpoints_needed < MAX_CHECKPOINT_REQUESTERS)) {
+		match->checkpoint_requesters[match->checkpoints_needed++] = joined->nodeid;
+		goto out;
+	}
+
+	rq = malloc(DM_ULOG_REQUEST_SIZE);
+	if (!rq) {
+		LOG_ERROR("cpg_config_callback: "
+			  "Unable to allocate transfer structs");
+		LOG_ERROR("cpg_config_callback: "
+			  "Unable to perform checkpoint");
+		goto out;
+	}
+	rq->u_rq.request_type = DM_ULOG_MEMBER_JOIN;
+	rq->originator = joined->nodeid;
+	dm_list_init(&rq->list);
+	dm_list_add(&match->startup_list, &rq->list);
+
+out:
+	/* Find the lowest_id, i.e. the server */
+	match->lowest_id = member_list[0].nodeid;
+	for (i = 0; i < member_list_entries; i++)
+		if (match->lowest_id > member_list[i].nodeid)
+			match->lowest_id = member_list[i].nodeid;
+
+	if (lowest == 0xDEAD)
+		LOG_COND(log_membership_change, "[%s]  Server change <none> -> %u (%u %s)",
+			 SHORT_UUID(match->name.value), match->lowest_id,
+			 joined->nodeid, (member_list_entries == 1) ?
+			 "is first to join" : "joined");
+	else if (lowest != match->lowest_id)
+		LOG_COND(log_membership_change, "[%s]  Server change %u -> %u (%u joined)",
+			 SHORT_UUID(match->name.value), lowest,
+			 match->lowest_id, joined->nodeid);
+	else
+		LOG_COND(log_membership_change, "[%s]  Server unchanged at %u (%u joined)",
+			 SHORT_UUID(match->name.value),
+			 lowest, joined->nodeid);
+	LOG_SPRINT(match, "+++  UUID=%s  %u join  +++",
+		   SHORT_UUID(match->name.value), joined->nodeid);
+}
+
+static void cpg_leave_callback(struct clog_cpg *match,
+			       struct cpg_address *left,
+			       struct cpg_address *member_list,
+			       int member_list_entries)
+{
+	int i, j, fd;
+	uint32_t lowest = match->lowest_id;
+	struct clog_request *rq, *n;
+	struct checkpoint_data *p_cp, *c_cp;
+
+	LOG_SPRINT(match, "---  UUID=%s  %u left  ---",
+		   SHORT_UUID(match->name.value), left->nodeid);
+
+	/* Am I leaving? */
+	if (my_cluster_id == left->nodeid) {
+		LOG_DBG("Finalizing leave...");
+		dm_list_del(&match->list);
+
+		cpg_fd_get(match->handle, &fd);
+		links_unregister(fd);
+
+		cluster_postsuspend(match->name.value, match->luid);
+
+		dm_list_iterate_items_safe(rq, n, &match->working_list) {
+			dm_list_del(&rq->list);
+
+			if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND)
+				kernel_send(&rq->u_rq);
+			free(rq);
+		}
+
+		cpg_finalize(match->handle);
+
+		match->free_me = 1;
+		match->lowest_id = 0xDEAD;
+		match->state = INVALID;
+	}			
+
+	/* Remove any pending checkpoints for the leaving node. */
+	for (p_cp = NULL, c_cp = match->checkpoint_list;
+	     c_cp && (c_cp->requester != left->nodeid);
+	     p_cp = c_cp, c_cp = c_cp->next);
+	if (c_cp) {
+		if (p_cp)
+			p_cp->next = c_cp->next;
+		else
+			match->checkpoint_list = c_cp->next;
+
+		LOG_COND(log_checkpoint,
+			 "[%s] Removing pending checkpoint (%u is leaving)",
+			 SHORT_UUID(match->name.value), left->nodeid);
+		free_checkpoint(c_cp);
+	}
+	dm_list_iterate_items_safe(rq, n, &match->startup_list) {
+		if ((rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN) &&
+		    (rq->originator == left->nodeid)) {
+			LOG_COND(log_checkpoint,
+				 "[%s] Removing pending ckpt from startup list (%u is leaving)",
+				 SHORT_UUID(match->name.value), left->nodeid);
+			dm_list_del(&rq->list);
+			free(rq);
+		}
+	}
+	for (i = 0, j = 0; i < match->checkpoints_needed; i++, j++) {
+		match->checkpoint_requesters[j] = match->checkpoint_requesters[i];
+		if (match->checkpoint_requesters[i] == left->nodeid) {
+			LOG_ERROR("[%s] Removing pending ckpt from needed list (%u is leaving)",
+				  SHORT_UUID(match->name.value), left->nodeid);
+			j--;
+		}
+	}
+	match->checkpoints_needed = j;
+
+	if (left->nodeid < my_cluster_id) {
+		match->delay = (match->delay > 0) ? match->delay - 1 : 0;
+		if (!match->delay && dm_list_empty(&match->working_list))
+			match->resend_requests = 0;
+		LOG_COND(log_resend_requests, "[%s] %u has left, delay = %d%s",
+			 SHORT_UUID(match->name.value), left->nodeid,
+			 match->delay, (dm_list_empty(&match->working_list)) ?
+			 " -- working_list empty": "");
+	}
+
+	/* Find the lowest_id, i.e. the server */
+	if (!member_list_entries) {
+		match->lowest_id = 0xDEAD;
+		LOG_COND(log_membership_change, "[%s]  Server change %u -> <none> "
+			 "(%u is last to leave)",
+			 SHORT_UUID(match->name.value), left->nodeid,
+			 left->nodeid);
+		return;
+	}
+		
+	match->lowest_id = member_list[0].nodeid;
+	for (i = 0; i < member_list_entries; i++)
+		if (match->lowest_id > member_list[i].nodeid)
+			match->lowest_id = member_list[i].nodeid;
+
+	if (lowest != match->lowest_id) {
+		LOG_COND(log_membership_change, "[%s]  Server change %u -> %u (%u left)",
+			 SHORT_UUID(match->name.value), lowest,
+			 match->lowest_id, left->nodeid);
+	} else
+		LOG_COND(log_membership_change, "[%s]  Server unchanged at %u (%u left)",
+			 SHORT_UUID(match->name.value), lowest, left->nodeid);
+
+	if ((match->state == INVALID) && !match->free_me) {
+		/*
+		 * If all CPG members are waiting for checkpoints and they
+		 * are all present in my startup_list, then I was the first to
+		 * join and I must assume control.
+		 *
+		 * We do not normally end up here, but if there was a quick
+		 * 'resume -> suspend -> resume' across the cluster, we may
+		 * have initially thought we were not the first to join because
+		 * of the presence of out-going (and unable to respond) members.
+		 */
+
+		i = 1; /* We do not have a DM_ULOG_MEMBER_JOIN entry of our own */
+		dm_list_iterate_items(rq, &match->startup_list)
+			if (rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN)
+				i++;
+
+		if (i == member_list_entries) {
+			/* 
+			 * Last node who could have given me a checkpoint just left.
+			 * Setting log state to VALID and acting as 'first join'.
+			 */
+			match->state = VALID;
+			flush_startup_list(match);
+		}
+	}
+}
+
+static void cpg_config_callback(cpg_handle_t handle, struct cpg_name *gname,
+				struct cpg_address *member_list,
+				int member_list_entries,
+				struct cpg_address *left_list,
+				int left_list_entries,
+				struct cpg_address *joined_list,
+				int joined_list_entries)
+{
+	struct clog_cpg *match;
+	int found = 0;
+
+	dm_list_iterate_items(match, &clog_cpg_list)
+		if (match->handle == handle) {
+			found = 1;
+			break;
+		}
+
+	if (!found) {
+		LOG_ERROR("Unable to find match for CPG config callback");
+		return;
+	}
+
+	if ((joined_list_entries + left_list_entries) > 1)
+		LOG_ERROR("[%s]  More than one node joining/leaving",
+			  SHORT_UUID(match->name.value));
+
+	if (joined_list_entries)
+		cpg_join_callback(match, joined_list,
+				  member_list, member_list_entries);
+	else
+		cpg_leave_callback(match, left_list,
+				   member_list, member_list_entries);
+}
+
+cpg_callbacks_t cpg_callbacks = {
+	.cpg_deliver_fn = cpg_message_callback,
+	.cpg_confchg_fn = cpg_config_callback,
+};
+
+/*
+ * remove_checkpoint
+ * @entry
+ *
+ * Returns: 1 if checkpoint removed, 0 if no checkpoints, -EXXX on error
+ */
+int remove_checkpoint(struct clog_cpg *entry)
+{
+	int len;
+	SaNameT name;
+	SaAisErrorT rv;
+	SaCkptCheckpointHandleT h;
+
+	len = snprintf((char *)(name.value), SA_MAX_NAME_LENGTH, "bitmaps_%s_%u",
+                       SHORT_UUID(entry->name.value), my_cluster_id);
+	name.length = len;
+
+open_retry:
+	rv = saCkptCheckpointOpen(ckpt_handle, &name, NULL,
+                                  SA_CKPT_CHECKPOINT_READ, 0, &h);
+	if (rv == SA_AIS_ERR_TRY_AGAIN) {
+		LOG_ERROR("abort_startup: ckpt open retry");
+                usleep(1000);
+                goto open_retry;
+        }
+
+	if (rv != SA_AIS_OK)
+                return 0;
+
+	LOG_DBG("[%s]  Removing checkpoint", SHORT_UUID(entry->name.value));
+unlink_retry:
+        rv = saCkptCheckpointUnlink(ckpt_handle, &name);
+        if (rv == SA_AIS_ERR_TRY_AGAIN) {
+                LOG_ERROR("abort_startup: ckpt unlink retry");
+                usleep(1000);
+                goto unlink_retry;
+        }
+	
+	if (rv != SA_AIS_OK) {
+                LOG_ERROR("[%s] Failed to unlink checkpoint: %s",
+                          SHORT_UUID(entry->name.value), str_ais_error(rv));
+                return -EIO;
+        }
+
+	saCkptCheckpointClose(h);
+
+	return 1;
+}
+
+int create_cluster_cpg(char *uuid, uint64_t luid)
+{
+	int r;
+	int size;
+	struct clog_cpg *new = NULL;
+	struct clog_cpg *tmp;
+
+	dm_list_iterate_items(tmp, &clog_cpg_list)
+		if (!strncmp(tmp->name.value, uuid, CPG_MAX_NAME_LENGTH)) {
+			LOG_ERROR("Log entry already exists: %s", uuid);
+			return -EEXIST;
+		}
+
+	new = malloc(sizeof(*new));
+	if (!new) {
+		LOG_ERROR("Unable to allocate memory for clog_cpg");
+		return -ENOMEM;
+	}
+	memset(new, 0, sizeof(*new));
+	dm_list_init(&new->list);
+	new->lowest_id = 0xDEAD;
+	dm_list_init(&new->startup_list);
+	dm_list_init(&new->working_list);
+
+	size = ((strlen(uuid) + 1) > CPG_MAX_NAME_LENGTH) ?
+		CPG_MAX_NAME_LENGTH : (strlen(uuid) + 1);
+	strncpy(new->name.value, uuid, size);
+	new->name.length = size;
+	new->luid = luid;
+
+	/*
+	 * Ensure there are no stale checkpoints around before we join
+	 */
+	if (remove_checkpoint(new) == 1)
+		LOG_COND(log_checkpoint,
+			 "[%s]  Removing checkpoints left from previous session",
+			 SHORT_UUID(new->name.value));
+
+	r = cpg_initialize(&new->handle, &cpg_callbacks);
+	if (r != SA_AIS_OK) {
+		LOG_ERROR("cpg_initialize failed:  Cannot join cluster");
+		free(new);
+		return -EPERM;
+	}
+
+	r = cpg_join(new->handle, &new->name);
+	if (r != SA_AIS_OK) {
+		LOG_ERROR("cpg_join failed:  Cannot join cluster");
+		free(new);
+		return -EPERM;
+	}
+
+	new->cpg_state = VALID;
+	dm_list_add(&clog_cpg_list, &new->list);
+	LOG_DBG("New   handle: %llu", (unsigned long long)new->handle);
+	LOG_DBG("New   name: %s", new->name.value);
+
+	/* FIXME: better variable */
+	cpg_fd_get(new->handle, &r);
+	links_register(r, "cluster", do_cluster_work, NULL);
+
+	return 0;
+}
+
+static void abort_startup(struct clog_cpg *del)
+{
+	struct clog_request *rq, *n;
+
+	LOG_DBG("[%s]  CPG teardown before checkpoint received",
+		SHORT_UUID(del->name.value));
+
+	dm_list_iterate_items_safe(rq, n, &del->startup_list) {
+		dm_list_del(&rq->list);
+
+		LOG_DBG("[%s]  Ignoring request from %u: %s",
+			SHORT_UUID(del->name.value), rq->originator,
+			_RQ_TYPE(rq->u_rq.request_type));
+		free(rq);
+	}
+
+	remove_checkpoint(del);
+}
+
+static int _destroy_cluster_cpg(struct clog_cpg *del)
+{
+	int r;
+	int state;
+	
+	LOG_COND(log_resend_requests, "[%s] I am leaving.2.....",
+		 SHORT_UUID(del->name.value));
+
+	/*
+	 * We must send any left over checkpoints before
+	 * leaving.  If we don't, an incoming node could
+	 * be stuck with no checkpoint and stall.
+	 do_checkpoints(del); --- THIS COULD BE CAUSING OUR PROBLEMS:
+
+	 - Incoming node deletes old checkpoints before joining
+	 - A stale checkpoint is issued here by leaving node
+	 - (leaving node leaves)
+	 - Incoming node joins cluster and finds stale checkpoint.
+	 - (leaving node leaves - option 2)
+	*/
+	do_checkpoints(del, 1);
+
+	state = del->state;
+
+	del->cpg_state = INVALID;
+	del->state = LEAVING;
+
+	/*
+	 * If the state is VALID, we might be processing the
+	 * startup list.  If so, we certainly don't want to
+	 * clear the startup_list here by calling abort_startup
+	 */
+	if (!dm_list_empty(&del->startup_list) && (state != VALID))
+		abort_startup(del);
+
+	r = cpg_leave(del->handle, &del->name);
+	if (r != CPG_OK)
+		LOG_ERROR("Error leaving CPG!");
+	return 0;
+}
+
+int destroy_cluster_cpg(char *uuid)
+{
+	struct clog_cpg *del, *tmp;
+
+	dm_list_iterate_items_safe(del, tmp, &clog_cpg_list)
+		if (!strncmp(del->name.value, uuid, CPG_MAX_NAME_LENGTH))
+			_destroy_cluster_cpg(del);
+
+	return 0;
+}
+
+int init_cluster(void)
+{
+	SaAisErrorT rv;
+
+	dm_list_init(&clog_cpg_list);
+	rv = saCkptInitialize(&ckpt_handle, &callbacks, &version);
+
+	if (rv != SA_AIS_OK)
+		return EXIT_CLUSTER_CKPT_INIT;
+
+	return 0;
+}
+
+void cleanup_cluster(void)
+{
+	SaAisErrorT err;
+
+	err = saCkptFinalize(ckpt_handle);
+	if (err != SA_AIS_OK)
+		LOG_ERROR("Failed to finalize checkpoint handle");
+}
+
+void cluster_debug(void)
+{
+	struct checkpoint_data *cp;
+	struct clog_cpg *entry;
+	struct clog_request *rq;
+	int i;
+
+	LOG_ERROR("");
+	LOG_ERROR("CLUSTER COMPONENT DEBUGGING::");
+	dm_list_iterate_items(entry, &clog_cpg_list) {
+		LOG_ERROR("%s::", SHORT_UUID(entry->name.value));
+		LOG_ERROR("  lowest_id         : %u", entry->lowest_id);
+		LOG_ERROR("  state             : %s", (entry->state == INVALID) ?
+			  "INVALID" : (entry->state == VALID) ? "VALID" :
+			  (entry->state == LEAVING) ? "LEAVING" : "UNKNOWN");
+		LOG_ERROR("  cpg_state         : %d", entry->cpg_state);
+		LOG_ERROR("  free_me           : %d", entry->free_me);
+		LOG_ERROR("  delay             : %d", entry->delay);
+		LOG_ERROR("  resend_requests   : %d", entry->resend_requests);
+		LOG_ERROR("  checkpoints_needed: %d", entry->checkpoints_needed);
+		for (i = 0, cp = entry->checkpoint_list;
+		     i < MAX_CHECKPOINT_REQUESTERS; i++)
+			if (cp)
+				cp = cp->next;
+			else
+				break;
+		LOG_ERROR("  CKPTs waiting     : %d", i);
+		LOG_ERROR("  Working list:");
+		dm_list_iterate_items(rq, &entry->working_list)
+			LOG_ERROR("  %s/%u", _RQ_TYPE(rq->u_rq.request_type),
+				  rq->u_rq.seq);
+
+		LOG_ERROR("  Startup list:");
+		dm_list_iterate_items(rq, &entry->startup_list)
+			LOG_ERROR("  %s/%u", _RQ_TYPE(rq->u_rq.request_type),
+				  rq->u_rq.seq);
+
+		LOG_ERROR("Command History:");
+		for (i = 0; i < DEBUGGING_HISTORY; i++) {
+			entry->idx++;
+			entry->idx = entry->idx % DEBUGGING_HISTORY;
+			if (entry->debugging[entry->idx][0] == '\0')
+				continue;
+			LOG_ERROR("%d:%d) %s", i, entry->idx,
+				  entry->debugging[entry->idx]);
+		}
+	}
+}
/cvs/lvm2/LVM2/daemons/cmirrord/cluster.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/cluster.h
+++ -	2009-09-02 17:36:49.867018000 +0000
@@ -0,0 +1,57 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#ifndef __CLUSTER_LOG_CLUSTER_DOT_H__
+#define __CLUSTER_LOG_CLUSTER_DOT_H__
+
+#include "libdevmapper.h"
+#include "dm-log-userspace.h"
+
+/*
+ * There is other information in addition to what can
+ * be found in the dm_ulog_request structure that we
+ * need for processing.  'clog_request' is the wrapping
+ * structure we use to make the additional fields
+ * available.
+ */
+struct clog_request {
+	struct dm_list list;
+
+	/*
+	 * 'originator' is the machine from which the requests
+	 * was made.
+	 */
+	uint32_t originator;
+
+	/*
+	 * 'pit_server' is the "point-in-time" server for the
+	 * request.  (I.e.  The machine that was the server at
+	 * the time the request was issued - only important during
+	 * startup.
+	 */
+	uint32_t pit_server;
+
+	/*
+	 * The request from the kernel that is being processed
+	 */
+	struct dm_ulog_request u_rq;
+};
+
+int init_cluster(void);
+void cleanup_cluster(void);
+void cluster_debug(void);
+
+int create_cluster_cpg(char *uuid, uint64_t luid);
+int destroy_cluster_cpg(char *uuid);
+
+int cluster_send(struct clog_request *rq);
+
+#endif /* __CLUSTER_LOG_CLUSTER_DOT_H__ */
/cvs/lvm2/LVM2/daemons/cmirrord/common.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/common.h
+++ -	2009-09-02 17:36:50.022069000 +0000
@@ -0,0 +1,33 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#ifndef __CLUSTER_LOG_COMMON_DOT_H__
+#define __CLUSTER_LOG_COMMON_DOT_H__
+
+/*
+#define EXIT_SUCCESS 0
+#define EXIT_FAILURE 1
+*/
+
+#define EXIT_LOCKFILE              2
+
+#define EXIT_KERNEL_SOCKET         3 /* Failed netlink socket create */
+#define EXIT_KERNEL_BIND           4
+#define EXIT_KERNEL_SETSOCKOPT     5
+
+#define EXIT_CLUSTER_CKPT_INIT     6 /* Failed to init checkpoint */
+
+#define EXIT_QUEUE_NOMEM           7
+
+
+#define DM_ULOG_REQUEST_SIZE 1024
+
+#endif /* __CLUSTER_LOG_COMMON_DOT_H__ */
/cvs/lvm2/LVM2/daemons/cmirrord/functions.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/functions.c
+++ -	2009-09-02 17:36:50.131296000 +0000
@@ -0,0 +1,1863 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <stdint.h>
+#include <errno.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <dirent.h>
+#include <unistd.h>
+#include <signal.h>
+#include <linux/kdev_t.h>
+//#define __USE_GNU /* for O_DIRECT */
+#include <fcntl.h>
+#include <time.h>
+#include "libdevmapper.h"
+#include "dm-log-userspace.h"
+#include "functions.h"
+#include "common.h"
+#include "cluster.h"
+#include "logging.h"
+
+#define BYTE_SHIFT 3
+
+/*
+ * Magic for persistent mirrors: "MiRr"
+ * Following on-disk header information is stolen from
+ * drivers/md/dm-log.c
+ */
+#define MIRROR_MAGIC 0x4D695272
+#define MIRROR_DISK_VERSION 2
+#define LOG_OFFSET 2
+
+#define RESYNC_HISTORY 50
+//static char resync_history[RESYNC_HISTORY][128];
+//static int idx = 0;
+#define LOG_SPRINT(_lc, f, arg...) do {					\
+		lc->idx++;						\
+		lc->idx = lc->idx % RESYNC_HISTORY;			\
+		sprintf(lc->resync_history[lc->idx], f, ## arg);	\
+	} while (0)
+
+struct log_header {
+        uint32_t magic;
+        uint32_t version;
+        uint64_t nr_regions;
+};
+
+struct log_c {
+	struct dm_list list;
+
+	char uuid[DM_UUID_LEN];
+	uint64_t luid;
+
+	time_t delay; /* limits how fast a resume can happen after suspend */
+	int touched;
+	uint32_t region_size;
+	uint32_t region_count;
+	uint64_t sync_count;
+
+	dm_bitset_t clean_bits;
+	dm_bitset_t sync_bits;
+	uint32_t recoverer;
+	uint64_t recovering_region; /* -1 means not recovering */
+	uint64_t skip_bit_warning; /* used to warn if region skipped */
+	int sync_search;
+
+	int resume_override;
+
+	uint32_t block_on_error;
+        enum sync {
+                DEFAULTSYNC,    /* Synchronize if necessary */
+                NOSYNC,         /* Devices known to be already in sync */
+                FORCESYNC,      /* Force a sync to happen */
+        } sync;
+
+	uint32_t state;         /* current operational state of the log */
+
+	struct dm_list mark_list;
+
+	uint32_t recovery_halted;
+	struct recovery_request *recovery_request_list;
+
+	int disk_fd;            /* -1 means no disk log */
+	int log_dev_failed;
+	uint64_t disk_nr_regions;
+	size_t disk_size;       /* size of disk_buffer in bytes */
+	void *disk_buffer;      /* aligned memory for O_DIRECT */
+	int idx;
+	char resync_history[RESYNC_HISTORY][128];
+};
+
+struct mark_entry {
+	struct dm_list list;
+	uint32_t nodeid;
+	uint64_t region;
+};
+
+struct recovery_request {
+	uint64_t region;
+	struct recovery_request *next;
+};
+
+static DM_LIST_INIT(log_list);
+static DM_LIST_INIT(log_pending_list);
+
+static int log_test_bit(dm_bitset_t bs, int bit)
+{
+	return dm_bit(bs, bit);
+}
+
+static void log_set_bit(struct log_c *lc, dm_bitset_t bs, int bit)
+{
+	dm_bit_set(bs, bit);
+	lc->touched = 1;
+}
+
+static void log_clear_bit(struct log_c *lc, dm_bitset_t bs, int bit)
+{
+	dm_bit_clear(bs, bit);
+	lc->touched = 1;
+}
+
+static int find_next_zero_bit(dm_bitset_t bs, int start)
+{
+	while (dm_bit(bs, start++))
+		if (start >= (int)bs[0])
+			return -1;
+
+	return start - 1;
+}
+
+static uint64_t count_bits32(dm_bitset_t bs)
+{
+	int i, size = ((int)bs[0]/DM_BITS_PER_INT + 1);
+	unsigned count = 0;
+
+	for (i = 1; i <= size; i++)
+		count += hweight32(bs[i]);
+
+	return (uint64_t)count;
+}
+
+/*
+ * get_log
+ *
+ * Returns: log if found, NULL otherwise
+ */
+static struct log_c *get_log(const char *uuid, uint64_t luid)
+{
+	struct log_c *lc;
+
+	dm_list_iterate_items(lc, &log_list)
+		if (!strcmp(lc->uuid, uuid) &&
+		    (!luid || (luid == lc->luid)))
+			return lc;
+
+	return NULL;
+}
+
+/*
+ * get_pending_log
+ *
+ * Pending logs are logs that have been 'clog_ctr'ed, but
+ * have not joined the CPG (via clog_resume).
+ *
+ * Returns: log if found, NULL otherwise
+ */
+static struct log_c *get_pending_log(const char *uuid, uint64_t luid)
+{
+	struct log_c *lc;
+
+	dm_list_iterate_items(lc, &log_pending_list)
+		if (!strcmp(lc->uuid, uuid) &&
+		    (!luid || (luid == lc->luid)))
+			return lc;
+
+	return NULL;
+}
+
+static void header_to_disk(struct log_header *mem, struct log_header *disk)
+{
+	memcpy(disk, mem, sizeof(struct log_header));
+}
+
+static void header_from_disk(struct log_header *mem, struct log_header *disk)
+{
+	memcpy(mem, disk, sizeof(struct log_header));
+}
+
+static int rw_log(struct log_c *lc, int do_write)
+{
+	int r;
+
+	r = lseek(lc->disk_fd, 0, SEEK_SET);
+	if (r < 0) {
+		LOG_ERROR("[%s] rw_log:  lseek failure: %s",
+			  SHORT_UUID(lc->uuid), strerror(errno));
+		return -errno;
+	}
+
+	if (do_write) {
+		r = write(lc->disk_fd, lc->disk_buffer, lc->disk_size);
+		if (r < 0) {
+			LOG_ERROR("[%s] rw_log:  write failure: %s",
+				  SHORT_UUID(lc->uuid), strerror(errno));
+			return -EIO; /* Failed disk write */
+		}
+		return 0;
+	}
+
+	/* Read */
+	r = read(lc->disk_fd, lc->disk_buffer, lc->disk_size);
+	if (r < 0)
+		LOG_ERROR("[%s] rw_log:  read failure: %s",
+			  SHORT_UUID(lc->uuid), strerror(errno));
+	if (r != lc->disk_size)
+		return -EIO; /* Failed disk read */
+	return 0;
+}
+
+/*
+ * read_log
+ * @lc
+ *
+ * Valid return codes:
+ *   -EINVAL:  Invalid header, bits not copied
+ *   -EIO:     Unable to read disk log
+ *    0:       Valid header, disk bit -> lc->clean_bits
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int read_log(struct log_c *lc)
+{
+	struct log_header lh;
+	size_t bitset_size;
+
+	memset(&lh, 0, sizeof(struct log_header));
+
+	if (rw_log(lc, 0))
+		return -EIO; /* Failed disk read */
+
+	header_from_disk(&lh, lc->disk_buffer);
+	if (lh.magic != MIRROR_MAGIC)
+		return -EINVAL;
+
+	lc->disk_nr_regions = lh.nr_regions;
+
+	/* Read disk bits into sync_bits */
+	bitset_size = lc->region_count / 8;
+	bitset_size += (lc->region_count % 8) ? 1 : 0;
+	memcpy(lc->clean_bits, lc->disk_buffer + 1024, bitset_size);
+
+	return 0;
+}
+
+/*
+ * write_log
+ * @lc
+ *
+ * Returns: 0 on success, -EIO on failure
+ */
+static int write_log(struct log_c *lc)
+{
+	struct log_header lh;
+	size_t bitset_size;
+
+	lh.magic = MIRROR_MAGIC;
+	lh.version = MIRROR_DISK_VERSION;
+	lh.nr_regions = lc->region_count;
+
+	header_to_disk(&lh, lc->disk_buffer);
+
+	/* Write disk bits from clean_bits */
+	bitset_size = lc->region_count / 8;
+	bitset_size += (lc->region_count % 8) ? 1 : 0;
+	memcpy(lc->disk_buffer + 1024, lc->clean_bits, bitset_size);
+
+	if (rw_log(lc, 1)) {
+		lc->log_dev_failed = 1;
+		return -EIO; /* Failed disk write */
+	}
+	return 0;
+}
+
+static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_path)
+{
+	int r;
+	DIR *dp;
+	struct dirent *dep;
+	struct stat statbuf;
+	int major, minor;
+
+	if (!strstr(major_minor_str, ":")) {
+		r = stat(major_minor_str, &statbuf);
+		if (r)
+			return -errno;
+		if (!S_ISBLK(statbuf.st_mode))
+			return -EINVAL;
+		sprintf(path_rtn, "%s", major_minor_str);
+		return 0;
+	}
+
+	r = sscanf(major_minor_str, "%d:%d", &major, &minor);
+	if (r != 2)
+		return -EINVAL;
+
+	LOG_DBG("Checking /dev/mapper for device %d:%d", major, minor);
+	/* Check /dev/mapper dir */
+	dp = opendir("/dev/mapper");
+	if (!dp)
+		return -ENOENT;
+
+	while ((dep = readdir(dp)) != NULL) {
+		/*
+		 * FIXME: This is racy.  By the time the path is used,
+		 * it may point to something else.  'fstat' will be
+		 * required upon opening to ensure we got what we
+		 * wanted.
+		 */
+
+		sprintf(path_rtn, "/dev/mapper/%s", dep->d_name);
+		stat(path_rtn, &statbuf);
+		if (S_ISBLK(statbuf.st_mode) &&
+		    (major(statbuf.st_rdev) == major) &&
+		    (minor(statbuf.st_rdev) == minor)) {
+			LOG_DBG("  %s: YES", dep->d_name);
+			closedir(dp);
+			return 0;
+		} else {
+			LOG_DBG("  %s: NO", dep->d_name);
+		}
+	}
+
+	closedir(dp);
+
+	LOG_DBG("Path not found for %d/%d", major, minor);
+	LOG_DBG("Creating /dev/mapper/%d-%d", major, minor);
+	sprintf(path_rtn, "/dev/mapper/%d-%d", major, minor);
+	r = mknod(path_rtn, S_IFBLK | S_IRUSR | S_IWUSR, MKDEV(major, minor));
+
+	/*
+	 * If we have to make the path, we unlink it after we open it
+	 */
+	*unlink_path = 1;
+
+	return r ? -errno : 0;
+}
+
+static int _clog_ctr(char *uuid, uint64_t luid,
+		     int argc, char **argv, uint64_t device_size)
+{
+	int i;
+	int r = 0;
+	char *p;
+	uint64_t region_size;
+	uint64_t region_count;
+	struct log_c *lc = NULL;
+	struct log_c *duplicate;
+	enum sync sync = DEFAULTSYNC;
+	uint32_t block_on_error = 0;
+
+	int disk_log = 0;
+	char disk_path[128];
+	int unlink_path = 0;
+	size_t page_size;
+	int pages;
+
+	/* If core log request, then argv[0] will be region_size */
+	if (!strtoll(argv[0], &p, 0) || *p) {
+		disk_log = 1;
+
+		if ((argc < 2) || (argc > 4)) {
+			LOG_ERROR("Too %s arguments to clustered_disk log type",
+				  (argc < 3) ? "few" : "many");
+			r = -EINVAL;
+			goto fail;
+		}
+
+		r = find_disk_path(argv[0], disk_path, &unlink_path);
+		if (r) {
+			LOG_ERROR("Unable to find path to device %s", argv[0]);
+			goto fail;
+		}
+		LOG_DBG("Clustered log disk is %s", disk_path);
+	} else {
+		disk_log = 0;
+
+		if ((argc < 1) || (argc > 3)) {
+			LOG_ERROR("Too %s arguments to clustered_core log type",
+				  (argc < 2) ? "few" : "many");
+			r = -EINVAL;
+			goto fail;
+		}
+	}
+
+	if (!(region_size = strtoll(argv[disk_log], &p, 0)) || *p) {
+		LOG_ERROR("Invalid region_size argument to clustered_%s log type",
+			  (disk_log) ? "disk" : "core");
+		r = -EINVAL;
+		goto fail;
+	}
+
+	region_count = device_size / region_size;
+	if (device_size % region_size) {
+		/*
+		 * I can't remember if device_size must be a multiple
+		 * of region_size, so check it anyway.
+		 */
+		region_count++;
+	}
+
+	for (i = 0; i < argc; i++) {
+		if (!strcmp(argv[i], "sync"))
+			sync = FORCESYNC;
+		else if (!strcmp(argv[i], "nosync"))
+			sync = NOSYNC;
+		else if (!strcmp(argv[i], "block_on_error"))
+			block_on_error = 1;
+	}
+
+	lc = malloc(sizeof(*lc));
+	if (!lc) {
+		LOG_ERROR("Unable to allocate cluster log context");
+		r = -ENOMEM;
+		goto fail;
+	}
+	memset(lc, 0, sizeof(*lc));
+
+	lc->region_size = region_size;
+	lc->region_count = region_count;
+	lc->sync = sync;
+	lc->block_on_error = block_on_error;
+	lc->sync_search = 0;
+	lc->recovering_region = (uint64_t)-1;
+	lc->skip_bit_warning = region_count;
+	lc->disk_fd = -1;
+	lc->log_dev_failed = 0;
+	strncpy(lc->uuid, uuid, DM_UUID_LEN);
+	lc->luid = luid;
+
+	if ((duplicate = get_log(lc->uuid, lc->luid)) ||
+	    (duplicate = get_pending_log(lc->uuid, lc->luid))) {
+		LOG_ERROR("[%s/%llu] Log already exists, unable to create.",
+			  SHORT_UUID(lc->uuid), lc->luid);
+		free(lc);
+		return -EINVAL;
+	}
+
+	dm_list_init(&lc->mark_list);
+
+	lc->clean_bits = dm_bitset_create(NULL, region_count);
+	if (!lc->clean_bits) {
+		LOG_ERROR("Unable to allocate clean bitset");
+		r = -ENOMEM;
+		goto fail;
+	}
+
+	lc->sync_bits = dm_bitset_create(NULL, region_count);
+	if (!lc->sync_bits) {
+		LOG_ERROR("Unable to allocate sync bitset");
+		r = -ENOMEM;
+		goto fail;
+	}
+	if (sync == NOSYNC)
+		dm_bit_set_all(lc->sync_bits);
+
+	lc->sync_count = (sync == NOSYNC) ? region_count : 0;
+	if (disk_log) {
+		page_size = sysconf(_SC_PAGESIZE);
+		pages = ((int)lc->clean_bits[0])/page_size;
+		pages += ((int)lc->clean_bits[0])%page_size ? 1 : 0;
+		pages += 1; /* for header */
+
+		r = open(disk_path, O_RDWR | O_DIRECT);
+		if (r < 0) {
+			LOG_ERROR("Unable to open log device, %s: %s",
+				  disk_path, strerror(errno));
+			r = errno;
+			goto fail;
+		}
+		if (unlink_path)
+			unlink(disk_path);
+
+		lc->disk_fd = r;
+		lc->disk_size = pages * page_size;
+
+		r = posix_memalign(&(lc->disk_buffer), page_size,
+				   lc->disk_size);
+		if (r) {
+			LOG_ERROR("Unable to allocate memory for disk_buffer");
+			goto fail;
+		}
+		memset(lc->disk_buffer, 0, lc->disk_size);
+		LOG_DBG("Disk log ready");
+	}
+
+	dm_list_add(&log_pending_list, &lc->list);
+
+	return 0;
+fail:
+	if (lc) {
+		if (lc->clean_bits)
+			free(lc->clean_bits);
+		if (lc->sync_bits)
+			free(lc->sync_bits);
+		if (lc->disk_buffer)
+			free(lc->disk_buffer);
+		if (lc->disk_fd >= 0)
+			close(lc->disk_fd);
+		free(lc);
+	}
+	return r;
+}
+
+/*
+ * clog_ctr
+ * @rq
+ *
+ * rq->data should contain constructor string as follows:
+ *	<log_type> [disk] <region_size> [[no]sync] <device_len>
+ * The kernel is responsible for adding the <dev_len> argument
+ * to the end; otherwise, we cannot compute the region_count.
+ *
+ * FIXME: Currently relies on caller to fill in rq->error
+ */
+static int clog_dtr(struct dm_ulog_request *rq);
+static int clog_ctr(struct dm_ulog_request *rq)
+{
+	int argc, i, r = 0;
+	char *p, **argv = NULL;
+	char *dev_size_str;
+	uint64_t device_size;
+
+	/* Sanity checks */
+	if (!rq->data_size) {
+		LOG_ERROR("Received constructor request with no data");
+		return -EINVAL;
+	}
+
+	if (strlen(rq->data) > rq->data_size) {
+		LOG_ERROR("Received constructor request with bad data");
+		LOG_ERROR("strlen(rq->data)[%d] != rq->data_size[%llu]",
+			  (int)strlen(rq->data),
+			  (unsigned long long)rq->data_size);
+		LOG_ERROR("rq->data = '%s' [%d]",
+			  rq->data, (int)strlen(rq->data));
+		return -EINVAL;
+	}
+
+	/* Split up args */
+	for (argc = 0, p = rq->data; (p = strstr(p, " ")); p++, argc++)
+		*p = '\0';
+
+	argv = malloc(argc * sizeof(char *));
+	if (!argv)
+		return -ENOMEM;
+
+	p = dev_size_str = rq->data;
+	p += strlen(p) + 1;
+	for (i = 0; i < argc; i++, p = p + strlen(p) + 1)
+		argv[i] = p;
+
+	if (strcmp(argv[0], "clustered_disk") &&
+	    strcmp(argv[0], "clustered_core")) {
+		LOG_ERROR("Unsupported userspace log type, \"%s\"", argv[0]);
+		free(argv);
+		return -EINVAL;
+	}
+
+	if (!(device_size = strtoll(dev_size_str, &p, 0)) || *p) {
+		LOG_ERROR("Invalid device size argument: %s", dev_size_str);
+		free(argv);
+		return -EINVAL;
+	}
+
+	r = _clog_ctr(rq->uuid, rq->luid, argc - 1, argv + 1, device_size);
+
+	/* We join the CPG when we resume */
+
+	/* No returning data */
+	rq->data_size = 0;
+
+	if (r) {
+		LOG_ERROR("Failed to create cluster log (%s)", rq->uuid);
+		for (i = 0; i < argc; i++)
+			LOG_ERROR("argv[%d] = %s", i, argv[i]);
+	}
+	else
+		LOG_DBG("[%s] Cluster log created",
+			SHORT_UUID(rq->uuid));
+
+	free(argv);
+	return r;
+}
+
+/*
+ * clog_dtr
+ * @rq
+ *
+ */
+static int clog_dtr(struct dm_ulog_request *rq)
+{
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (lc) {
+		/*
+		 * The log should not be on the official list.  There
+		 * should have been a suspend first.
+		 */
+		LOG_ERROR("[%s] DTR before SUS: leaving CPG",
+			  SHORT_UUID(rq->uuid));
+		destroy_cluster_cpg(rq->uuid);
+	} else if (!(lc = get_pending_log(rq->uuid, rq->luid))) {
+		LOG_ERROR("clog_dtr called on log that is not official or pending");
+		return -EINVAL;
+	}
+
+	LOG_DBG("[%s] Cluster log removed", SHORT_UUID(lc->uuid));
+
+	dm_list_del(&lc->list);
+	if (lc->disk_fd != -1)
+		close(lc->disk_fd);
+	if (lc->disk_buffer)
+		free(lc->disk_buffer);
+	free(lc->clean_bits);
+	free(lc->sync_bits);
+	free(lc);
+
+	return 0;
+}
+
+/*
+ * clog_presuspend
+ * @rq
+ *
+ */
+static int clog_presuspend(struct dm_ulog_request *rq)
+{
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (lc->touched)
+		LOG_DBG("WARNING: log still marked as 'touched' during suspend");
+
+	lc->recovery_halted = 1;
+
+	return 0;
+}
+
+/*
+ * clog_postsuspend
+ * @rq
+ *
+ */
+static int clog_postsuspend(struct dm_ulog_request *rq)
+{
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	LOG_DBG("[%s] clog_postsuspend: leaving CPG", SHORT_UUID(lc->uuid));
+	destroy_cluster_cpg(rq->uuid);
+
+	lc->state = LOG_SUSPENDED;
+	lc->recovering_region = (uint64_t)-1;
+	lc->recoverer = (uint32_t)-1;
+	lc->delay = time(NULL);
+
+	return 0;
+}
+
+/*
+ * cluster_postsuspend
+ * @rq
+ *
+ */
+int cluster_postsuspend(char *uuid, uint64_t luid)
+{
+	struct log_c *lc = get_log(uuid, luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	LOG_DBG("[%s] clog_postsuspend: finalizing", SHORT_UUID(lc->uuid));
+	lc->resume_override = 0;
+
+	/* move log to pending list */
+	dm_list_del(&lc->list);
+	dm_list_add(&log_pending_list, &lc->list);
+
+	return 0;
+}
+
+/*
+ * clog_resume
+ * @rq
+ *
+ * Does the main work of resuming.
+ */
+static int clog_resume(struct dm_ulog_request *rq)
+{
+	uint32_t i;
+	int commit_log = 0;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	switch (lc->resume_override) {
+	case 1000:
+		LOG_ERROR("[%s] Additional resume issued before suspend",
+			  SHORT_UUID(rq->uuid));
+#ifdef DEBUG
+		kill(getpid(), SIGUSR1);
+#endif
+		return 0;
+	case 0:
+		lc->resume_override = 1000;
+		if (lc->disk_fd == -1) {
+			LOG_DBG("[%s] Master resume.",
+				SHORT_UUID(lc->uuid));
+			goto no_disk;
+		}
+
+		LOG_DBG("[%s] Master resume: reading disk log",
+			SHORT_UUID(lc->uuid));
+		commit_log = 1;
+		break;
+	case 1:
+		LOG_ERROR("Error:: partial bit loading (just sync_bits)");
+		return -EINVAL;
+	case 2:
+		LOG_ERROR("Error:: partial bit loading (just clean_bits)");
+		return -EINVAL;
+	case 3:
+		LOG_DBG("[%s] Non-master resume: bits pre-loaded",
+			SHORT_UUID(lc->uuid));
+		lc->resume_override = 1000;
+		goto out;
+	default:
+		LOG_ERROR("Error:: multiple loading of bits (%d)",
+			  lc->resume_override);
+		return -EINVAL;
+	}
+
+	if (lc->log_dev_failed) {
+		LOG_ERROR("Log device has failed, unable to read bits");
+		rq->error = 0;  /* We can handle this so far */
+		lc->disk_nr_regions = 0;
+	} else
+		rq->error = read_log(lc);
+
+	switch (rq->error) {
+	case 0:
+		if (lc->disk_nr_regions < lc->region_count)
+			LOG_DBG("[%s] Mirror has grown, updating log bits",
+				SHORT_UUID(lc->uuid));
+		else if (lc->disk_nr_regions > lc->region_count)
+			LOG_DBG("[%s] Mirror has shrunk, updating log bits",
+				SHORT_UUID(lc->uuid));
+		break;		
+	case -EINVAL:
+		LOG_DBG("[%s] (Re)initializing mirror log - resync issued.",
+			SHORT_UUID(lc->uuid));
+		lc->disk_nr_regions = 0;
+		break;
+	default:
+		LOG_ERROR("Failed to read disk log");
+		lc->disk_nr_regions = 0;
+		break;
+	}
+
+no_disk:
+	/* If mirror has grown, set bits appropriately */
+	if (lc->sync == NOSYNC)
+		for (i = lc->disk_nr_regions; i < lc->region_count; i++)
+			log_set_bit(lc, lc->clean_bits, i);
+	else
+		for (i = lc->disk_nr_regions; i < lc->region_count; i++)
+			log_clear_bit(lc, lc->clean_bits, i);
+
+	/* Clear any old bits if device has shrunk */
+	for (i = lc->region_count; i % 32; i++)
+		log_clear_bit(lc, lc->clean_bits, i);
+
+	/* copy clean across to sync */
+	dm_bit_copy(lc->sync_bits, lc->clean_bits);
+
+	if (commit_log && (lc->disk_fd >= 0)) {
+		rq->error = write_log(lc);
+		if (rq->error)
+			LOG_ERROR("Failed initial disk log write");
+		else
+			LOG_DBG("Disk log initialized");
+		lc->touched = 0;
+	}
+out:
+	/*
+	 * Clear any old bits if device has shrunk - necessary
+	 * for non-master resume
+	 */
+	for (i = lc->region_count; i % 32; i++) {
+		log_clear_bit(lc, lc->clean_bits, i);
+		log_clear_bit(lc, lc->sync_bits, i);
+	}
+
+	lc->sync_count = count_bits32(lc->sync_bits);
+
+	LOG_SPRINT(lc, "[%s] Initial sync_count = %llu",
+		   SHORT_UUID(lc->uuid), (unsigned long long)lc->sync_count);
+	lc->sync_search = 0;
+	lc->state = LOG_RESUMED;
+	lc->recovery_halted = 0;
+	
+	return rq->error;
+}
+
+/*
+ * local_resume
+ * @rq
+ *
+ * If the log is pending, we must first join the cpg and
+ * put the log in the official list.
+ *
+ */
+int local_resume(struct dm_ulog_request *rq)
+{
+	int r;
+	time_t t;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc) {
+		/* Is the log in the pending list? */
+		lc = get_pending_log(rq->uuid, rq->luid);
+		if (!lc) {
+			LOG_ERROR("clog_resume called on log that is not official or pending");
+			return -EINVAL;
+		}
+
+		t = time(NULL);
+		t -= lc->delay;
+		/*
+		 * This should be considered a temporary fix.  It addresses
+		 * a problem that exists when nodes suspend/resume in rapid
+		 * succession.  While the problem is very rare, it has been
+		 * seen to happen in real-world-like testing.
+		 *
+		 * The problem:
+		 * - Node A joins cluster
+		 * - Node B joins cluster
+		 * - Node A prepares checkpoint
+		 * - Node A gets ready to write checkpoint
+		 * - Node B leaves
+		 * - Node B joins
+		 * - Node A finishes write of checkpoint
+		 * - Node B receives checkpoint meant for previous session
+		 * -- Node B can now be non-coherent
+		 *
+		 * This timer will solve the problem for now, but could be
+		 * replaced by a generation number sent with the resume
+		 * command from the kernel.  The generation number would
+		 * be included in the name of the checkpoint to prevent
+		 * reading stale data.
+		 */
+		if ((t < 3) && (t >= 0))
+			sleep(3 - t);
+
+		/* Join the CPG */
+		r = create_cluster_cpg(rq->uuid, rq->luid);
+		if (r) {
+			LOG_ERROR("clog_resume:  Failed to create cluster CPG");
+			return r;
+		}
+
+		/* move log to official list */
+		dm_list_del(&lc->list);
+		dm_list_add(&log_list, &lc->list);
+	}
+
+	return 0;
+}
+
+/*
+ * clog_get_region_size
+ * @rq
+ *
+ * Since this value doesn't change, the kernel
+ * should not need to talk to server to get this
+ * The function is here for completness
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int clog_get_region_size(struct dm_ulog_request *rq)
+{
+	uint64_t *rtn = (uint64_t *)rq->data;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc && !(lc = get_pending_log(rq->uuid, rq->luid)))
+		return -EINVAL;
+
+	*rtn = lc->region_size;
+	rq->data_size = sizeof(*rtn);
+
+	return 0;
+}
+
+/*
+ * clog_is_clean
+ * @rq
+ *
+ * Returns: 1 if clean, 0 otherwise
+ */
+static int clog_is_clean(struct dm_ulog_request *rq)
+{
+	int64_t *rtn = (int64_t *)rq->data;
+	uint64_t region = *((uint64_t *)(rq->data));
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	*rtn = log_test_bit(lc->clean_bits, region);
+	rq->data_size = sizeof(*rtn);
+
+	return 0;
+}
+
+/*
+ * clog_in_sync
+ * @rq
+ *
+ * We ignore any request for non-block.  That
+ * should be handled elsewhere.  (If the request
+ * has come this far, it has already blocked.)
+ *
+ * Returns: 1 if in-sync, 0 otherwise
+ */
+static int clog_in_sync(struct dm_ulog_request *rq)
+{
+	int64_t *rtn = (int64_t *)rq->data;
+	uint64_t region = *((uint64_t *)(rq->data));
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (region > lc->region_count)
+		return -EINVAL;
+
+	*rtn = log_test_bit(lc->sync_bits, region);
+	if (*rtn)
+		LOG_DBG("[%s] Region is in-sync: %llu",
+			SHORT_UUID(lc->uuid), (unsigned long long)region);
+	else
+		LOG_DBG("[%s] Region is not in-sync: %llu",
+			SHORT_UUID(lc->uuid), (unsigned long long)region);
+
+	rq->data_size = sizeof(*rtn);
+
+	return 0;
+}
+
+/*
+ * clog_flush
+ * @rq
+ *
+ */
+static int clog_flush(struct dm_ulog_request *rq, int server)
+{
+	int r = 0;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+	
+	if (!lc)
+		return -EINVAL;
+
+	if (!lc->touched)
+		return 0;
+
+	/*
+	 * Do the actual flushing of the log only
+	 * if we are the server.
+	 */
+	if (server && (lc->disk_fd >= 0)) {
+		r = rq->error = write_log(lc);
+		if (r)
+			LOG_ERROR("[%s] Error writing to disk log",
+				  SHORT_UUID(lc->uuid));
+		else 
+			LOG_DBG("[%s] Disk log written", SHORT_UUID(lc->uuid));
+	}
+
+	lc->touched = 0;
+
+	return r;
+
+}
+
+/*
+ * mark_region
+ * @lc
+ * @region
+ * @who
+ *
+ * Put a mark region request in the tree for tracking.
+ *
+ * Returns: 0 on success, -EXXX on error
+ */
+static int mark_region(struct log_c *lc, uint64_t region, uint32_t who)
+{
+	int found = 0;
+	struct mark_entry *m;
+
+	dm_list_iterate_items(m, &lc->mark_list)
+		if (m->region == region) {
+			found = 1;
+			if (m->nodeid == who)
+				return 0;
+		}
+
+	if (!found)
+		log_clear_bit(lc, lc->clean_bits, region);
+
+	/*
+	 * Save allocation until here - if there is a failure,
+	 * at least we have cleared the bit.
+	 */
+	m = malloc(sizeof(*m));
+	if (!m) {
+		LOG_ERROR("Unable to allocate space for mark_entry: %llu/%u",
+			  (unsigned long long)region, who);
+		return -ENOMEM;
+	}
+
+	m->nodeid = who;
+	m->region = region;
+	dm_list_add(&lc->mark_list, &m->list);
+
+	return 0;
+}
+
+/*
+ * clog_mark_region
+ * @rq
+ *
+ * rq may contain more than one mark request.  We
+ * can determine the number from the 'data_size' field.
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
+{
+	int r;
+	int count;
+	uint64_t *region;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (rq->data_size % sizeof(uint64_t)) {
+		LOG_ERROR("Bad data size given for mark_region request");
+		return -EINVAL;
+	}
+
+	count = rq->data_size / sizeof(uint64_t);
+	region = (uint64_t *)&rq->data;
+
+	for (; count > 0; count--, region++) {
+		r = mark_region(lc, *region, originator);
+		if (r)
+			return r;
+	}
+
+	rq->data_size = 0;
+
+	return 0;
+}
+
+static int clear_region(struct log_c *lc, uint64_t region, uint32_t who)
+{
+	int other_matches = 0;
+	struct mark_entry *m, *n;
+
+	dm_list_iterate_items_safe(m, n, &lc->mark_list)
+		if (m->region == region) {
+			if (m->nodeid == who) {
+				dm_list_del(&m->list);
+				free(m);
+			} else
+				other_matches = 1;
+		}
+
+	/*
+	 * Clear region if:
+	 *  1) It is in-sync
+	 *  2) There are no other machines that have it marked
+	 */
+	if (!other_matches && log_test_bit(lc->sync_bits, region))
+		log_set_bit(lc, lc->clean_bits, region);
+
+	return 0;
+}
+
+/*
+ * clog_clear_region
+ * @rq
+ *
+ * rq may contain more than one clear request.  We
+ * can determine the number from the 'data_size' field.
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int clog_clear_region(struct dm_ulog_request *rq, uint32_t originator)
+{
+	int r;
+	int count;
+	uint64_t *region;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (rq->data_size % sizeof(uint64_t)) {
+		LOG_ERROR("Bad data size given for clear_region request");
+		return -EINVAL;
+	}
+
+	count = rq->data_size / sizeof(uint64_t);
+	region = (uint64_t *)&rq->data;
+
+	for (; count > 0; count--, region++) {
+		r = clear_region(lc, *region, originator);
+		if (r)
+			return r;
+	}
+
+	rq->data_size = 0;
+
+	return 0;
+}
+
+/*
+ * clog_get_resync_work
+ * @rq
+ *
+ */
+static int clog_get_resync_work(struct dm_ulog_request *rq, uint32_t originator)
+{
+	struct {
+		int64_t i;
+		uint64_t r;
+	} *pkg = (void *)rq->data;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	rq->data_size = sizeof(*pkg);
+	pkg->i = 0;
+
+	if (lc->sync_search >= lc->region_count) {
+		/*
+		 * FIXME: handle intermittent errors during recovery
+		 * by resetting sync_search... but not to many times.
+		 */
+		LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "Recovery finished",
+			   rq->seq, SHORT_UUID(lc->uuid), originator);
+		return 0;
+	}
+
+	if (lc->recovering_region != (uint64_t)-1) {
+		if (lc->recoverer == originator) {
+			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Re-requesting work (%llu)",
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
+				   (unsigned long long)lc->recovering_region);
+			pkg->r = lc->recovering_region;
+			pkg->i = 1;
+			LOG_COND(log_resend_requests, "***** RE-REQUEST *****");
+		} else {
+			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Someone already recovering (%llu)",
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
+				   (unsigned long long)lc->recovering_region);
+		}
+
+		return 0;
+	}
+
+	while (lc->recovery_request_list) {
+		struct recovery_request *del;
+
+		del = lc->recovery_request_list;
+		lc->recovery_request_list = del->next;
+
+		pkg->r = del->region;
+		free(del);
+
+		if (!log_test_bit(lc->sync_bits, pkg->r)) {
+			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Assigning priority resync work (%llu)",
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
+				   (unsigned long long)pkg->r);
+			pkg->i = 1;
+			lc->recovering_region = pkg->r;
+			lc->recoverer = originator;
+			return 0;
+		}
+	}
+
+	pkg->r = find_next_zero_bit(lc->sync_bits,
+				    lc->sync_search);
+
+	if (pkg->r >= lc->region_count) {
+		LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "Resync work complete.",
+			   rq->seq, SHORT_UUID(lc->uuid), originator);
+		return 0;
+	}
+
+	lc->sync_search = pkg->r + 1;
+
+	LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+		   "Assigning resync work (%llu)",
+		   rq->seq, SHORT_UUID(lc->uuid), originator,
+		   (unsigned long long)pkg->r);
+	pkg->i = 1;
+	lc->recovering_region = pkg->r;
+	lc->recoverer = originator;
+
+	return 0;
+}
+
+/*
+ * clog_set_region_sync
+ * @rq
+ */
+static int clog_set_region_sync(struct dm_ulog_request *rq, uint32_t originator)
+{
+	struct {
+		uint64_t region;
+		int64_t in_sync;
+	} *pkg = (void *)rq->data;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	lc->recovering_region = (uint64_t)-1;
+
+	if (pkg->in_sync) {
+		if (log_test_bit(lc->sync_bits, pkg->region)) {
+			LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Region already set (%llu)",
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
+				   (unsigned long long)pkg->region);
+		} else {
+			log_set_bit(lc, lc->sync_bits, pkg->region);
+			lc->sync_count++;
+
+			/* The rest of this section is all for debugging */
+			LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Setting region (%llu)",
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
+				   (unsigned long long)pkg->region);
+			if (pkg->region == lc->skip_bit_warning)
+				lc->skip_bit_warning = lc->region_count;
+
+			if (pkg->region > (lc->skip_bit_warning + 5)) {
+				LOG_ERROR("*** Region #%llu skipped during recovery ***",
+					  (unsigned long long)lc->skip_bit_warning);
+				lc->skip_bit_warning = lc->region_count;
+#ifdef DEBUG
+				kill(getpid(), SIGUSR1);
+#endif
+			}
+
+			if (!log_test_bit(lc->sync_bits,
+					  (pkg->region) ? pkg->region - 1 : 0)) {
+				LOG_SPRINT(lc, "*** Previous bit not set ***");
+				lc->skip_bit_warning = (pkg->region) ?
+					pkg->region - 1 : 0;
+			}
+		}
+	} else if (log_test_bit(lc->sync_bits, pkg->region)) {
+		lc->sync_count--;
+		log_clear_bit(lc, lc->sync_bits, pkg->region);
+		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "Unsetting region (%llu)",
+			   rq->seq, SHORT_UUID(lc->uuid), originator,
+			   (unsigned long long)pkg->region);
+	}
+
+	if (lc->sync_count != count_bits32(lc->sync_bits)) {
+		unsigned long long reset = count_bits32(lc->sync_bits);
+
+		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "sync_count(%llu) != bitmap count(%llu)",
+			   rq->seq, SHORT_UUID(lc->uuid), originator,
+			   (unsigned long long)lc->sync_count, reset);
+#ifdef DEBUG
+		kill(getpid(), SIGUSR1);
+#endif
+		lc->sync_count = reset;
+	}
+
+	if (lc->sync_count > lc->region_count)
+		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "(lc->sync_count > lc->region_count) - this is bad",
+			   rq->seq, SHORT_UUID(lc->uuid), originator);
+
+	rq->data_size = 0;
+	return 0;
+}
+
+/*
+ * clog_get_sync_count
+ * @rq
+ */
+static int clog_get_sync_count(struct dm_ulog_request *rq, uint32_t originator)
+{
+	uint64_t *sync_count = (uint64_t *)rq->data;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	/*
+	 * FIXME: Mirror requires us to be able to ask for
+	 * the sync count while pending... but I don't like
+	 * it because other machines may not be suspended and
+	 * the stored value may not be accurate.
+	 */
+	if (!lc)
+		lc = get_pending_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	*sync_count = lc->sync_count;
+
+	rq->data_size = sizeof(*sync_count);
+
+	if (lc->sync_count != count_bits32(lc->sync_bits)) {
+		unsigned long long reset = count_bits32(lc->sync_bits);
+
+		LOG_SPRINT(lc, "get_sync_count - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "sync_count(%llu) != bitmap count(%llu)",
+			   rq->seq, SHORT_UUID(lc->uuid), originator,
+			   (unsigned long long)lc->sync_count, reset);
+#ifdef DEBUG
+		kill(getpid(), SIGUSR1);
+#endif
+		lc->sync_count = reset;
+	}
+
+	return 0;
+}
+
+static int core_status_info(struct log_c *lc, struct dm_ulog_request *rq)
+{
+	char *data = (char *)rq->data;
+
+	rq->data_size = sprintf(data, "1 clustered_core");
+
+	return 0;
+}
+
+static int disk_status_info(struct log_c *lc, struct dm_ulog_request *rq)
+{
+	char *data = (char *)rq->data;
+	struct stat statbuf;
+
+	if(fstat(lc->disk_fd, &statbuf)) {
+		rq->error = -errno;
+		return -errno;
+	}
+
+	rq->data_size = sprintf(data, "3 clustered_disk %d:%d %c",
+				major(statbuf.st_rdev), minor(statbuf.st_rdev),
+				(lc->log_dev_failed) ? 'D' : 'A');
+
+	return 0;
+}
+
+/*
+ * clog_status_info
+ * @rq
+ *
+ */
+static int clog_status_info(struct dm_ulog_request *rq)
+{
+	int r;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		lc = get_pending_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (lc->disk_fd == -1)
+		r = core_status_info(lc, rq);
+	else
+		r = disk_status_info(lc, rq);
+
+	return r;
+}
+
+static int core_status_table(struct log_c *lc, struct dm_ulog_request *rq)
+{
+	char *data = (char *)rq->data;
+
+	rq->data_size = sprintf(data, "clustered_core %u %s%s ",
+				lc->region_size,
+				(lc->sync == DEFAULTSYNC) ? "" :
+				(lc->sync == NOSYNC) ? "nosync " : "sync ",
+				(lc->block_on_error) ? "block_on_error" : "");
+	return 0;
+}
+
+static int disk_status_table(struct log_c *lc, struct dm_ulog_request *rq)
+{
+	char *data = (char *)rq->data;
+	struct stat statbuf;
+
+	if(fstat(lc->disk_fd, &statbuf)) {
+		rq->error = -errno;
+		return -errno;
+	}
+
+	rq->data_size = sprintf(data, "clustered_disk %d:%d %u %s%s ",
+				major(statbuf.st_rdev), minor(statbuf.st_rdev),
+				lc->region_size,
+				(lc->sync == DEFAULTSYNC) ? "" :
+				(lc->sync == NOSYNC) ? "nosync " : "sync ",
+				(lc->block_on_error) ? "block_on_error" : "");
+	return 0;
+}
+
+/*
+ * clog_status_table
+ * @rq
+ *
+ */
+static int clog_status_table(struct dm_ulog_request *rq)
+{
+	int r;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		lc = get_pending_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (lc->disk_fd == -1)
+		r = core_status_table(lc, rq);
+	else
+		r = disk_status_table(lc, rq);
+
+	return r;
+}
+
+/*
+ * clog_is_remote_recovering
+ * @rq
+ *
+ */
+static int clog_is_remote_recovering(struct dm_ulog_request *rq)
+{
+	uint64_t region = *((uint64_t *)(rq->data));
+	struct {
+		int64_t is_recovering;
+		uint64_t in_sync_hint;
+	} *pkg = (void *)rq->data;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (region > lc->region_count)
+		return -EINVAL;
+
+	if (lc->recovery_halted) {
+		LOG_DBG("[%s] Recovery halted... [not remote recovering]: %llu",
+			SHORT_UUID(lc->uuid), (unsigned long long)region);
+		pkg->is_recovering = 0;
+		pkg->in_sync_hint = lc->region_count; /* none are recovering */
+	} else {
+		pkg->is_recovering = !log_test_bit(lc->sync_bits, region);
+
+		/*
+		 * Remember, 'lc->sync_search' is 1 plus the region
+		 * currently being recovered.  So, we must take off 1
+		 * to account for that; but only if 'sync_search > 1'.
+		 */
+		pkg->in_sync_hint = lc->sync_search ? (lc->sync_search - 1) : 0;
+		LOG_DBG("[%s] Region is %s: %llu",
+			SHORT_UUID(lc->uuid),
+			(region == lc->recovering_region) ?
+			"currently remote recovering" :
+			(pkg->is_recovering) ? "pending remote recovery" :
+			"not remote recovering", (unsigned long long)region);
+	}
+
+	if (pkg->is_recovering &&
+	    (region != lc->recovering_region)) {
+		struct recovery_request *rr;
+
+		/* Already in the list? */
+		for (rr = lc->recovery_request_list; rr; rr = rr->next)
+			if (rr->region == region)
+				goto out;
+
+		/* Failure to allocated simply means we can't prioritize it */
+		rr = malloc(sizeof(*rr));
+		if (!rr)
+			goto out;
+
+		LOG_DBG("[%s] Adding region to priority list: %llu",
+			SHORT_UUID(lc->uuid), (unsigned long long)region);
+		rr->region = region;
+		rr->next = lc->recovery_request_list;
+		lc->recovery_request_list = rr;
+	}
+
+out:
+
+	rq->data_size = sizeof(*pkg);
+
+	return 0;	
+}
+
+
+/*
+ * do_request
+ * @rq: the request
+ * @server: is this request performed by the server
+ *
+ * An inability to perform this function will return an error
+ * from this function.  However, an inability to successfully
+ * perform the request will fill in the 'rq->error' field.
+ *
+ * Returns: 0 on success, -EXXX on error
+ */
+int do_request(struct clog_request *rq, int server)
+{
+	int r;
+
+	if (!rq)
+		return 0;
+
+	if (rq->u_rq.error)
+		LOG_DBG("Programmer error: rq struct has error set");
+
+	switch (rq->u_rq.request_type) {
+	case DM_ULOG_CTR:
+		r = clog_ctr(&rq->u_rq);
+		break;
+	case DM_ULOG_DTR:
+		r = clog_dtr(&rq->u_rq);
+		break;
+	case DM_ULOG_PRESUSPEND:
+		r = clog_presuspend(&rq->u_rq);
+		break;
+	case DM_ULOG_POSTSUSPEND:
+		r = clog_postsuspend(&rq->u_rq);
+		break;
+	case DM_ULOG_RESUME:
+		r = clog_resume(&rq->u_rq);
+		break;
+	case DM_ULOG_GET_REGION_SIZE:
+		r = clog_get_region_size(&rq->u_rq);
+		break;
+	case DM_ULOG_IS_CLEAN:
+		r = clog_is_clean(&rq->u_rq);
+		break;
+	case DM_ULOG_IN_SYNC:
+		r = clog_in_sync(&rq->u_rq);
+		break;
+	case DM_ULOG_FLUSH:
+		r = clog_flush(&rq->u_rq, server);
+		break;
+	case DM_ULOG_MARK_REGION:
+		r = clog_mark_region(&rq->u_rq, rq->originator);
+		break;
+	case DM_ULOG_CLEAR_REGION:
+		r = clog_clear_region(&rq->u_rq, rq->originator);
+		break;
+	case DM_ULOG_GET_RESYNC_WORK:
+		r = clog_get_resync_work(&rq->u_rq, rq->originator);
+		break;
+	case DM_ULOG_SET_REGION_SYNC:
+		r = clog_set_region_sync(&rq->u_rq, rq->originator);
+		break;
+	case DM_ULOG_GET_SYNC_COUNT:
+		r = clog_get_sync_count(&rq->u_rq, rq->originator);
+		break;
+	case DM_ULOG_STATUS_INFO:
+		r = clog_status_info(&rq->u_rq);
+		break;
+	case DM_ULOG_STATUS_TABLE:
+		r = clog_status_table(&rq->u_rq);
+		break;
+	case DM_ULOG_IS_REMOTE_RECOVERING:
+		r = clog_is_remote_recovering(&rq->u_rq);
+		break;
+	default:
+		LOG_ERROR("Unknown request");
+		r = rq->u_rq.error = -EINVAL;
+		break;
+	}
+
+	if (r && !rq->u_rq.error)
+		rq->u_rq.error = r;
+	else if (r != rq->u_rq.error)
+		LOG_DBG("Warning:  error from function != rq->u_rq.error");
+
+	if (rq->u_rq.error && rq->u_rq.data_size) {
+		/* Make sure I'm handling errors correctly above */
+		LOG_DBG("Programmer error: rq->u_rq.error && rq->u_rq.data_size");
+		rq->u_rq.data_size = 0;
+	}
+
+	return 0;
+}
+
+static void print_bits(char *buf, int size, int print)
+{
+	int i;
+	char outbuf[128];
+
+	memset(outbuf, 0, sizeof(outbuf));
+
+	for (i = 0; i < size; i++) {
+		if (!(i % 16)) {
+			if (outbuf[0] != '\0') {
+				if (print)
+					LOG_PRINT("%s", outbuf);
+				else
+					LOG_DBG("%s", outbuf);
+			}
+			memset(outbuf, 0, sizeof(outbuf));
+			sprintf(outbuf, "[%3d - %3d]", i, i+15);
+		}
+		sprintf(outbuf + strlen(outbuf), " %.2X", (unsigned char)buf[i]);
+	}
+	if (outbuf[0] != '\0') {
+		if (print)
+			LOG_PRINT("%s", outbuf);
+		else
+			LOG_DBG("%s", outbuf);
+	}
+}
+
+/* int store_bits(const char *uuid, const char *which, char **buf)*/
+int push_state(const char *uuid, uint64_t luid,
+	       const char *which, char **buf, uint32_t debug_who)
+{
+	int bitset_size;
+	struct log_c *lc;
+
+	if (*buf)
+		LOG_ERROR("store_bits: *buf != NULL");
+
+	lc = get_log(uuid, luid);
+	if (!lc) {
+		LOG_ERROR("store_bits: No log found for %s", uuid);
+		return -EINVAL;
+	}
+
+	if (!strcmp(which, "recovering_region")) {
+		*buf = malloc(64); /* easily handles the 2 written numbers */
+		if (!*buf)
+			return -ENOMEM;
+		sprintf(*buf, "%llu %u", (unsigned long long)lc->recovering_region,
+			lc->recoverer);
+
+		LOG_SPRINT(lc, "CKPT SEND - SEQ#=X, UUID=%s, nodeid = %u:: "
+			   "recovering_region=%llu, recoverer=%u, sync_count=%llu",
+			   SHORT_UUID(lc->uuid), debug_who,
+			   (unsigned long long)lc->recovering_region,
+			   lc->recoverer,
+			   (unsigned long long)count_bits32(lc->sync_bits));
+		return 64;
+	}
+
+	/* Size in 'int's */
+	bitset_size = ((int)lc->clean_bits[0]/DM_BITS_PER_INT) + 1;
+
+	/* Size in bytes */
+	bitset_size *= 4;
+
+	*buf = malloc(bitset_size);
+
+	if (!*buf) {
+		LOG_ERROR("store_bits: Unable to allocate memory");
+		return -ENOMEM;
+	}
+
+	if (!strncmp(which, "sync_bits", 9)) {
+		memcpy(*buf, lc->sync_bits + 1, bitset_size);
+		LOG_DBG("[%s] storing sync_bits (sync_count = %llu):",
+			SHORT_UUID(uuid), (unsigned long long)
+			count_bits32(lc->sync_bits));
+		print_bits(*buf, bitset_size, 0);
+	} else if (!strncmp(which, "clean_bits", 9)) {
+		memcpy(*buf, lc->clean_bits + 1, bitset_size);
+		LOG_DBG("[%s] storing clean_bits:", SHORT_UUID(lc->uuid));
+		print_bits(*buf, bitset_size, 0);
+	}
+
+	return bitset_size;
+}
+
+/*int load_bits(const char *uuid, const char *which, char *buf, int size)*/
+int pull_state(const char *uuid, uint64_t luid,
+	       const char *which, char *buf, int size)
+{
+	int bitset_size;
+	struct log_c *lc;
+
+	if (!buf)
+		LOG_ERROR("pull_state: buf == NULL");
+
+	lc = get_log(uuid, luid);
+	if (!lc) {
+		LOG_ERROR("pull_state: No log found for %s", uuid);
+		return -EINVAL;
+	}
+
+	if (!strncmp(which, "recovering_region", 17)) {
+		sscanf(buf, "%llu %u", (unsigned long long *)&lc->recovering_region,
+		       &lc->recoverer);
+		LOG_SPRINT(lc, "CKPT INIT - SEQ#=X, UUID=%s, nodeid = X:: "
+			   "recovering_region=%llu, recoverer=%u",
+			   SHORT_UUID(lc->uuid),
+			   (unsigned long long)lc->recovering_region, lc->recoverer);
+		return 0;
+	}
+
+	/* Size in 'int's */
+	bitset_size = ((int)lc->clean_bits[0]/DM_BITS_PER_INT) + 1;
+
+	/* Size in bytes */
+	bitset_size *= 4;
+
+	if (bitset_size != size) {
+		LOG_ERROR("pull_state(%s): bad bitset_size (%d vs %d)",
+			  which, size, bitset_size);
+		return -EINVAL;
+	}
+
+	if (!strncmp(which, "sync_bits", 9)) {
+		lc->resume_override += 1;
+		memcpy(lc->sync_bits + 1, buf, bitset_size);
+		LOG_DBG("[%s] loading sync_bits (sync_count = %llu):",
+			SHORT_UUID(lc->uuid),(unsigned long long)
+			count_bits32(lc->sync_bits));
+		print_bits((char *)lc->sync_bits, bitset_size, 0);
+	} else if (!strncmp(which, "clean_bits", 9)) {
+		lc->resume_override += 2;
+		memcpy(lc->clean_bits + 1, buf, bitset_size);
+		LOG_DBG("[%s] loading clean_bits:", SHORT_UUID(lc->uuid));
+		print_bits((char *)lc->clean_bits, bitset_size, 0);
+	}
+
+	return 0;
+}
+
+int log_get_state(struct dm_ulog_request *rq)
+{
+	struct log_c *lc;
+
+	lc = get_log(rq->uuid, rq->luid);
+	if (!lc)
+		return -EINVAL;
+
+	return lc->state;
+}
+
+/*
+ * log_status
+ *
+ * Returns: 1 if logs are still present, 0 otherwise
+ */
+int log_status(void)
+{
+	if (!dm_list_empty(&log_list) || !dm_list_empty(&log_pending_list))
+		return 1;
+
+	return 0;
+}
+
+void log_debug(void)
+{
+	struct log_c *lc;
+	uint64_t r;
+	int i;
+
+	LOG_ERROR("");
+	LOG_ERROR("LOG COMPONENT DEBUGGING::");
+	LOG_ERROR("Official log list:");
+	LOG_ERROR("Pending log list:");
+	dm_list_iterate_items(lc, &log_pending_list) {
+		LOG_ERROR("%s", lc->uuid);
+		LOG_ERROR("sync_bits:");
+		print_bits((char *)lc->sync_bits, (int)lc->sync_bits[0], 1);
+		LOG_ERROR("clean_bits:");
+		print_bits((char *)lc->clean_bits, (int)lc->sync_bits[0], 1);
+	}
+
+	dm_list_iterate_items(lc, &log_list) {
+		LOG_ERROR("%s", lc->uuid);
+		LOG_ERROR("  recoverer        : %u", lc->recoverer);
+		LOG_ERROR("  recovering_region: %llu",
+			  (unsigned long long)lc->recovering_region);
+		LOG_ERROR("  recovery_halted  : %s", (lc->recovery_halted) ?
+			  "YES" : "NO");
+		LOG_ERROR("sync_bits:");
+		print_bits((char *)lc->sync_bits, (int)lc->sync_bits[0], 1);
+		LOG_ERROR("clean_bits:");
+		print_bits((char *)lc->clean_bits, (int)lc->sync_bits[0], 1);
+
+		LOG_ERROR("Validating %s::", SHORT_UUID(lc->uuid));
+		r = find_next_zero_bit(lc->sync_bits, 0);
+		LOG_ERROR("  lc->region_count = %llu",
+			  (unsigned long long)lc->region_count);
+		LOG_ERROR("  lc->sync_count = %llu",
+			  (unsigned long long)lc->sync_count);
+		LOG_ERROR("  next zero bit  = %llu",
+			  (unsigned long long)r);
+		if ((r > lc->region_count) ||
+		    ((r == lc->region_count) && (lc->sync_count > lc->region_count))) {
+			LOG_ERROR("ADJUSTING SYNC_COUNT");
+			lc->sync_count = lc->region_count;
+		}
+
+		LOG_ERROR("Resync request history:");
+		for (i = 0; i < RESYNC_HISTORY; i++) {
+			lc->idx++;
+			lc->idx = lc->idx % RESYNC_HISTORY;
+			if (lc->resync_history[lc->idx][0] == '\0')
+				continue;
+			LOG_ERROR("%d:%d) %s", i, lc->idx,
+				  lc->resync_history[lc->idx]);
+		}
+	}
+}
/cvs/lvm2/LVM2/daemons/cmirrord/functions.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/functions.h
+++ -	2009-09-02 17:36:50.248174000 +0000
@@ -0,0 +1,34 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#ifndef __CLOG_FUNCTIONS_DOT_H__
+#define __CLOG_FUNCTIONS_DOT_H__
+
+#include "dm-log-userspace.h"
+#include "cluster.h"
+
+#define LOG_RESUMED   1
+#define LOG_SUSPENDED 2
+
+int local_resume(struct dm_ulog_request *rq);
+int cluster_postsuspend(char *, uint64_t);
+
+int do_request(struct clog_request *rq, int server);
+int push_state(const char *uuid, uint64_t luid,
+	       const char *which, char **buf, uint32_t debug_who);
+int pull_state(const char *uuid, uint64_t luid,
+	       const char *which, char *buf, int size);
+
+int log_get_state(struct dm_ulog_request *rq);
+int log_status(void);
+void log_debug(void);
+
+#endif /* __CLOG_FUNCTIONS_DOT_H__ */
/cvs/lvm2/LVM2/daemons/cmirrord/link_mon.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/link_mon.c
+++ -	2009-09-02 17:36:50.331530000 +0000
@@ -0,0 +1,149 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#include <stdlib.h>
+#include <errno.h>
+#include <poll.h>
+
+#include "logging.h"
+
+struct link_callback {
+	int fd;
+	char *name;
+	void *data;
+	int (*callback)(void *data);
+
+	struct link_callback *next;
+};
+
+static int used_pfds = 0;
+static int free_pfds = 0;
+static struct pollfd *pfds = NULL;
+static struct link_callback *callbacks = NULL;
+
+int links_register(int fd, char *name, int (*callback)(void *data), void *data)
+{
+	int i;
+	struct link_callback *lc;
+
+	for (i = 0; i < used_pfds; i++) {
+		if (fd == pfds[i].fd) {
+			LOG_ERROR("links_register: Duplicate file descriptor");
+			return -EINVAL;
+		}
+	}
+
+	lc = malloc(sizeof(*lc));
+	if (!lc)
+		return -ENOMEM;
+
+	lc->fd = fd;
+	lc->name = name;
+	lc->data = data;
+	lc->callback = callback;
+
+	if (!free_pfds) {
+		struct pollfd *tmp;
+		tmp = realloc(pfds, sizeof(struct pollfd) * ((used_pfds*2) + 1));
+		if (!tmp) {
+			free(lc);
+			return -ENOMEM;
+		}
+		
+		pfds = tmp;
+		free_pfds = used_pfds + 1;
+	}
+
+	free_pfds--;
+	pfds[used_pfds].fd = fd;
+	pfds[used_pfds].events = POLLIN;
+	pfds[used_pfds].revents = 0;
+	used_pfds++;
+
+	lc->next = callbacks;
+	callbacks = lc;
+	LOG_DBG("Adding %s/%d", lc->name, lc->fd);
+	LOG_DBG(" used_pfds = %d, free_pfds = %d",
+		used_pfds, free_pfds);
+
+	return 0;
+}
+
+int links_unregister(int fd)
+{
+	int i;
+	struct link_callback *p, *c;
+
+	for (i = 0; i < used_pfds; i++)
+		if (fd == pfds[i].fd) {
+			/* entire struct is copied (overwritten) */
+			pfds[i] = pfds[used_pfds - 1];
+			used_pfds--;
+			free_pfds++;
+		}
+
+	for (p = NULL, c = callbacks; c; p = c, c = c->next)
+		if (fd == c->fd) {
+			LOG_DBG("Freeing up %s/%d", c->name, c->fd);
+			LOG_DBG(" used_pfds = %d, free_pfds = %d",
+				used_pfds, free_pfds);
+			if (p)
+				p->next = c->next;
+			else
+				callbacks = c->next;
+			free(c);
+			break;
+		}
+
+	return 0;
+}
+
+int links_monitor(void)
+{
+	int i, r;
+
+	for (i = 0; i < used_pfds; i++) {
+		pfds[i].revents = 0;
+	}
+
+	r = poll(pfds, used_pfds, -1);
+	if (r <= 0)
+		return r;
+
+	r = 0;
+	/* FIXME: handle POLLHUP */
+	for (i = 0; i < used_pfds; i++)
+		if (pfds[i].revents & POLLIN) {
+			LOG_DBG("Data ready on %d", pfds[i].fd);
+				
+			/* FIXME: Add this back return 1;*/
+			r++;
+		}
+
+	return r;
+}
+
+int links_issue_callbacks(void)
+{
+	int i;
+	struct link_callback *lc;
+
+	for (i = 0; i < used_pfds; i++)
+		if (pfds[i].revents & POLLIN)
+			for (lc = callbacks; lc; lc = lc->next)
+				if (pfds[i].fd == lc->fd) {
+					LOG_DBG("Issuing callback on %s/%d",
+						lc->name, lc->fd);
+					lc->callback(lc->data);
+					break;
+				}
+	return 0;
+}
/cvs/lvm2/LVM2/daemons/cmirrord/link_mon.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/link_mon.h
+++ -	2009-09-02 17:36:50.427384000 +0000
@@ -0,0 +1,20 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#ifndef __LINK_MON_DOT_H__
+#define __LINK_MON_DOT_H__
+
+int links_register(int fd, char *name, int (*callback)(void *data), void *data);
+int links_unregister(int fd);
+int links_monitor(void);
+int links_issue_callbacks(void);
+
+#endif /* __LINK_MON_DOT_H__ */
/cvs/lvm2/LVM2/daemons/cmirrord/local.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/local.c
+++ -	2009-09-02 17:36:50.518618000 +0000
@@ -0,0 +1,420 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#include <unistd.h>
+#include <errno.h>
+#include <string.h>
+#include <stdint.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/poll.h>
+#include <linux/connector.h>
+#include <linux/netlink.h>
+
+#include "dm-log-userspace.h"
+#include "functions.h"
+#include "cluster.h"
+#include "common.h"
+#include "logging.h"
+#include "link_mon.h"
+#include "local.h"
+
+#ifndef CN_IDX_DM
+#warning Kernel should be at least 2.6.31
+#define CN_IDX_DM                       0x7     /* Device Mapper */
+#define CN_VAL_DM_USERSPACE_LOG         0x1
+#endif
+
+static int cn_fd;  /* Connector (netlink) socket fd */
+static char recv_buf[2048];
+static char send_buf[2048];
+
+
+/* FIXME: merge this function with kernel_send_helper */
+static int kernel_ack(uint32_t seq, int error)
+{
+	int r;
+	struct nlmsghdr *nlh = (struct nlmsghdr *)send_buf;
+	struct cn_msg *msg = NLMSG_DATA(nlh);
+
+	if (error < 0) {
+		LOG_ERROR("Programmer error: error codes must be positive");
+		return -EINVAL;
+	}
+
+	memset(send_buf, 0, sizeof(send_buf));
+
+	nlh->nlmsg_seq = 0;
+	nlh->nlmsg_pid = getpid();
+	nlh->nlmsg_type = NLMSG_DONE;
+	nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct cn_msg));
+	nlh->nlmsg_flags = 0;
+
+	msg->len = 0;
+	msg->id.idx = CN_IDX_DM;
+	msg->id.val = CN_VAL_DM_USERSPACE_LOG;
+	msg->seq = seq;
+	msg->ack = error;
+
+	r = send(cn_fd, nlh, NLMSG_LENGTH(sizeof(struct cn_msg)), 0);
+	/* FIXME: do better error processing */
+	if (r <= 0)
+		return -EBADE;
+
+	return 0;
+}
+
+
+/*
+ * kernel_recv
+ * @rq: the newly allocated request from kernel
+ *
+ * Read requests from the kernel and allocate space for the new request.
+ * If there is no request from the kernel, *rq is NULL.
+ *
+ * This function is not thread safe due to returned stack pointer.  In fact,
+ * the returned pointer must not be in-use when this function is called again.
+ *
+ * Returns: 0 on success, -EXXX on error
+ */
+static int kernel_recv(struct clog_request **rq)
+{
+	int r = 0;
+	int len;
+	struct cn_msg *msg;
+	struct dm_ulog_request *u_rq;
+
+	*rq = NULL;
+	memset(recv_buf, 0, sizeof(recv_buf));
+
+	len = recv(cn_fd, recv_buf, sizeof(recv_buf), 0);
+	if (len < 0) {
+		LOG_ERROR("Failed to recv message from kernel");
+		r = -errno;
+		goto fail;
+	}
+
+	switch (((struct nlmsghdr *)recv_buf)->nlmsg_type) {
+	case NLMSG_ERROR:
+		LOG_ERROR("Unable to recv message from kernel: NLMSG_ERROR");
+		r = -EBADE;
+		goto fail;
+	case NLMSG_DONE:
+		msg = (struct cn_msg *)NLMSG_DATA((struct nlmsghdr *)recv_buf);
+		len -= sizeof(struct nlmsghdr);
+
+		if (len < sizeof(struct cn_msg)) {
+			LOG_ERROR("Incomplete request from kernel received");
+			r = -EBADE;
+			goto fail;
+		}
+
+		if (msg->len > DM_ULOG_REQUEST_SIZE) {
+			LOG_ERROR("Not enough space to receive kernel request (%d/%d)",
+				  msg->len, DM_ULOG_REQUEST_SIZE);
+			r = -EBADE;
+			goto fail;
+		}
+
+		if (!msg->len)
+			LOG_ERROR("Zero length message received");
+
+		len -= sizeof(struct cn_msg);
+
+		if (len < msg->len)
+			LOG_ERROR("len = %d, msg->len = %d", len, msg->len);
+
+		msg->data[msg->len] = '\0'; /* Cleaner way to ensure this? */
+		u_rq = (struct dm_ulog_request *)msg->data;
+
+		if (!u_rq->request_type) {
+			LOG_DBG("Bad transmission, requesting resend [%u]",
+				msg->seq);
+			r = -EAGAIN;
+
+			if (kernel_ack(msg->seq, EAGAIN)) {
+				LOG_ERROR("Failed to NACK kernel transmission [%u]",
+					  msg->seq);
+				r = -EBADE;
+			}
+		}
+
+		/*
+		 * Now we've got sizeof(struct cn_msg) + sizeof(struct nlmsghdr)
+		 * worth of space that precede the request structure from the
+		 * kernel.  Since that space isn't going to be used again, we
+		 * can take it for our purposes; rather than allocating a whole
+		 * new structure and doing a memcpy.
+		 *
+		 * We should really make sure 'clog_request' doesn't grow
+		 * beyond what is available to us, but we need only check it
+		 * once... perhaps at compile time?
+		 */
+//		*rq = container_of(u_rq, struct clog_request, u_rq);
+		*rq = (void *)u_rq -
+			(sizeof(struct clog_request) -
+			 sizeof(struct dm_ulog_request));
+
+		/* Clear the wrapper container fields */
+		memset(*rq, 0, (void *)u_rq - (void *)(*rq));
+		break;
+	default:
+		LOG_ERROR("Unknown nlmsg_type");
+		r = -EBADE;
+	}
+
+fail:
+	if (r)
+		*rq = NULL;
+
+	return (r == -EAGAIN) ? 0 : r;
+}
+
+static int kernel_send_helper(void *data, int out_size)
+{
+	int r;
+	struct nlmsghdr *nlh;
+	struct cn_msg *msg;
+
+	memset(send_buf, 0, sizeof(send_buf));
+
+	nlh = (struct nlmsghdr *)send_buf;
+	nlh->nlmsg_seq = 0;  /* FIXME: Is this used? */
+	nlh->nlmsg_pid = getpid();
+	nlh->nlmsg_type = NLMSG_DONE;
+	nlh->nlmsg_len = NLMSG_LENGTH(out_size + sizeof(struct cn_msg));
+	nlh->nlmsg_flags = 0;
+
+	msg = NLMSG_DATA(nlh);
+	memcpy(msg->data, data, out_size);
+	msg->len = out_size;
+	msg->id.idx = CN_IDX_DM;
+	msg->id.val = CN_VAL_DM_USERSPACE_LOG;
+	msg->seq = 0;
+
+	r = send(cn_fd, nlh, NLMSG_LENGTH(out_size + sizeof(struct cn_msg)), 0);
+	/* FIXME: do better error processing */
+	if (r <= 0)
+		return -EBADE;
+
+	return 0;
+}
+
+/*
+ * do_local_work
+ *
+ * Any processing errors are placed in the 'rq'
+ * structure to be reported back to the kernel.
+ * It may be pointless for this function to
+ * return an int.
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int do_local_work(void *data)
+{
+	int r;
+	struct clog_request *rq;
+	struct dm_ulog_request *u_rq = NULL;
+
+	r = kernel_recv(&rq);
+	if (r)
+		return r;
+
+	if (!rq)
+		return 0;
+
+	u_rq = &rq->u_rq;
+	LOG_DBG("[%s]  Request from kernel received: [%s/%u]",
+		SHORT_UUID(u_rq->uuid), RQ_TYPE(u_rq->request_type),
+		u_rq->seq);
+	switch (u_rq->request_type) {
+	case DM_ULOG_CTR:
+	case DM_ULOG_DTR:
+	case DM_ULOG_GET_REGION_SIZE:
+	case DM_ULOG_IN_SYNC:
+	case DM_ULOG_GET_SYNC_COUNT:
+	case DM_ULOG_STATUS_INFO:
+	case DM_ULOG_STATUS_TABLE:
+	case DM_ULOG_PRESUSPEND:
+		/* We do not specify ourselves as server here */
+		r = do_request(rq, 0);
+		if (r)
+			LOG_DBG("Returning failed request to kernel [%s]",
+				RQ_TYPE(u_rq->request_type));
+		r = kernel_send(u_rq);
+		if (r)
+			LOG_ERROR("Failed to respond to kernel [%s]",
+				  RQ_TYPE(u_rq->request_type));
+			
+		break;
+	case DM_ULOG_RESUME:
+		/*
+		 * Resume is a special case that requires a local
+		 * component to join the CPG, and a cluster component
+		 * to handle the request.
+		 */
+		r = local_resume(u_rq);
+		if (r) {
+			LOG_DBG("Returning failed request to kernel [%s]",
+				RQ_TYPE(u_rq->request_type));
+			r = kernel_send(u_rq);
+			if (r)
+				LOG_ERROR("Failed to respond to kernel [%s]",
+					  RQ_TYPE(u_rq->request_type));
+			break;
+		}
+		/* ELSE, fall through */
+	case DM_ULOG_IS_CLEAN:
+	case DM_ULOG_FLUSH:
+	case DM_ULOG_MARK_REGION:
+	case DM_ULOG_GET_RESYNC_WORK:
+	case DM_ULOG_SET_REGION_SYNC:
+	case DM_ULOG_IS_REMOTE_RECOVERING:
+	case DM_ULOG_POSTSUSPEND:
+		r = cluster_send(rq);
+		if (r) {
+			u_rq->data_size = 0;
+			u_rq->error = r;
+			kernel_send(u_rq);
+		}
+
+		break;
+	case DM_ULOG_CLEAR_REGION:
+		r = kernel_ack(u_rq->seq, 0);
+
+		r = cluster_send(rq);
+		if (r) {
+			/*
+			 * FIXME: store error for delivery on flush
+			 *        This would allow us to optimize MARK_REGION
+			 *        too.
+			 */
+		}
+
+		break;
+	default:
+		LOG_ERROR("Invalid log request received (%u), ignoring.",
+			  u_rq->request_type);
+
+		return 0;
+	}
+
+	if (r && !u_rq->error)
+		u_rq->error = r;
+
+	return r;
+}
+
+/*
+ * kernel_send
+ * @u_rq: result to pass back to kernel
+ *
+ * This function returns the u_rq structure
+ * (containing the results) to the kernel.
+ * It then frees the structure.
+ *
+ * WARNING: should the structure be freed if
+ * there is an error?  I vote 'yes'.  If the
+ * kernel doesn't get the response, it should
+ * resend the request.
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+int kernel_send(struct dm_ulog_request *u_rq)
+{
+	int r;
+	int size;
+
+	if (!u_rq)
+		return -EINVAL;
+
+	size = sizeof(struct dm_ulog_request) + u_rq->data_size;
+
+	if (!u_rq->data_size && !u_rq->error) {
+		/* An ACK is all that is needed */
+
+		/* FIXME: add ACK code */
+	} else if (size > DM_ULOG_REQUEST_SIZE) {
+		/*
+		 * If we gotten here, we've already overrun
+		 * our allotted space somewhere.
+		 *
+		 * We must do something, because the kernel
+		 * is waiting for a response.
+		 */
+		LOG_ERROR("Not enough space to respond to server");
+		u_rq->error = -ENOSPC;
+		size = sizeof(struct dm_ulog_request);
+	}
+
+	r = kernel_send_helper(u_rq, size);
+	if (r)
+		LOG_ERROR("Failed to send msg to kernel.");
+
+	return r;
+}
+
+/*
+ * init_local
+ *
+ * Initialize kernel communication socket (netlink)
+ *
+ * Returns: 0 on success, values from common.h on failure
+ */
+int init_local(void)
+{
+	int r = 0;
+	int opt;
+	struct sockaddr_nl addr;
+
+	cn_fd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_CONNECTOR);
+	if (cn_fd < 0)
+		return EXIT_KERNEL_SOCKET;
+
+	/* memset to fix valgrind complaint */
+	memset(&addr, 0, sizeof(struct sockaddr_nl));
+
+	addr.nl_family = AF_NETLINK;
+	addr.nl_groups = CN_IDX_DM;
+	addr.nl_pid = 0;
+
+	r = bind(cn_fd, (struct sockaddr *) &addr, sizeof(addr));
+	if (r < 0) {
+		close(cn_fd);
+		return EXIT_KERNEL_BIND;
+	}
+
+	opt = addr.nl_groups;
+	r = setsockopt(cn_fd, 270, NETLINK_ADD_MEMBERSHIP, &opt, sizeof(opt));
+	if (r) {
+		close(cn_fd);
+		return EXIT_KERNEL_SETSOCKOPT;
+	}
+
+	/*
+	r = fcntl(cn_fd, F_SETFL, FNDELAY);
+	*/
+
+	links_register(cn_fd, "local", do_local_work, NULL);
+
+	return 0;
+}
+
+/*
+ * cleanup_local
+ *
+ * Clean up before exiting
+ */
+void cleanup_local(void)
+{
+	links_unregister(cn_fd);
+	close(cn_fd);
+}
/cvs/lvm2/LVM2/daemons/cmirrord/local.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/local.h
+++ -	2009-09-02 17:36:50.602679000 +0000
@@ -0,0 +1,20 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#ifndef __CLUSTER_LOG_LOCAL_DOT_H__
+#define __CLUSTER_LOG_LOCAL_DOT_H__
+
+int init_local(void);
+void cleanup_local(void);
+
+int kernel_send(struct dm_ulog_request *rq);
+
+#endif /* __CLUSTER_LOG_LOCAL_DOT_H__ */
/cvs/lvm2/LVM2/daemons/cmirrord/logging.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/logging.c
+++ -	2009-09-02 17:36:50.684002000 +0000
@@ -0,0 +1,58 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#include <stdio.h>
+#include <syslog.h>
+
+char *__rq_types_off_by_one[] = {
+	"DM_ULOG_CTR",
+	"DM_ULOG_DTR",
+	"DM_ULOG_PRESUSPEND",
+	"DM_ULOG_POSTSUSPEND",
+	"DM_ULOG_RESUME",
+	"DM_ULOG_GET_REGION_SIZE",
+	"DM_ULOG_IS_CLEAN",
+	"DM_ULOG_IN_SYNC",
+	"DM_ULOG_FLUSH",
+	"DM_ULOG_MARK_REGION",
+	"DM_ULOG_CLEAR_REGION",
+	"DM_ULOG_GET_RESYNC_WORK",
+	"DM_ULOG_SET_REGION_SYNC",
+	"DM_ULOG_GET_SYNC_COUNT",
+	"DM_ULOG_STATUS_INFO",
+	"DM_ULOG_STATUS_TABLE",
+	"DM_ULOG_IS_REMOTE_RECOVERING",
+	NULL
+};
+
+int log_tabbing = 0;
+int log_is_open = 0;
+
+/*
+ * Variables for various conditional logging
+ */
+#ifdef MEMB
+int log_membership_change = 1;
+#else
+int log_membership_change = 0;
+#endif
+
+#ifdef CKPT
+int log_checkpoint = 1;
+#else
+int log_checkpoint = 0;
+#endif
+
+#ifdef RESEND
+int log_resend_requests = 1;
+#else
+int log_resend_requests = 0;
+#endif
/cvs/lvm2/LVM2/daemons/cmirrord/logging.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/logging.h
+++ -	2009-09-02 17:36:50.768903000 +0000
@@ -0,0 +1,72 @@
+/*
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
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
+#ifndef __CLUSTER_LOG_LOGGING_DOT_H__
+#define __CLUSTER_LOG_LOGGING_DOT_H__
+
+#include <stdio.h>
+#include <syslog.h>
+
+/* SHORT_UUID - print last 8 chars of a string */
+#define SHORT_UUID(x) (strlen(x) > 8) ? ((x) + (strlen(x) - 8)) : (x)
+
+extern char *__rq_types_off_by_one[];
+#define RQ_TYPE(x) __rq_types_off_by_one[(x) - 1]
+
+extern int log_tabbing;
+extern int log_is_open;
+extern int log_membership_change;
+extern int log_checkpoint;
+extern int log_resend_requests;
+
+#define LOG_OPEN(ident, option, facility) do { \
+		openlog(ident, option, facility); \
+		log_is_open = 1;		  \
+	} while (0)
+
+#define LOG_CLOSE(void) do { \
+		log_is_open = 0; \
+		closelog();	 \
+	} while (0)
+
+#define LOG_OUTPUT(level, f, arg...) do {				\
+		int __i;						\
+		char __buffer[16];					\
+		FILE *fp = (level > LOG_NOTICE) ? stderr : stdout;	\
+		if (log_is_open) {					\
+			for (__i = 0; (__i < log_tabbing) && (__i < 15); __i++) \
+				__buffer[__i] = '\t';			\
+			__buffer[__i] = '\0';				\
+			syslog(level, "%s" f "\n", __buffer, ## arg);	\
+		} else {						\
+			for (__i = 0; __i < log_tabbing; __i++)		\
+				fprintf(fp, "\t");			\
+			fprintf(fp, f "\n", ## arg);			\
+		}							\
+	} while (0)
+
+
+#ifdef DEBUG
+#define LOG_DBG(f, arg...) LOG_OUTPUT(LOG_DEBUG, f, ## arg)
+#else /* DEBUG */
+#define LOG_DBG(f, arg...)
+#endif /* DEBUG */
+
+#define LOG_COND(__X, f, arg...) do {\
+		if (__X) { 	     \
+			LOG_OUTPUT(LOG_NOTICE, f, ## arg); \
+		} \
+	} while (0)
+#define LOG_PRINT(f, arg...) LOG_OUTPUT(LOG_NOTICE, f, ## arg)
+#define LOG_ERROR(f, arg...) LOG_OUTPUT(LOG_ERR, f, ## arg)
+
+#endif /* __CLUSTER_LOG_LOGGING_DOT_H__ */


