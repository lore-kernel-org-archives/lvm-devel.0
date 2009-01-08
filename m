From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 8 Jan 2009 17:12:35 -0000
Subject: LVM2/daemons/clogd Makefile clogd.c cluster.c ...
Message-ID: <20090108171235.10348.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-01-08 17:12:33

Added files:
	daemons/clogd  : Makefile clogd.c cluster.c cluster.h common.h 
	                 functions.c functions.h link_mon.c link_mon.h 
	                 list.h local.c local.h logging.c logging.h 

Log message:
	Initial import of the cluster log daemon from the 'cluster' repository.
	
	There is a rudimentary make file in place so people can build by hand
	from 'LVM2/daemons/clogd'.  It is not hooked into the main build system
	yet.  I am checking this in to provide people better access to the
	source code.
	
	There is still work to be done to make better use of existing code in
	the LVM repository.  (list.h could be removed in favor of existing list
	implementations, for example.  Logging might also be removed in favor
	of what is already in the tree.)
	
	I will probably defer updating WHATS_NEW_DM until this code is linked
	into the main build system (unless otherwise instructed).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/Makefile.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/clogd.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/common.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/link_mon.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/link_mon.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/list.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/daemons/clogd/Makefile,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/Makefile
+++ -	2009-01-08 17:12:34.194791000 +0000
@@ -0,0 +1,77 @@
+###############################################################################
+###############################################################################
+##
+##  Copyright (C) 2009 Red Hat, Inc.  All rights reserved.
+##
+##  This copyrighted material is made available to anyone wishing to use,
+##  modify, copy, or redistribute it subject to the terms and conditions
+##  of the GNU General Public License v.2.
+##
+###############################################################################
+###############################################################################
+
+SOURCES = clogd.c cluster.c functions.c link_mon.c local.c logging.c
+
+TARGET = $(shell if [ ! -e /usr/include/linux/dm-clog-tfr.h ]; then \
+		echo 'no_clogd_kernel_headers'; \
+	elif [ ! -e /usr/include/linux/ext2_fs.h ]; then \
+		echo 'no_e2fsprogs_devel'; \
+	elif [ ! -e /usr/include/openais/saCkpt.h ]; then \
+		echo 'no_openais_devel'; \
+	else \
+		echo 'clogd'; \
+	fi)
+
+ifneq ($(DEBUG), )
+CFLAGS += -DDEBUG
+endif
+
+ifneq ($(MEMB), )
+CFLAGS += -DMEMB
+endif
+
+ifneq ($(CKPT), )
+CFLAGS += -DCKPT
+endif
+
+ifneq ($(RESEND), )
+CFLAGS += -DRESEND
+endif
+
+CFLAGS += -g
+
+LDFLAGS += $(shell if [ -e /usr/lib64/openais ]; then \
+		echo '-L/usr/lib64/openais -L/usr/lib64'; \
+	else \
+		echo '-L/usr/lib/openais -L/usr/lib'; \
+	fi)
+LDFLAGS += -lcpg -lSaCkpt -lext2fs
+
+all: ${TARGET}
+
+clogd: ${SOURCES}
+	${CC} ${CFLAGS} -o $@ $^ ${LDFLAGS}
+
+no_clogd_kernel_headers:
+	echo "Unable to find clogd kernel headers"
+	exit 1
+
+no_e2fsprogs_devel:
+	echo "Unable to find ext2fs kernel headers."
+	echo "Install 'e2fsprogs-devel'?"
+	exit 1
+
+no_openais_devel:
+	echo "Unable to find openAIS headers."
+	echo "http://sources.redhat.com/cluster/wiki/"
+	exit 1
+
+install: clogd
+	install -d /usr/sbin
+	install clogd /usr/sbin
+
+uninstall:
+	rm /usr/sbin/clogd
+
+clean:
+	rm -f *.o clogd *~
/cvs/lvm2/LVM2/daemons/clogd/clogd.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/clogd.c
+++ -	2009-01-08 17:12:34.322915000 +0000
@@ -0,0 +1,283 @@
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
+#include <linux/dm-clog-tfr.h>
+#include <linux/dm-ioctl.h>
+
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
+static void set_priority(void);
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
+	/* set_priority(); -- let's try to do w/o this */
+
+	LOG_PRINT("Starting clogd:");
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
+		case EXIT_KERNEL_TFR_SOCKET:
+			LOG_ERROR("Unable to create netlink socket");
+			break;
+		case EXIT_KERNEL_TFR_BIND:
+			LOG_ERROR("Unable to bind to netlink socket");
+			break;
+		case EXIT_KERNEL_TFR_SETSOCKOPT:
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
+	LOG_OPEN("clogd", LOG_PID, LOG_DAEMON);
+
+	if (create_lockfile("/var/run/clogd.pid"))
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
+
+static void set_priority(void)
+{
+        struct sched_param sched_param;
+        int res;
+
+        res = sched_get_priority_max(SCHED_RR);
+        if (res != -1) {
+                sched_param.sched_priority = res;
+                res = sched_setscheduler(0, SCHED_RR, &sched_param);
+	}
+
+	if (res == -1)
+		LOG_ERROR("Unable to set SCHED_RR priority.");
+}
/cvs/lvm2/LVM2/daemons/clogd/cluster.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/cluster.c
+++ -	2009-01-08 17:12:34.436162000 +0000
@@ -0,0 +1,1551 @@
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
+#include "linux/dm-clog-tfr.h"
+#include "list.h"
+#include "functions.h"
+#include "local.h"
+#include "common.h"
+#include "logging.h"
+#include "link_mon.h"
+#include "cluster.h"
+
+/* Open AIS error codes */
+#define str_ais_error(x) \
+	((x) == SA_AIS_OK) ? "SA_AIS_OK" : \
+	((x) == SA_AIS_ERR_LIBRARY) ? "SA_AIS_ERR_LIBRARY" : \
+	((x) == SA_AIS_ERR_VERSION) ? "SA_AIS_ERR_VERSION" : \
+	((x) == SA_AIS_ERR_INIT) ? "SA_AIS_ERR_INIT" : \
+	((x) == SA_AIS_ERR_TIMEOUT) ? "SA_AIS_ERR_TIMEOUT" : \
+	((x) == SA_AIS_ERR_TRY_AGAIN) ? "SA_AIS_ERR_TRY_AGAIN" : \
+	((x) == SA_AIS_ERR_INVALID_PARAM) ? "SA_AIS_ERR_INVALID_PARAM" : \
+	((x) == SA_AIS_ERR_NO_MEMORY) ? "SA_AIS_ERR_NO_MEMORY" : \
+	((x) == SA_AIS_ERR_BAD_HANDLE) ? "SA_AIS_ERR_BAD_HANDLE" : \
+	((x) == SA_AIS_ERR_BUSY) ? "SA_AIS_ERR_BUSY" : \
+	((x) == SA_AIS_ERR_ACCESS) ? "SA_AIS_ERR_ACCESS" : \
+	((x) == SA_AIS_ERR_NOT_EXIST) ? "SA_AIS_ERR_NOT_EXIST" : \
+	((x) == SA_AIS_ERR_NAME_TOO_LONG) ? "SA_AIS_ERR_NAME_TOO_LONG" : \
+	((x) == SA_AIS_ERR_EXIST) ? "SA_AIS_ERR_EXIST" : \
+	((x) == SA_AIS_ERR_NO_SPACE) ? "SA_AIS_ERR_NO_SPACE" : \
+	((x) == SA_AIS_ERR_INTERRUPT) ? "SA_AIS_ERR_INTERRUPT" : \
+	((x) == SA_AIS_ERR_NAME_NOT_FOUND) ? "SA_AIS_ERR_NAME_NOT_FOUND" : \
+	((x) == SA_AIS_ERR_NO_RESOURCES) ? "SA_AIS_ERR_NO_RESOURCES" : \
+	((x) == SA_AIS_ERR_NOT_SUPPORTED) ? "SA_AIS_ERR_NOT_SUPPORTED" : \
+	((x) == SA_AIS_ERR_BAD_OPERATION) ? "SA_AIS_ERR_BAD_OPERATION" : \
+	((x) == SA_AIS_ERR_FAILED_OPERATION) ? "SA_AIS_ERR_FAILED_OPERATION" : \
+	((x) == SA_AIS_ERR_MESSAGE_ERROR) ? "SA_AIS_ERR_MESSAGE_ERROR" : \
+	((x) == SA_AIS_ERR_QUEUE_FULL) ? "SA_AIS_ERR_QUEUE_FULL" : \
+	((x) == SA_AIS_ERR_QUEUE_NOT_AVAILABLE) ? "SA_AIS_ERR_QUEUE_NOT_AVAILABLE" : \
+	((x) == SA_AIS_ERR_BAD_FLAGS) ? "SA_AIS_ERR_BAD_FLAGS" : \
+	((x) == SA_AIS_ERR_TOO_BIG) ? "SA_AIS_ERR_TOO_BIG" : \
+	((x) == SA_AIS_ERR_NO_SECTIONS) ? "SA_AIS_ERR_NO_SECTIONS" : \
+	"ais_error_unknown"
+
+#define DM_CLOG_RESPONSE 0x1000 /* in last byte of 32-bit value */
+#define DM_CLOG_CHECKPOINT_READY 21
+#define DM_CLOG_MEMBER_JOIN      22
+
+#define _RQ_TYPE(x) \
+	((x) == DM_CLOG_CHECKPOINT_READY) ? "DM_CLOG_CHECKPOINT_READY": \
+	((x) == DM_CLOG_MEMBER_JOIN) ? "DM_CLOG_MEMBER_JOIN": \
+	RQ_TYPE((x) & ~DM_CLOG_RESPONSE)
+
+static uint32_t my_cluster_id = 0xDEAD;
+static SaCkptHandleT ckpt_handle = 0;
+static SaCkptCallbacksT callbacks = { 0, 0 };
+static SaVersionT version = { 'B', 1, 1 };
+
+#define DEBUGGING_HISTORY 50
+static char debugging[DEBUGGING_HISTORY][128];
+static int idx = 0;
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
+	struct list_head list;
+
+	uint32_t lowest_id;
+	cpg_handle_t handle;
+	struct cpg_name name;
+
+	/* Are we the first, or have we received checkpoint? */
+	int state;
+	int cpg_state;  /* FIXME: debugging */
+	int free_me;
+	int delay;
+	int resend_requests;
+	struct list_head startup_list;
+	struct list_head working_list;
+
+	int checkpoints_needed;
+	uint32_t checkpoint_requesters[MAX_CHECKPOINT_REQUESTERS];
+	struct checkpoint_data *checkpoint_list;
+};
+
+/* FIXME: Need lock for this */
+static struct list_head clog_cpg_list;
+
+/*
+ * cluster_send
+ * @tfr
+ *
+ * Returns: 0 on success, -Exxx on error
+ */
+int cluster_send(struct clog_tfr *tfr)
+{
+	int r;
+	int count=0;
+	int found;
+	struct iovec iov;
+	struct clog_cpg *entry, *tmp;
+
+	list_for_each_entry_safe(entry, tmp, &clog_cpg_list, list)
+		if (!strncmp(entry->name.value, tfr->uuid, CPG_MAX_NAME_LENGTH)) {
+			found = 1;
+			break;
+		}
+
+	if (!found) {
+		tfr->error = -ENOENT;
+		return -ENOENT;
+	}
+
+	iov.iov_base = tfr;
+	iov.iov_len = sizeof(struct clog_tfr) + tfr->data_size;
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
+				  SHORT_UUID(tfr->uuid), count, str_ais_error(r));
+		else if ((count < 100) && !(count % 10))
+			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s",
+				  SHORT_UUID(tfr->uuid), count, str_ais_error(r));
+		else if ((count < 1000) && !(count % 100))
+			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s",
+				  SHORT_UUID(tfr->uuid), count, str_ais_error(r));
+		else if ((count < 10000) && !(count % 1000))
+			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s - "
+				  "OpenAIS not handling the load?",
+				  SHORT_UUID(tfr->uuid), count, str_ais_error(r));
+		usleep(1000);
+	} while (1);
+
+	if (r == CPG_OK)
+		return 0;
+
+	/* error codes found in openais/cpg.h */
+	LOG_ERROR("cpg_mcast_joined error: %s", str_ais_error(r));
+
+	tfr->error = -EBADE;
+	return -EBADE;
+}
+
+static struct clog_tfr *get_matching_tfr(struct clog_tfr *t, struct list_head *l)
+{
+	struct clog_tfr *match;
+	struct list_head *p, *n;
+
+	list_for_each_safe(p, n, l) {
+		match = (struct clog_tfr *)p;
+		if (match->seq == t->seq) {
+			list_del_init(p);
+			return match;
+		}
+	}
+	return NULL;
+}
+
+static char tfr_buffer[DM_CLOG_TFR_SIZE];
+static int handle_cluster_request(struct clog_cpg *entry,
+				  struct clog_tfr *tfr, int server)
+{
+	int r = 0;
+	struct clog_tfr *t = (struct clog_tfr *)tfr_buffer;
+
+	/*
+	 * We need a separate clog_tfr struct, one that can carry
+	 * a return payload.  Otherwise, the memory address after
+	 * tfr will be altered - leading to problems
+	 */
+	memset(t, 0, DM_CLOG_TFR_SIZE);
+	memcpy(t, tfr, sizeof(struct clog_tfr) + tfr->data_size);
+
+	/*
+	 * With resumes, we only handle our own.
+	 * Resume is a special case that requires
+	 * local action (to set up CPG), followed by
+	 * a cluster action to co-ordinate reading
+	 * the disk and checkpointing
+	 */
+	if ((t->request_type != DM_CLOG_RESUME) ||
+	    (t->originator == my_cluster_id))
+		r = do_request(t, server);
+
+	if (server &&
+	    (t->request_type != DM_CLOG_CLEAR_REGION) &&
+	    (t->request_type != DM_CLOG_POSTSUSPEND)) {
+		t->request_type |= DM_CLOG_RESPONSE;
+
+		/*
+		 * Errors from previous functions are in the tfr struct.
+		 */
+		r = cluster_send(t);
+		if (r < 0)
+			LOG_ERROR("cluster_send failed: %s", strerror(-r));
+	}
+
+	return r;
+}
+
+static int handle_cluster_response(struct clog_cpg *entry, struct clog_tfr *tfr)
+{
+	int r = 0;
+	struct clog_tfr *orig_tfr;
+
+	/*
+	 * If I didn't send it, then I don't care about the response
+	 */
+	if (tfr->originator != my_cluster_id)
+		return 0;
+
+	tfr->request_type &= ~DM_CLOG_RESPONSE;
+	orig_tfr = get_matching_tfr(tfr, &entry->working_list);
+
+	if (!orig_tfr) {
+		struct list_head *p, *n;
+		struct clog_tfr *t;
+
+		/* Unable to find match for response */
+
+		LOG_ERROR("[%s] No match for cluster response: %s:%u",
+			  SHORT_UUID(tfr->uuid),
+			  _RQ_TYPE(tfr->request_type), tfr->seq);
+
+		LOG_ERROR("Current local list:");
+		if (list_empty(&entry->working_list))
+			LOG_ERROR("   [none]");
+
+		list_for_each_safe(p, n, &entry->working_list) {
+			t = (struct clog_tfr *)p;
+			LOG_ERROR("   [%s]  %s:%u", SHORT_UUID(t->uuid),
+				  _RQ_TYPE(t->request_type), t->seq);
+		}
+
+		return -EINVAL;
+	}
+
+	if (log_resp_rec > 0) {
+		LOG_COND(log_resend_requests,
+			 "[%s] Response received to %s/#%u",
+			 SHORT_UUID(tfr->uuid), _RQ_TYPE(tfr->request_type),
+			 tfr->seq);
+		log_resp_rec--;
+	}
+
+	/* FIXME: Ensure memcpy cannot explode */
+	memcpy(orig_tfr, tfr, sizeof(*tfr) + tfr->data_size);
+
+	r = kernel_send(orig_tfr);
+	if (r)
+		LOG_ERROR("Failed to send response to kernel");
+
+	free(orig_tfr);
+	return r;
+}
+
+static struct clog_cpg *find_clog_cpg(cpg_handle_t handle)
+{
+	struct clog_cpg *match, *tmp;
+
+	list_for_each_entry_safe(match, tmp, &clog_cpg_list, list) {
+		if (match->handle == handle)
+			return match;
+	}
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
+	new->bitmap_size = push_state(entry->name.value, "clean_bits",
+				      &new->clean_bits);
+	if (new->bitmap_size <= 0) {
+		LOG_ERROR("Failed to store clean_bits to checkpoint for node %u",
+			  new->requester);
+		free(new);
+		return NULL;
+	}
+
+	new->bitmap_size = push_state(entry->name.value,
+				      "sync_bits", &new->sync_bits);
+	if (new->bitmap_size <= 0) {
+		LOG_ERROR("Failed to store sync_bits to checkpoint for node %u",
+			  new->requester);
+		free(new->clean_bits);
+		free(new);
+		return NULL;
+	}
+
+	r = push_state(entry->name.value, "recovering_region", &new->recovering_region);
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
+	struct clog_tfr *tfr;
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
+	tfr = malloc(DM_CLOG_TFR_SIZE);
+	if (!tfr) {
+		LOG_ERROR("export_checkpoint: Unable to allocate transfer structs");
+		return -ENOMEM;
+	}
+	memset(tfr, 0, sizeof(*tfr));
+
+	INIT_LIST_HEAD((struct list_head *)&tfr->private);
+	tfr->request_type = DM_CLOG_CHECKPOINT_READY;
+	tfr->originator = cp->requester;  /* FIXME: hack to overload meaning of originator */
+	strncpy(tfr->uuid, cp->uuid, CPG_MAX_NAME_LENGTH);
+
+	r = cluster_send(tfr);
+	if (r)
+		LOG_ERROR("Failed to send checkpoint ready notice: %s",
+			  strerror(-r));
+
+	free(tfr);
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
+			if (pull_state(entry->name.value,
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
+static void do_checkpoints(struct clog_cpg *entry)
+{
+	struct checkpoint_data *cp;
+
+	for (cp = entry->checkpoint_list; cp;) {
+		LOG_COND(log_checkpoint,
+			 "[%s] Checkpoint data available for node %u",
+			 SHORT_UUID(entry->name.value), cp->requester);
+
+		/*
+		 * FIXME: Check return code.  Could send failure
+		 * notice in tfr in export_checkpoint function
+		 * by setting tfr->error
+		 */
+		switch (export_checkpoint(cp)) {
+		case -EEXIST:
+			LOG_COND(log_checkpoint,
+				 "[%s] Checkpoint for %u already handled",
+				 SHORT_UUID(entry->name.value), cp->requester);
+		case 0:
+			entry->checkpoint_list = cp->next;
+			free_checkpoint(cp);
+			cp = entry->checkpoint_list;
+			break;
+		default:
+			/* FIXME: Skipping will cause list corruption */
+			LOG_ERROR("[%s] Failed to export checkpoint for %u",
+				  SHORT_UUID(entry->name.value), cp->requester);
+		}
+	}
+}
+
+static int resend_requests(struct clog_cpg *entry)
+{
+	int r = 0;
+	struct list_head *p, *n;
+	struct clog_tfr *tfr;
+
+	if (!entry->resend_requests || entry->delay)
+		return 0;
+
+	if (entry->state != VALID)
+		return 0;
+
+	entry->resend_requests = 0;
+
+	list_for_each_safe(p, n, &entry->working_list) {
+		list_del_init(p);
+		tfr = (struct clog_tfr *)p;
+
+		if (strcmp(entry->name.value, tfr->uuid)) {
+			LOG_ERROR("[%s]  Stray request from another log (%s)",
+				  SHORT_UUID(entry->name.value),
+				  SHORT_UUID(tfr->uuid));
+			free(tfr);
+			continue;
+		}
+
+		switch (tfr->request_type) {
+		case DM_CLOG_RESUME:
+			/* We are only concerned about this request locally */
+		case DM_CLOG_SET_REGION_SYNC:
+			/*
+			 * Some requests simply do not need to be resent.
+			 * If it is a request that just changes log state,
+			 * then it doesn't need to be resent (everyone makes
+			 * updates).
+			 */
+			LOG_COND(log_resend_requests,
+				 "[%s] Skipping resend of %s/#%u...",
+				 SHORT_UUID(entry->name.value),
+				 _RQ_TYPE(tfr->request_type), tfr->seq);
+			idx++;
+			idx = idx % DEBUGGING_HISTORY;
+			sprintf(debugging[idx], "###  No resend: [%s] %s/%u ###",
+				SHORT_UUID(entry->name.value), _RQ_TYPE(tfr->request_type),
+				tfr->seq);
+			tfr->data_size = 0;
+			kernel_send(tfr);
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
+				 _RQ_TYPE(tfr->request_type),
+				 tfr->seq, entry->lowest_id);
+			idx++;
+			idx = idx % DEBUGGING_HISTORY;
+			sprintf(debugging[idx], "***  Resending: [%s] %s/%u ***",
+				SHORT_UUID(entry->name.value), _RQ_TYPE(tfr->request_type),
+				tfr->seq);
+			r = cluster_send(tfr);
+			if (r < 0)
+				LOG_ERROR("Failed resend");
+		}
+		free(tfr);
+	}
+
+	return r;
+}
+
+static int do_cluster_work(void *data)
+{
+	int r = SA_AIS_OK;
+	struct clog_cpg *entry, *tmp;
+
+	list_for_each_entry_safe(entry, tmp, &clog_cpg_list, list) {
+		r = cpg_dispatch(entry->handle, CPG_DISPATCH_ALL);
+		if (r != SA_AIS_OK)
+			LOG_ERROR("cpg_dispatch failed: %s", str_ais_error(r));
+
+		if (entry->free_me) {
+			free(entry);
+			continue;
+		}
+		do_checkpoints(entry);
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
+	struct list_head *p, *n;
+	struct clog_tfr *tfr = NULL;
+	struct checkpoint_data *new;
+
+	list_for_each_safe(p, n, &entry->startup_list) {
+		list_del_init(p);
+		tfr = (struct clog_tfr *)p;
+		if (tfr->request_type == DM_CLOG_MEMBER_JOIN) {
+			new = prepare_checkpoint(entry, tfr->originator);
+			if (!new) {
+				/*
+				 * FIXME: Need better error handling.  Other nodes
+				 * will be trying to send the checkpoint too, and we
+				 * must continue processing the list; so report error
+				 * but continue.
+				 */
+				LOG_ERROR("Failed to prepare checkpoint for %u!!!",
+					  tfr->originator);
+				free(tfr);
+				continue;
+			}
+			LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u",
+				 SHORT_UUID(entry->name.value), tfr->originator);
+			new->next = entry->checkpoint_list;
+			entry->checkpoint_list = new;
+		} else {
+			LOG_DBG("[%s] Processing delayed request: %s",
+				SHORT_UUID(tfr->uuid), _RQ_TYPE(tfr->request_type));
+			i_was_server = (tfr->error == my_cluster_id) ? 1 : 0;
+			tfr->error = 0;
+			r = handle_cluster_request(entry, tfr, i_was_server);
+
+			if (r)
+				/*
+				 * FIXME: If we error out here, we will never get
+				 * another opportunity to retry these requests
+				 */
+				LOG_ERROR("Error while processing delayed CPG message");
+		}
+		free(tfr);
+	}
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
+	struct clog_tfr *tfr = msg;
+	struct clog_tfr *tmp_tfr = NULL;
+	struct clog_cpg *match;
+
+	match = find_clog_cpg(handle);
+	if (!match) {
+		LOG_ERROR("Unable to find clog_cpg for cluster message");
+		return;
+	}
+
+	if ((nodeid == my_cluster_id) &&
+	    !(tfr->request_type & DM_CLOG_RESPONSE) &&
+	    (tfr->request_type != DM_CLOG_CLEAR_REGION) &&
+	    (tfr->request_type != DM_CLOG_CHECKPOINT_READY)) {
+		tmp_tfr = malloc(DM_CLOG_TFR_SIZE);
+		if (!tmp_tfr) {
+			/*
+			 * FIXME: It may be possible to continue... but we
+			 * would not be able to resend any messages that might
+			 * be necessary during membership changes
+			 */
+			LOG_ERROR("[%s] Unable to record request: -ENOMEM",
+				  SHORT_UUID(tfr->uuid));
+			return;
+		}
+		memcpy(tmp_tfr, tfr, sizeof(*tfr) + tfr->data_size);
+		list_add_tail((struct list_head *)&tmp_tfr->private, &match->working_list);
+	}
+
+	if (tfr->request_type == DM_CLOG_POSTSUSPEND) {
+		/*
+		 * If the server (lowest_id) indicates it is leaving,
+		 * then we must resend any outstanding requests.  However,
+		 * we do not want to resend them if the next server in
+		 * line is in the process of leaving.
+		 */
+		if (nodeid == my_cluster_id) {
+			LOG_COND(log_resend_requests, "[%s] I am leaving.1.....",
+				 SHORT_UUID(tfr->uuid));
+		} else {
+			if (nodeid < my_cluster_id) {
+				if (nodeid == match->lowest_id) {
+					struct list_head *p, *n;
+					
+					match->resend_requests = 1;
+					LOG_COND(log_resend_requests, "[%s] %u is leaving, resend required%s",
+						 SHORT_UUID(tfr->uuid), nodeid,
+						 (list_empty(&match->working_list)) ? " -- working_list empty": "");
+			
+					list_for_each_safe(p, n, &match->working_list) {
+						tmp_tfr = (struct clog_tfr *)p;
+					
+						LOG_COND(log_resend_requests,
+							 "[%s]                %s/%u",
+							 SHORT_UUID(tmp_tfr->uuid),
+							 _RQ_TYPE(tmp_tfr->request_type), tmp_tfr->seq);
+					}
+				}
+
+				match->delay++;
+				LOG_COND(log_resend_requests, "[%s] %u is leaving, delay = %d",
+					 SHORT_UUID(tfr->uuid), nodeid, match->delay);
+			}
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
+	if (tfr->request_type == DM_CLOG_CHECKPOINT_READY) {
+		if (my_cluster_id == tfr->originator) {
+			/* Redundant checkpoints ignored if match->valid */
+			if (import_checkpoint(match, (match->state != INVALID))) {
+				LOG_ERROR("[%s] Failed to import checkpoint from %u",
+					  SHORT_UUID(tfr->uuid), nodeid);
+				/* Could we retry? */
+				goto out;
+			} else if (match->state == INVALID) {
+				LOG_COND(log_checkpoint,
+					 "[%s] Checkpoint data received from %u.  Log is now valid",
+					 SHORT_UUID(match->name.value), nodeid);
+				match->state = VALID;
+
+				flush_startup_list(match);
+			}
+		}
+		goto out;
+	}
+
+	/*
+	 * If the log is now valid, we can queue the checkpoints
+	 */
+	for (i = match->checkpoints_needed; i; ) {
+		struct checkpoint_data *new;
+
+		i--;
+		new = prepare_checkpoint(match, match->checkpoint_requesters[i]);
+		if (!new) {
+			/* FIXME: Need better error handling */
+			LOG_ERROR("[%s] Failed to prepare checkpoint for %u!!!",
+				  SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
+			break;
+		}
+		LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u*",
+			 SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
+		match->checkpoints_needed--;
+
+		new->next = match->checkpoint_list;
+		match->checkpoint_list = new;
+	}		
+
+	if (tfr->request_type & DM_CLOG_RESPONSE) {
+		response = 1;
+		r = handle_cluster_response(match, tfr);
+	} else {
+		tfr->originator = nodeid;
+
+		if (match->state == LEAVING) {
+			LOG_ERROR("[%s]  Ignoring %s from %u.  Reason: I'm leaving",
+				  SHORT_UUID(tfr->uuid), _RQ_TYPE(tfr->request_type),
+				  tfr->originator);
+			goto out;
+		}
+
+		if (match->state == INVALID) {
+			LOG_DBG("Log not valid yet, storing request");
+			tmp_tfr = malloc(DM_CLOG_TFR_SIZE);
+			if (!tmp_tfr) {
+				LOG_ERROR("cpg_message_callback:  Unable to"
+					  " allocate transfer structs");
+				r = -ENOMEM; /* FIXME: Better error #? */
+				goto out;
+			}
+
+			memcpy(tmp_tfr, tfr, sizeof(*tfr) + tfr->data_size);
+			tmp_tfr->error = match->lowest_id;
+			list_add_tail((struct list_head *)&tmp_tfr->private,
+				      &match->startup_list);
+			goto out;
+		}
+
+		r = handle_cluster_request(match, tfr, i_am_server);
+	}
+
+out:
+	/* nothing happens after this point.  It is just for debugging */
+	if (r) {
+		LOG_ERROR("[%s] Error while processing CPG message, %s: %s",
+			  SHORT_UUID(tfr->uuid),
+			  _RQ_TYPE(tfr->request_type & ~DM_CLOG_RESPONSE),
+			  strerror(-r));
+		LOG_ERROR("[%s]    Response  : %s", SHORT_UUID(tfr->uuid),
+			  (response) ? "YES" : "NO");
+		LOG_ERROR("[%s]    Originator: %u",
+			  SHORT_UUID(tfr->uuid), tfr->originator);
+		if (response)
+			LOG_ERROR("[%s]    Responder : %u",
+				  SHORT_UUID(tfr->uuid), nodeid);
+
+               LOG_ERROR("HISTORY::");
+               for (i = 0; i < DEBUGGING_HISTORY; i++) {
+                       idx++;
+                       idx = idx % DEBUGGING_HISTORY;
+                       if (debugging[idx][0] == '\0')
+                               continue;
+                       LOG_ERROR("%d:%d) %s", i, idx, debugging[idx]);
+               }
+       } else if (!(tfr->request_type & DM_CLOG_RESPONSE) ||
+                  (tfr->originator == my_cluster_id)) {
+               int len;
+               idx++;
+               idx = idx % DEBUGGING_HISTORY;
+               len = sprintf(debugging[idx],
+                             "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s",
+                             tfr->seq,
+                             SHORT_UUID(tfr->uuid),
+                             _RQ_TYPE(tfr->request_type),
+                             tfr->originator, (response) ? "YES" : "NO");
+               if (response)
+                       sprintf(debugging[idx] + len, ", RSPR=%u", nodeid);
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
+	struct clog_tfr *tfr;
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
+	LOG_COND(log_checkpoint, "[%s] Joining node, %u needs checkpoint",
+		 SHORT_UUID(match->name.value), joined->nodeid);
+
+	/*
+	 * FIXME: remove checkpoint_requesters/checkpoints_needed, and use
+	 * the startup_list interface exclusively
+	 */
+	if (list_empty(&match->startup_list) && (match->state == VALID) &&
+	    (match->checkpoints_needed < MAX_CHECKPOINT_REQUESTERS)) {
+		match->checkpoint_requesters[match->checkpoints_needed++] = joined->nodeid;
+		goto out;
+	}
+
+	tfr = malloc(DM_CLOG_TFR_SIZE);
+	if (!tfr) {
+		LOG_ERROR("cpg_config_callback: "
+			  "Unable to allocate transfer structs");
+		LOG_ERROR("cpg_config_callback: "
+			  "Unable to perform checkpoint");
+		goto out;
+	}
+	tfr->request_type = DM_CLOG_MEMBER_JOIN;
+	tfr->originator   = joined->nodeid;
+	list_add_tail((struct list_head *)&tfr->private, &match->startup_list);
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
+	idx++;
+	idx = idx % DEBUGGING_HISTORY;
+	sprintf(debugging[idx], "+++  UUID=%s  %u join  +++",
+		SHORT_UUID(match->name.value), joined->nodeid);
+}
+
+static void cpg_leave_callback(struct clog_cpg *match,
+			       struct cpg_address *left,
+			       struct cpg_address *member_list,
+			       int member_list_entries)
+{
+	int i, fd;
+	struct list_head *p, *n;
+	uint32_t lowest = match->lowest_id;
+	struct clog_tfr *tfr;
+
+	{
+               idx++;
+               idx = idx % DEBUGGING_HISTORY;
+               sprintf(debugging[idx], "---  UUID=%s  %u left  ---",
+		       SHORT_UUID(match->name.value), left->nodeid);
+	}
+
+	/* Am I leaving? */
+	if (my_cluster_id == left->nodeid) {
+		LOG_DBG("Finalizing leave...");
+		list_del_init(&match->list);
+
+		cpg_fd_get(match->handle, &fd);
+		links_unregister(fd);
+
+		cluster_postsuspend(match->name.value);
+
+		list_for_each_safe(p, n, &match->working_list) {
+			list_del_init(p);
+			tfr = (struct clog_tfr *)p;
+
+			if (tfr->request_type == DM_CLOG_POSTSUSPEND)
+				kernel_send(tfr);
+			free(tfr);
+		}
+
+		cpg_finalize(match->handle);
+
+		match->free_me = 1;
+		match->lowest_id = 0xDEAD;
+		match->state = INVALID;
+	}			
+
+	if (left->nodeid < my_cluster_id) {
+		match->delay = (match->delay > 0) ? match->delay - 1 : 0;
+		if (!match->delay && list_empty(&match->working_list))
+			match->resend_requests = 0;
+		LOG_COND(log_resend_requests, "[%s] %u has left, delay = %d%s",
+			 SHORT_UUID(match->name.value), left->nodeid,
+			 match->delay, (list_empty(&match->working_list)) ?
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
+		i = 1; /* We do not have a DM_CLOG_MEMBER_JOIN entry */
+		list_for_each_safe(p, n, &match->startup_list) {
+			tfr = (struct clog_tfr *)p;
+			if (tfr->request_type == DM_CLOG_MEMBER_JOIN)
+				i++;
+		}
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
+	struct clog_cpg *match, *tmp;
+	int found = 0;
+
+	list_for_each_entry_safe(match, tmp, &clog_cpg_list, list)
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
+				  member_list, member_list_entries);
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
+int create_cluster_cpg(char *str)
+{
+	int r;
+	int size;
+	struct clog_cpg *new = NULL;
+	struct clog_cpg *tmp, *tmp2;
+
+	list_for_each_entry_safe(tmp, tmp2, &clog_cpg_list, list)
+		if (!strncmp(tmp->name.value, str, CPG_MAX_NAME_LENGTH)) {
+			LOG_ERROR("Log entry already exists: %s", str);
+			return -EEXIST;
+		}
+
+	new = malloc(sizeof(*new));
+	if (!new) {
+		LOG_ERROR("Unable to allocate memory for clog_cpg");
+		return -ENOMEM;
+	}
+	memset(new, 0, sizeof(*new));
+	INIT_LIST_HEAD(&new->list);
+	new->lowest_id = 0xDEAD;
+	INIT_LIST_HEAD(&new->startup_list);
+	INIT_LIST_HEAD(&new->working_list);
+
+	size = ((strlen(str) + 1) > CPG_MAX_NAME_LENGTH) ?
+		CPG_MAX_NAME_LENGTH : (strlen(str) + 1);
+	strncpy(new->name.value, str, size);
+	new->name.length = size;
+
+	/*
+	 * Look for checkpoints before joining to see if
+	 * someone wrote a checkpoint after I left a previous
+	 * session.
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
+	list_add(&new->list, &clog_cpg_list);
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
+	struct list_head *p, *n;
+	struct clog_tfr *tfr = NULL;
+
+	LOG_DBG("[%s]  CPG teardown before checkpoint received",
+		SHORT_UUID(del->name.value));
+
+	list_for_each_safe(p, n, &del->startup_list) {
+		list_del_init(p);
+		tfr = (struct clog_tfr *)p;
+		LOG_DBG("[%s]  Ignoring request from %u: %s",
+			SHORT_UUID(del->name.value), tfr->originator,
+			_RQ_TYPE(tfr->request_type));
+		free(tfr);
+	}
+
+	remove_checkpoint(del);
+}
+
+static int _destroy_cluster_cpg(struct clog_cpg *del)
+{
+	int r;
+	
+	LOG_COND(log_resend_requests, "[%s] I am leaving.2.....",
+		 SHORT_UUID(del->name.value));
+
+	/*
+	 * We must send any left over checkpoints before
+	 * leaving.  If we don't, an incoming node could
+	 * be stuck with no checkpoint and stall.
+	 */
+	do_checkpoints(del);
+
+	del->cpg_state = INVALID;
+	del->state = LEAVING;
+
+	if (!list_empty(&del->startup_list))
+		abort_startup(del);
+
+	r = cpg_leave(del->handle, &del->name);
+	if (r != CPG_OK)
+		LOG_ERROR("Error leaving CPG!");
+	return 0;
+}
+
+int destroy_cluster_cpg(char *str)
+{
+	struct clog_cpg *del, *tmp;
+
+	list_for_each_entry_safe(del, tmp, &clog_cpg_list, list)
+		if (!strncmp(del->name.value, str, CPG_MAX_NAME_LENGTH))
+			_destroy_cluster_cpg(del);
+
+	return 0;
+}
+
+int init_cluster(void)
+{
+	SaAisErrorT rv;
+
+	{
+		int i;
+		for (i = 0; i < DEBUGGING_HISTORY; i++)
+			debugging[i][0] = '\0';
+	}
+
+	INIT_LIST_HEAD(&clog_cpg_list);
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
+	struct clog_cpg *entry, *tmp;
+	struct list_head *p, *n;
+	struct clog_tfr *t;
+	int i;
+
+	LOG_ERROR("");
+	LOG_ERROR("CLUSTER COMPONENT DEBUGGING::");
+	list_for_each_entry_safe(entry, tmp, &clog_cpg_list, list) {
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
+		list_for_each_safe(p, n, &entry->working_list) {
+			t = (struct clog_tfr *)p;
+			LOG_ERROR("  %s/%u", _RQ_TYPE(t->request_type), t->seq);
+		}
+
+		LOG_ERROR("  Startup list:");
+		list_for_each_safe(p, n, &entry->startup_list) {
+			t = (struct clog_tfr *)p;
+			LOG_ERROR("  %s/%u", _RQ_TYPE(t->request_type), t->seq);
+		}
+	}
+
+	LOG_ERROR("Command History:");
+	for (i = 0; i < DEBUGGING_HISTORY; i++) {
+		idx++;
+		idx = idx % DEBUGGING_HISTORY;
+		if (debugging[idx][0] == '\0')
+			continue;
+		LOG_ERROR("%d:%d) %s", i, idx, debugging[idx]);
+	}
+}
/cvs/lvm2/LVM2/daemons/clogd/cluster.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/cluster.h
+++ -	2009-01-08 17:12:34.553336000 +0000
@@ -0,0 +1,13 @@
+#ifndef __CLUSTER_LOG_CLUSTER_DOT_H__
+#define __CLUSTER_LOG_CLUSTER_DOT_H__
+
+int init_cluster(void);
+void cleanup_cluster(void);
+void cluster_debug(void);
+
+int create_cluster_cpg(char *str);
+int destroy_cluster_cpg(char *str);
+
+int cluster_send(struct clog_tfr *tfr);
+
+#endif /* __CLUSTER_LOG_CLUSTER_DOT_H__ */
/cvs/lvm2/LVM2/daemons/clogd/common.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/common.h
+++ -	2009-01-08 17:12:34.685790000 +0000
@@ -0,0 +1,40 @@
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
+#define EXIT_KERNEL_TFR_SOCKET     3 /* Failed netlink socket create */
+#define EXIT_KERNEL_TFR_BIND       4
+#define EXIT_KERNEL_TFR_SETSOCKOPT 5
+
+#define EXIT_CLUSTER_CKPT_INIT     6 /* Failed to init checkpoint */
+
+#define EXIT_QUEUE_NOMEM           7
+
+/* Located in dm-clog-tfr.h
+#define RQ_TYPE(x) \
+	((x) == DM_CLOG_CTR) ? "DM_CLOG_CTR" : \
+	((x) == DM_CLOG_DTR) ? "DM_CLOG_DTR" : \
+	((x) == DM_CLOG_PRESUSPEND) ? "DM_CLOG_PRESUSPEND" : \
+	((x) == DM_CLOG_POSTSUSPEND) ? "DM_CLOG_POSTSUSPEND" : \
+	((x) == DM_CLOG_RESUME) ? "DM_CLOG_RESUME" : \
+	((x) == DM_CLOG_GET_REGION_SIZE) ? "DM_CLOG_GET_REGION_SIZE" : \
+	((x) == DM_CLOG_IS_CLEAN) ? "DM_CLOG_IS_CLEAN" : \
+	((x) == DM_CLOG_IN_SYNC) ? "DM_CLOG_IN_SYNC" : \
+	((x) == DM_CLOG_FLUSH) ? "DM_CLOG_FLUSH" : \
+	((x) == DM_CLOG_MARK_REGION) ? "DM_CLOG_MARK_REGION" : \
+	((x) == DM_CLOG_CLEAR_REGION) ? "DM_CLOG_CLEAR_REGION" : \
+	((x) == DM_CLOG_GET_RESYNC_WORK) ? "DM_CLOG_GET_RESYNC_WORK" : \
+	((x) == DM_CLOG_SET_REGION_SYNC) ? "DM_CLOG_SET_REGION_SYNC" : \
+	((x) == DM_CLOG_GET_SYNC_COUNT) ? "DM_CLOG_GET_SYNC_COUNT" : \
+	((x) == DM_CLOG_STATUS_INFO) ? "DM_CLOG_STATUS_INFO" : \
+	((x) == DM_CLOG_STATUS_TABLE) ? "DM_CLOG_STATUS_TABLE" : \
+	NULL
+*/
+
+#endif /* __CLUSTER_LOG_COMMON_DOT_H__ */
/cvs/lvm2/LVM2/daemons/clogd/functions.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/functions.c
+++ -	2009-01-08 17:12:34.826419000 +0000
@@ -0,0 +1,1788 @@
+#include <stdint.h>
+#include <errno.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <dirent.h>
+#include <unistd.h>
+#include <signal.h>
+#include <ext2fs/ext2_fs.h>
+#include <ext2fs/ext2fs.h>
+#include <linux/kdev_t.h>
+#define __USE_GNU /* for O_DIRECT */
+#include <fcntl.h>
+#include "linux/dm-clog-tfr.h"
+#include "list.h"
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
+static char resync_history[RESYNC_HISTORY][128];
+static int idx = 0;
+#define LOG_SPRINT(f, arg...) do {\
+		idx++; \
+		idx = idx % RESYNC_HISTORY; \
+		sprintf(resync_history[idx], f, ## arg); \
+	} while (0)
+
+struct log_header {
+        uint32_t magic;
+        uint32_t version;
+        uint64_t nr_regions;
+};
+
+struct log_c {
+	struct list_head list;
+
+	char uuid[DM_UUID_LEN];
+	uint32_t ref_count;
+
+	int touched;
+	uint32_t region_size;
+	uint32_t region_count;
+	uint64_t sync_count;
+	uint32_t bitset_uint32_count;
+
+	uint32_t *clean_bits;
+	uint32_t *sync_bits;
+	uint32_t recoverer;
+	uint64_t recovering_region; /* -1 means not recovering */
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
+	struct list_head mark_list;
+
+	uint32_t recovery_halted;
+	struct recovery_request *recovery_request_list;
+
+	int disk_fd;            /* -1 means no disk log */
+	int log_dev_failed;
+	uint64_t disk_nr_regions;
+	size_t disk_size;       /* size of disk_buffer in bytes */
+	void *disk_buffer;      /* aligned memory for O_DIRECT */
+};
+
+struct mark_entry {
+	struct list_head list;
+	uint32_t nodeid;
+	uint64_t region;
+};
+
+struct recovery_request {
+	uint64_t region;
+	struct recovery_request *next;
+};
+
+static struct list_head log_list = LIST_HEAD_INIT(log_list);
+static struct list_head log_pending_list = LIST_HEAD_INIT(log_pending_list);
+
+
+static int log_test_bit(uint32_t *bs, unsigned bit)
+{
+	return ext2fs_test_bit(bit, (unsigned int *) bs) ? 1 : 0;
+}
+
+static void log_set_bit(struct log_c *lc, uint32_t *bs, unsigned bit)
+{
+	ext2fs_set_bit(bit, (unsigned int *) bs);
+	lc->touched = 1;
+}
+
+static void log_clear_bit(struct log_c *lc, uint32_t *bs, unsigned bit)
+{
+	ext2fs_clear_bit(bit, (unsigned int *) bs);
+	lc->touched = 1;
+}
+
+/* FIXME: Why aren't count and start the same type? */
+static uint64_t find_next_zero_bit(uint32_t *bits, uint32_t count, int start)
+{
+	for(; (start < count) && log_test_bit(bits, start); start++);
+	return start;
+}
+
+static uint64_t count_bits32(uint32_t *addr, uint32_t count)
+{
+	int j;
+	uint32_t i;
+	uint64_t rtn = 0;
+
+	for (i = 0; i < count; i++) {
+		if (!addr[i])
+			continue;
+		for (j = 0; j < 32; j++)
+			rtn += (addr[i] & (1<<j)) ? 1 : 0;
+	}
+	return rtn;
+}
+
+/*
+ * get_log
+ * @tfr
+ *
+ * Returns: log if found, NULL otherwise
+ */
+static struct log_c *get_log(const char *uuid)
+{
+	struct list_head *l;
+	struct log_c *lc;
+
+	/* FIXME: Need prefetch to do this right */
+	__list_for_each(l, &log_list) {
+		lc = list_entry(l, struct log_c, list);
+		if (!strcmp(lc->uuid, uuid))
+			return lc;
+	}
+
+	return NULL;
+}
+
+/*
+ * get_pending_log
+ * @tfr
+ *
+ * Pending logs are logs that have been 'clog_ctr'ed, but
+ * have not joined the CPG (via clog_resume).
+ *
+ * Returns: log if found, NULL otherwise
+ */
+static struct log_c *get_pending_log(const char *uuid)
+{
+	struct list_head *l;
+	struct log_c *lc;
+
+	/* FIXME: Need prefetch to do this right */
+	__list_for_each(l, &log_pending_list) {
+		lc = list_entry(l, struct log_c, list);
+		if (!strcmp(lc->uuid, uuid))
+			return lc;
+	}
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
+static int _clog_ctr(int argc, char **argv, uint64_t device_size)
+{
+	int i;
+	int r = 0;
+	char *p;
+	uint64_t region_size;
+	uint64_t region_count;
+	uint32_t bitset_size;
+	struct log_c *lc = NULL;
+	struct log_c *dup;
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
+		if ((argc < 3) || (argc > 5)) {
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
+		if ((argc < 2) || (argc > 4)) {
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
+	lc->disk_fd = -1;
+	lc->log_dev_failed = 0;
+	lc->ref_count = 1;
+	strncpy(lc->uuid, argv[1 + disk_log], DM_UUID_LEN);
+
+	if ((dup = get_log(lc->uuid)) ||
+	    (dup = get_pending_log(lc->uuid))) {
+		LOG_DBG("[%s] Inc reference count on cluster log",
+			  SHORT_UUID(lc->uuid));
+		free(lc);
+		dup->ref_count++;
+		return 0;
+	}
+
+	INIT_LIST_HEAD(&lc->mark_list);
+
+	lc->bitset_uint32_count = region_count / 
+		(sizeof(*lc->clean_bits) << BYTE_SHIFT);
+	if (region_count % (sizeof(*lc->clean_bits) << BYTE_SHIFT))
+		lc->bitset_uint32_count++;
+
+	bitset_size = lc->bitset_uint32_count * sizeof(*lc->clean_bits);
+
+	lc->clean_bits = malloc(bitset_size);	
+	if (!lc->clean_bits) {
+		LOG_ERROR("Unable to allocate clean bitset");
+		r = -ENOMEM;
+		goto fail;
+	}
+	memset(lc->clean_bits, -1, bitset_size);
+
+	lc->sync_bits = malloc(bitset_size);
+	if (!lc->sync_bits) {
+		LOG_ERROR("Unable to allocate sync bitset");
+		r = -ENOMEM;
+		goto fail;
+	}
+	memset(lc->sync_bits, (sync == NOSYNC) ? -1 : 0, bitset_size);
+	lc->sync_count = (sync == NOSYNC) ? region_count : 0;
+	if (disk_log) {
+		page_size = sysconf(_SC_PAGESIZE);
+		pages = bitset_size/page_size;
+		pages += bitset_size%page_size ? 1 : 0;
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
+	list_add(&lc->list, &log_pending_list);
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
+ * @tfr
+ *
+ * tfr->data should contain constructor string as follows:
+ *	[disk] <regiion_size> <uuid> [[no]sync] <device_len>
+ * The kernel is responsible for adding the <dev_len> argument
+ * to the end; otherwise, we cannot compute the region_count.
+ *
+ * FIXME: Currently relies on caller to fill in tfr->error
+ */
+static int clog_dtr(struct clog_tfr *tfr);
+static int clog_ctr(struct clog_tfr *tfr)
+{
+	int argc, i, r = 0;
+	char *p, **argv = NULL;
+	uint64_t device_size;
+
+	/* Sanity checks */
+	if (!tfr->data_size) {
+		LOG_ERROR("Received constructor request with no data");
+		return -EINVAL;
+	}
+
+	if (strlen(tfr->data) != tfr->data_size) {
+		LOG_ERROR("Received constructor request with bad data");
+		LOG_ERROR("strlen(tfr->data)[%d] != tfr->data_size[%d]",
+			  (int)strlen(tfr->data), tfr->data_size);
+		LOG_ERROR("tfr->data = '%s' [%d]",
+			  tfr->data, (int)strlen(tfr->data));
+		return -EINVAL;
+	}
+
+	/* Split up args */
+	for (argc = 1, p = tfr->data; (p = strstr(p, " ")); p++, argc++)
+		*p = '\0';
+
+	argv = malloc(argc * sizeof(char *));
+	if (!argv)
+		return -ENOMEM;
+
+	for (i = 0, p = tfr->data; i < argc; i++, p = p + strlen(p) + 1)
+		argv[i] = p;
+
+	if (!(device_size = strtoll(argv[argc - 1], &p, 0)) || *p) {
+		LOG_ERROR("Invalid device size argument: %s", argv[argc - 1]);
+		free(argv);
+		return -EINVAL;
+	}
+
+	argc--;  /* We pass in the device_size separate */
+	r = _clog_ctr(argc, argv, device_size);
+
+	/* We join the CPG when we resume */
+
+	/* No returning data */
+	tfr->data_size = 0;
+
+	free(argv);
+	if (r)
+		LOG_ERROR("Failed to create cluster log (%s)", tfr->uuid);
+	else
+		LOG_DBG("[%s] Cluster log created",
+			  SHORT_UUID(tfr->uuid));
+
+	return r;
+}
+
+/*
+ * clog_dtr
+ * @tfr
+ *
+ */
+static int clog_dtr(struct clog_tfr *tfr)
+{
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (lc) {
+		/*
+		 * The log should not be on the official list.  There
+		 * should have been a suspend first.
+		 */
+		lc->ref_count--;
+		if (!lc->ref_count) {
+			LOG_ERROR("[%s] DTR before SUS: leaving CPG",
+				  SHORT_UUID(tfr->uuid));
+			destroy_cluster_cpg(tfr->uuid);
+		}
+	} else if ((lc = get_pending_log(tfr->uuid))) {
+		lc->ref_count--;
+	} else {
+		LOG_ERROR("clog_dtr called on log that is not official or pending");
+		return -EINVAL;
+	}
+
+	if (lc->ref_count) {
+		LOG_DBG("[%s] Dec reference count on cluster log",
+			  SHORT_UUID(lc->uuid));
+		return 0;
+	}
+
+	LOG_DBG("[%s] Cluster log removed", SHORT_UUID(lc->uuid));
+
+	list_del_init(&lc->list);
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
+ * @tfr
+ *
+ */
+static int clog_presuspend(struct clog_tfr *tfr)
+{
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (lc->touched)
+		LOG_DBG("WARNING: log still marked as 'touched' during suspend");
+
+	lc->state = LOG_SUSPENDED;
+	lc->recovery_halted = 1;
+
+	return 0;
+}
+
+/*
+ * clog_postsuspend
+ * @tfr
+ *
+ */
+static int clog_postsuspend(struct clog_tfr *tfr)
+{
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	LOG_DBG("[%s] clog_postsuspend: leaving CPG", SHORT_UUID(lc->uuid));
+	destroy_cluster_cpg(tfr->uuid);
+
+	lc->recovering_region = (uint64_t)-1;
+	lc->recoverer = (uint32_t)-1;
+
+	return 0;
+}
+
+/*
+ * cluster_postsuspend
+ * @tfr
+ *
+ */
+int cluster_postsuspend(char *uuid)
+{
+	struct log_c *lc = get_log(uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	LOG_DBG("[%s] clog_postsuspend: finalizing", SHORT_UUID(lc->uuid));
+	lc->resume_override = 0;
+
+	/* move log to pending list */
+	list_del_init(&lc->list);
+	list_add(&lc->list, &log_pending_list);
+
+	return 0;
+}
+
+/*
+ * clog_resume
+ * @tfr
+ *
+ * Does the main work of resuming.
+ */
+static int clog_resume(struct clog_tfr *tfr)
+{
+	uint32_t i;
+	int commit_log = 0;
+	struct log_c *lc = get_log(tfr->uuid);
+	size_t size = lc->bitset_uint32_count * sizeof(uint32_t);
+
+	if (!lc)
+		return -EINVAL;
+
+	switch (lc->resume_override) {
+	case 1000:
+		LOG_ERROR("[%s] Additional resume issued before suspend",
+			  SHORT_UUID(tfr->uuid));
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
+		LOG_ERROR("Error:: multiple loading of bits (%d)", lc->resume_override);
+		return -EINVAL;
+	}
+
+	if (lc->log_dev_failed) {
+		LOG_ERROR("Log device has failed, unable to read bits");
+		tfr->error = 0;  /* We can handle this so far */
+		lc->disk_nr_regions = 0;
+	} else
+		tfr->error = read_log(lc);
+
+	switch (tfr->error) {
+	case 0:
+		if (lc->disk_nr_regions < lc->region_count)
+			LOG_DBG("[%s] Mirror has grown, updating log bits",
+				SHORT_UUID(lc->uuid));
+		else if (lc->disk_nr_regions > lc->region_count)
+			LOG_DBG("[%s] Mirror has shrunk, updating log bits",
+				SHORT_UUID(lc->uuid));
+		break;		
+	case -EINVAL:
+		LOG_PRINT("[%s] (Re)initializing mirror log - resync issued.",
+			  SHORT_UUID(lc->uuid));
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
+	memcpy(lc->sync_bits, lc->clean_bits, size);
+
+	if (commit_log && (lc->disk_fd >= 0)) {
+		tfr->error = write_log(lc);
+		if (tfr->error)
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
+	lc->sync_count = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
+
+	LOG_DBG("[%s] Initial sync_count = %llu",
+		SHORT_UUID(lc->uuid), (unsigned long long)lc->sync_count);
+	lc->sync_search = 0;
+	lc->state = LOG_RESUMED;
+	lc->recovery_halted = 0;
+	
+	return tfr->error;
+}
+
+/*
+ * local_resume
+ * @tfr
+ *
+ * If the log is pending, we must first join the cpg and
+ * put the log in the official list.
+ *
+ */
+int local_resume(struct clog_tfr *tfr)
+{
+	int r;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc) {
+		/* Is the log in the pending list? */
+		lc = get_pending_log(tfr->uuid);
+		if (!lc) {
+			LOG_ERROR("clog_resume called on log that is not official or pending");
+			return -EINVAL;
+		}
+
+		/* Join the CPG */
+		r = create_cluster_cpg(tfr->uuid);
+		if (r) {
+			LOG_ERROR("clog_resume:  Failed to create cluster CPG");
+			return r;
+		}
+
+		/* move log to official list */
+		list_del_init(&lc->list);
+		list_add(&lc->list, &log_list);
+	}
+
+	return 0;
+}
+
+/*
+ * clog_get_region_size
+ * @tfr
+ *
+ * Since this value doesn't change, the kernel
+ * should not need to talk to server to get this
+ * The function is here for completness
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int clog_get_region_size(struct clog_tfr *tfr)
+{
+	uint64_t *rtn = (uint64_t *)tfr->data;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	LOG_PRINT("WARNING: kernel should not be calling clog_get_region_size");
+	if (!lc)
+		return -EINVAL;
+
+	/* FIXME: region_size is 32-bit, while function requires 64-bit */
+	*rtn = lc->region_size;
+	tfr->data_size = sizeof(*rtn);
+
+	return 0;
+}
+
+/*
+ * clog_is_clean
+ * @tfr
+ *
+ * Returns: 1 if clean, 0 otherwise
+ */
+static int clog_is_clean(struct clog_tfr *tfr)
+{
+	int *rtn = (int *)tfr->data;
+	uint64_t region = *((uint64_t *)(tfr->data));
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	*rtn = log_test_bit(lc->clean_bits, region);
+	tfr->data_size = sizeof(*rtn);
+
+	return 0;
+}
+
+/*
+ * clog_in_sync
+ * @tfr
+ *
+ * We ignore any request for non-block.  That
+ * should be handled elsewhere.  (If the request
+ * has come this far, it has already blocked.)
+ *
+ * Returns: 1 if in-sync, 0 otherwise
+ */
+static int clog_in_sync(struct clog_tfr *tfr)
+{
+	int *rtn = (int *)tfr->data;
+	uint64_t region = *((uint64_t *)(tfr->data));
+	struct log_c *lc = get_log(tfr->uuid);
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
+	tfr->data_size = sizeof(*rtn);
+
+	return 0;
+}
+
+/*
+ * clog_flush
+ * @tfr
+ *
+ */
+static int clog_flush(struct clog_tfr *tfr, int server)
+{
+	int r = 0;
+	struct log_c *lc = get_log(tfr->uuid);
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
+		r = tfr->error = write_log(lc);
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
+	struct list_head *p, *n;
+
+	list_for_each_safe(p, n, &lc->mark_list) {
+		/* FIXME: Use proper macros */
+		m = (struct mark_entry *)p;
+		if (m->region == region) {
+			found = 1;
+			if (m->nodeid == who)
+				return 0;
+		}
+	}
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
+	list_add_tail(&m->list, &lc->mark_list);
+
+	return 0;
+}
+
+/*
+ * clog_mark_region
+ * @tfr
+ *
+ * tfr may contain more than one mark request.  We
+ * can determine the number from the 'data_size' field.
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int clog_mark_region(struct clog_tfr *tfr)
+{
+	int r;
+	int count;
+	uint64_t *region;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (tfr->data_size % sizeof(uint64_t)) {
+		LOG_ERROR("Bad data size given for mark_region request");
+		return -EINVAL;
+	}
+
+	count = tfr->data_size / sizeof(uint64_t);
+	region = (uint64_t *)&tfr->data;
+
+	for (; count > 0; count--, region++) {
+		r = mark_region(lc, *region, tfr->originator);
+		if (r)
+			return r;
+	}
+
+	tfr->data_size = 0;
+
+	return 0;
+}
+
+static int clear_region(struct log_c *lc, uint64_t region, uint32_t who)
+{
+	int other_matches = 0;
+	struct mark_entry *m;
+	struct list_head *p, *n;
+
+	list_for_each_safe(p, n, &lc->mark_list) {
+		/* FIXME: Use proper macros */
+		m = (struct mark_entry *)p;
+		if (m->region == region) {
+			if (m->nodeid == who) {
+				list_del_init(&m->list);
+				free(m);
+			} else
+				other_matches = 1;
+		}
+	}			
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
+ * @tfr
+ *
+ * tfr may contain more than one clear request.  We
+ * can determine the number from the 'data_size' field.
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int clog_clear_region(struct clog_tfr *tfr)
+{
+	int r;
+	int count;
+	uint64_t *region;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (tfr->data_size % sizeof(uint64_t)) {
+		LOG_ERROR("Bad data size given for clear_region request");
+		return -EINVAL;
+	}
+
+	count = tfr->data_size / sizeof(uint64_t);
+	region = (uint64_t *)&tfr->data;
+
+	for (; count > 0; count--, region++) {
+		r = clear_region(lc, *region, tfr->originator);
+		if (r)
+			return r;
+	}
+
+	tfr->data_size = 0;
+
+	return 0;
+}
+
+/*
+ * clog_get_resync_work
+ * @tfr
+ *
+ */
+static int clog_get_resync_work(struct clog_tfr *tfr)
+{
+	struct {int i; uint64_t r; } *pkg = (void *)tfr->data;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	tfr->data_size = sizeof(*pkg);
+	pkg->i = 0;
+
+	if (lc->sync_search >= lc->region_count) {
+		/*
+		 * FIXME: handle intermittent errors during recovery
+		 * by resetting sync_search... but not to many times.
+		 */
+		LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "Recovery finished",
+			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
+		return 0;
+	}
+
+	if (lc->recovering_region != (uint64_t)-1) {
+		if (lc->recoverer == tfr->originator) {
+			LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Re-requesting work (%llu)",
+				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   (unsigned long long)lc->recovering_region);
+			pkg->r = lc->recovering_region;
+			pkg->i = 1;
+		} else {
+			LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Someone already recovering (%llu)",
+				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
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
+			LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Assigning priority resync work (%llu)",
+				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   (unsigned long long)pkg->r);
+			pkg->i = 1;
+			lc->recovering_region = pkg->r;
+			lc->recoverer = tfr->originator;
+			return 0;
+		}
+	}
+
+	pkg->r = find_next_zero_bit(lc->sync_bits,
+				    lc->region_count,
+				    lc->sync_search);
+
+	if (pkg->r >= lc->region_count) {
+		LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "Resync work complete.",
+			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
+		return 0;
+	}
+
+	lc->sync_search = pkg->r + 1;
+
+	LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+		   "Assigning resync work (%llu)",
+		   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+		   (unsigned long long)pkg->r);
+	pkg->i = 1;
+	lc->recovering_region = pkg->r;
+	lc->recoverer = tfr->originator;
+
+	return 0;
+}
+
+/*
+ * clog_set_region_sync
+ * @tfr
+ */
+static int clog_set_region_sync(struct clog_tfr *tfr)
+{
+	struct { uint64_t region; int in_sync; } *pkg = (void *)tfr->data;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	lc->recovering_region = (uint64_t)-1;
+
+	if (pkg->in_sync) {
+		if (log_test_bit(lc->sync_bits, pkg->region)) {
+			LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Region already set (%llu)",
+				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   (unsigned long long)pkg->region);
+		} else {
+			log_set_bit(lc, lc->sync_bits, pkg->region);
+			lc->sync_count++;
+			LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+				   "Setting region (%llu)",
+				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   (unsigned long long)pkg->region);
+		}
+	} else if (log_test_bit(lc->sync_bits, pkg->region)) {
+		lc->sync_count--;
+		log_clear_bit(lc, lc->sync_bits, pkg->region);
+		LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "Unsetting region (%llu)",
+			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+			   (unsigned long long)pkg->region);
+	}
+
+	if (lc->sync_count != count_bits32(lc->sync_bits, lc->bitset_uint32_count)) {
+		unsigned long long reset = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
+
+		LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "sync_count(%llu) != bitmap count(%llu)",
+			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+			   (unsigned long long)lc->sync_count, reset);
+		lc->sync_count = reset;
+	}
+
+	if (lc->sync_count > lc->region_count)
+		LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "(lc->sync_count > lc->region_count) - this is bad",
+			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
+
+	tfr->data_size = 0;
+	return 0;
+}
+
+/*
+ * clog_get_sync_count
+ * @tfr
+ */
+static int clog_get_sync_count(struct clog_tfr *tfr)
+{
+	uint64_t *sync_count = (uint64_t *)tfr->data;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	/*
+	 * FIXME: Mirror requires us to be able to ask for
+	 * the sync count while pending... but I don't like
+	 * it because other machines may not be suspended and
+	 * the stored value may not be accurate.
+	 */
+	if (!lc)
+		lc = get_pending_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	*sync_count = lc->sync_count;
+
+	tfr->data_size = sizeof(*sync_count);
+
+	return 0;
+}
+
+static int core_status_info(struct log_c *lc, struct clog_tfr *tfr)
+{
+	char *data = (char *)tfr->data;
+
+	tfr->data_size = sprintf(data, "1 clustered_core");
+
+	return 0;
+}
+
+static int disk_status_info(struct log_c *lc, struct clog_tfr *tfr)
+{
+	char *data = (char *)tfr->data;
+	struct stat statbuf;
+
+	if(fstat(lc->disk_fd, &statbuf)) {
+		tfr->error = -errno;
+		return -errno;
+	}
+
+	tfr->data_size = sprintf(data, "3 clustered_disk %d:%d %c",
+				 major(statbuf.st_rdev), minor(statbuf.st_rdev),
+				 (lc->log_dev_failed) ? 'D' : 'A');
+
+	return 0;
+}
+
+/*
+ * clog_status_info
+ * @tfr
+ *
+ */
+static int clog_status_info(struct clog_tfr *tfr)
+{
+	int r;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		lc = get_pending_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (lc->disk_fd == -1)
+		r = core_status_info(lc, tfr);
+	else
+		r = disk_status_info(lc, tfr);
+
+	return r;
+}
+
+static int core_status_table(struct log_c *lc, struct clog_tfr *tfr)
+{
+	int params;
+	char *data = (char *)tfr->data;
+
+	params = (lc->sync == DEFAULTSYNC) ? 3 : 4;
+	tfr->data_size = sprintf(data, "clustered_core %d %u %s %s%s ",
+				 params, lc->region_size, lc->uuid,
+				 (lc->sync == DEFAULTSYNC) ? "" :
+				 (lc->sync == NOSYNC) ? "nosync " : "sync ",
+				 (lc->block_on_error) ? "block_on_error" : "");
+	return 0;
+}
+
+static int disk_status_table(struct log_c *lc, struct clog_tfr *tfr)
+{
+	int params;
+	char *data = (char *)tfr->data;
+	struct stat statbuf;
+
+	if(fstat(lc->disk_fd, &statbuf)) {
+		tfr->error = -errno;
+		return -errno;
+	}
+
+	params = (lc->sync == DEFAULTSYNC) ? 4 : 5;
+	tfr->data_size = sprintf(data, "clustered_disk %d %d:%d %u %s %s%s ",
+				 params, major(statbuf.st_rdev), minor(statbuf.st_rdev),
+				 lc->region_size, lc->uuid,
+				 (lc->sync == DEFAULTSYNC) ? "" :
+				 (lc->sync == NOSYNC) ? "nosync " : "sync ",
+				 (lc->block_on_error) ? "block_on_error" : "");
+	return 0;
+}
+
+/*
+ * clog_status_table
+ * @tfr
+ *
+ */
+static int clog_status_table(struct clog_tfr *tfr)
+{
+	int r;
+	struct log_c *lc = get_log(tfr->uuid);
+
+	if (!lc)
+		lc = get_pending_log(tfr->uuid);
+
+	if (!lc)
+		return -EINVAL;
+
+	if (lc->disk_fd == -1)
+		r = core_status_table(lc, tfr);
+	else
+		r = disk_status_table(lc, tfr);
+
+	return r;
+}
+
+/*
+ * clog_is_remote_recovering
+ * @tfr
+ *
+ */
+static int clog_is_remote_recovering(struct clog_tfr *tfr)
+{
+	uint64_t region = *((uint64_t *)(tfr->data));
+	struct { int is_recovering; uint64_t in_sync_hint; } *pkg = (void *)tfr->data;
+	struct log_c *lc = get_log(tfr->uuid);
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
+		 * to account for that.
+		 */
+		pkg->in_sync_hint = (lc->sync_search - 1);
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
+	tfr->data_size = sizeof(*pkg);
+
+	return 0;	
+}
+
+
+/*
+ * do_request
+ * @tfr: the request
+ * @server: is this request performed by the server
+ *
+ * An inability to perform this function will return an error
+ * from this function.  However, an inability to successfully
+ * perform the request will fill in the 'tfr->error' field.
+ *
+ * Returns: 0 on success, -EXXX on error
+ */
+int do_request(struct clog_tfr *tfr, int server)
+{
+	int r;
+
+	if (!tfr)
+		return 0;
+
+	if (tfr->error)
+		LOG_DBG("Programmer error: tfr struct has error set");
+
+	switch (tfr->request_type) {
+	case DM_CLOG_CTR:
+		r = clog_ctr(tfr);
+		break;
+	case DM_CLOG_DTR:
+		r = clog_dtr(tfr);
+		break;
+	case DM_CLOG_PRESUSPEND:
+		r = clog_presuspend(tfr);
+		break;
+	case DM_CLOG_POSTSUSPEND:
+		r = clog_postsuspend(tfr);
+		break;
+	case DM_CLOG_RESUME:
+		r = clog_resume(tfr);
+		break;
+	case DM_CLOG_GET_REGION_SIZE:
+		r = clog_get_region_size(tfr);
+		break;
+	case DM_CLOG_IS_CLEAN:
+		r = clog_is_clean(tfr);
+		break;
+	case DM_CLOG_IN_SYNC:
+		r = clog_in_sync(tfr);
+		break;
+	case DM_CLOG_FLUSH:
+		r = clog_flush(tfr, server);
+		break;
+	case DM_CLOG_MARK_REGION:
+		r = clog_mark_region(tfr);
+		break;
+	case DM_CLOG_CLEAR_REGION:
+		r = clog_clear_region(tfr);
+		break;
+	case DM_CLOG_GET_RESYNC_WORK:
+		r = clog_get_resync_work(tfr);
+		break;
+	case DM_CLOG_SET_REGION_SYNC:
+		r = clog_set_region_sync(tfr);
+		break;
+	case DM_CLOG_GET_SYNC_COUNT:
+		r = clog_get_sync_count(tfr);
+		break;
+	case DM_CLOG_STATUS_INFO:
+		r = clog_status_info(tfr);
+		break;
+	case DM_CLOG_STATUS_TABLE:
+		r = clog_status_table(tfr);
+		break;
+	case DM_CLOG_IS_REMOTE_RECOVERING:
+		r = clog_is_remote_recovering(tfr);
+		break;
+	default:
+		LOG_ERROR("Unknown request");
+		r = tfr->error = -EINVAL;
+		break;
+	}
+
+	if (r && !tfr->error)
+		tfr->error = r;
+	else if (r != tfr->error)
+		LOG_DBG("Warning:  error from function != tfr->error");
+
+	if (tfr->error && tfr->data_size) {
+		/* Make sure I'm handling errors correctly above */
+		LOG_DBG("Programmer error: tfr->error && tfr->data_size");
+		tfr->data_size = 0;
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
+int push_state(const char *uuid, const char *which, char **buf)
+{
+	int bitset_size;
+	struct log_c *lc;
+
+	if (*buf)
+		LOG_ERROR("store_bits: *buf != NULL");
+
+	lc = get_log(uuid);
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
+		LOG_SPRINT("CKPT SEND - SEQ#=X, UUID=%s, nodeid = X:: "
+			   "recovering_region=%llu, recoverer=%u",
+			   SHORT_UUID(lc->uuid),
+			   (unsigned long long)lc->recovering_region, lc->recoverer);
+		return 64;
+	}
+
+	bitset_size = lc->bitset_uint32_count * sizeof(*lc->clean_bits);
+	*buf = malloc(bitset_size);
+
+	if (!*buf) {
+		LOG_ERROR("store_bits: Unable to allocate memory");
+		return -ENOMEM;
+	}
+
+	if (!strncmp(which, "sync_bits", 9)) {
+		memcpy(*buf, lc->sync_bits, bitset_size);
+		LOG_DBG("[%s] storing sync_bits (sync_count = %llu):",
+			SHORT_UUID(uuid), (unsigned long long)
+			count_bits32(lc->sync_bits, lc->bitset_uint32_count));
+		print_bits(*buf, bitset_size, 0);
+	} else if (!strncmp(which, "clean_bits", 9)) {
+		memcpy(*buf, lc->clean_bits, bitset_size);
+		LOG_DBG("[%s] storing clean_bits:", SHORT_UUID(lc->uuid));
+		print_bits(*buf, bitset_size, 0);
+	}
+
+	return bitset_size;
+}
+
+/*int load_bits(const char *uuid, const char *which, char *buf, int size)*/
+int pull_state(const char *uuid, const char *which, char *buf, int size)
+{
+	int bitset_size;
+	struct log_c *lc;
+
+	if (!buf)
+		LOG_ERROR("pull_state: buf == NULL");
+
+	lc = get_log(uuid);
+	if (!lc) {
+		LOG_ERROR("pull_state: No log found for %s", uuid);
+		return -EINVAL;
+	}
+
+	if (!strncmp(which, "recovering_region", 17)) {
+		sscanf(buf, "%llu %u", (unsigned long long *)&lc->recovering_region,
+		       &lc->recoverer);
+		LOG_SPRINT("CKPT INIT - SEQ#=X, UUID=%s, nodeid = X:: "
+			   "recovering_region=%llu, recoverer=%u",
+			   SHORT_UUID(lc->uuid),
+			   (unsigned long long)lc->recovering_region, lc->recoverer);
+		return 0;
+	}
+
+	bitset_size = lc->bitset_uint32_count * sizeof(*lc->clean_bits);
+	if (bitset_size != size) {
+		LOG_ERROR("pull_state(%s): bad bitset_size (%d vs %d)",
+			  which, size, bitset_size);
+		return -EINVAL;
+	}
+
+	if (!strncmp(which, "sync_bits", 9)) {
+		lc->resume_override += 1;
+		memcpy(lc->sync_bits, buf, bitset_size);
+		LOG_DBG("[%s] loading sync_bits (sync_count = %llu):",
+			SHORT_UUID(lc->uuid),(unsigned long long)
+			count_bits32(lc->sync_bits, lc->bitset_uint32_count));
+		print_bits((char *)lc->sync_bits, bitset_size, 0);
+	} else if (!strncmp(which, "clean_bits", 9)) {
+		lc->resume_override += 2;
+		memcpy(lc->clean_bits, buf, bitset_size);
+		LOG_DBG("[%s] loading clean_bits:", SHORT_UUID(lc->uuid));
+		print_bits((char *)lc->clean_bits, bitset_size, 0);
+	}
+
+	return 0;
+}
+
+int log_get_state(struct clog_tfr *tfr)
+{
+	struct log_c *lc;
+
+	lc = get_log(tfr->uuid);
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
+	struct list_head *l;
+
+	__list_for_each(l, &log_list)
+		return 1;
+
+	__list_for_each(l, &log_pending_list)
+		return 1;
+
+	return 0;
+}
+
+void log_debug(void)
+{
+	struct list_head *l;
+	struct log_c *lc;
+	uint64_t r;
+	int i;
+
+	LOG_ERROR("");
+	LOG_ERROR("LOG COMPONENT DEBUGGING::");
+	LOG_ERROR("Official log list:");
+	__list_for_each(l, &log_list) {
+		lc = list_entry(l, struct log_c, list);
+		LOG_ERROR("%s", lc->uuid);
+		LOG_ERROR("  recoverer        : %u", lc->recoverer);
+		LOG_ERROR("  recovering_region: %llu",
+			  (unsigned long long)lc->recovering_region);
+		LOG_ERROR("  recovery_halted  : %s", (lc->recovery_halted) ?
+			  "YES" : "NO");
+		LOG_ERROR("sync_bits:");
+		print_bits((char *)lc->sync_bits,
+			   lc->bitset_uint32_count * sizeof(*lc->sync_bits), 1);
+		LOG_ERROR("clean_bits:");
+		print_bits((char *)lc->clean_bits,
+			   lc->bitset_uint32_count * sizeof(*lc->clean_bits), 1);
+	}
+
+	LOG_ERROR("Pending log list:");
+	__list_for_each(l, &log_pending_list) {
+		lc = list_entry(l, struct log_c, list);
+		LOG_ERROR("%s", lc->uuid);
+		LOG_ERROR("sync_bits:");
+		print_bits((char *)lc->sync_bits,
+			   lc->bitset_uint32_count * sizeof(*lc->sync_bits), 1);
+		LOG_ERROR("clean_bits:");
+		print_bits((char *)lc->clean_bits,
+			   lc->bitset_uint32_count * sizeof(*lc->clean_bits), 1);
+	}
+
+	__list_for_each(l, &log_list) {
+		lc = list_entry(l, struct log_c, list);
+		LOG_ERROR("Validating %s::", SHORT_UUID(lc->uuid));
+		r = find_next_zero_bit(lc->sync_bits, lc->region_count, 0);
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
+	}
+
+	LOG_ERROR("Resync request history:");
+	for (i = 0; i < RESYNC_HISTORY; i++) {
+		idx++;
+		idx = idx % RESYNC_HISTORY;
+		if (resync_history[idx][0] == '\0')
+			continue;
+		LOG_ERROR("%d:%d) %s", i, idx, resync_history[idx]);
+	}
+}
/cvs/lvm2/LVM2/daemons/clogd/functions.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/functions.h
+++ -	2009-01-08 17:12:34.942363000 +0000
@@ -0,0 +1,20 @@
+#ifndef __CLOG_FUNCTIONS_DOT_H__
+#define __CLOG_FUNCTIONS_DOT_H__
+
+#include <linux/dm-clog-tfr.h>
+
+#define LOG_RESUMED   1
+#define LOG_SUSPENDED 2
+
+int local_resume(struct clog_tfr *tfr);
+int cluster_postsuspend(char *);
+
+int do_request(struct clog_tfr *tfr, int server);
+int push_state(const char *uuid, const char *which, char **buf);
+int pull_state(const char *uuid, const char *which, char *buf, int size);
+
+int log_get_state(struct clog_tfr *tfr);
+int log_status(void);
+void log_debug(void);
+
+#endif /* __CLOG_FUNCTIONS_DOT_H__ */
/cvs/lvm2/LVM2/daemons/clogd/link_mon.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/link_mon.c
+++ -	2009-01-08 17:12:35.045866000 +0000
@@ -0,0 +1,138 @@
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
/cvs/lvm2/LVM2/daemons/clogd/link_mon.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/link_mon.h
+++ -	2009-01-08 17:12:35.166923000 +0000
@@ -0,0 +1,9 @@
+#ifndef __LINK_MON_DOT_H__
+#define __LINK_MON_DOT_H__
+
+int links_register(int fd, char *name, int (*callback)(void *data), void *data);
+int links_unregister(int fd);
+int links_monitor(void);
+int links_issue_callbacks(void);
+
+#endif /* __LINK_MON_DOT_H__ */
/cvs/lvm2/LVM2/daemons/clogd/list.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/list.h
+++ -	2009-01-08 17:12:35.300575000 +0000
@@ -0,0 +1,471 @@
+#ifndef _LINUX_LIST_H
+#define _LINUX_LIST_H
+
+/*
+ * These are non-NULL pointers that will result in page faults
+ * under normal circumstances, used to verify that nobody uses
+ * non-initialized list entries.
+ */
+#define LIST_POISON1  ((void *) 0x00100100)
+#define LIST_POISON2  ((void *) 0x00200200)
+
+/*
+ * Simple doubly linked list implementation.
+ *
+ * Some of the internal functions ("__xxx") are useful when
+ * manipulating whole lists rather than single entries, as
+ * sometimes we already know the next/prev entries and we can
+ * generate better code by using them directly rather than
+ * using the generic single-entry routines.
+ */
+
+struct list_head {
+	struct list_head *next, *prev;
+};
+
+#define LIST_HEAD_INIT(name) { &(name), &(name) }
+
+#define LIST_HEAD(name) \
+	struct list_head name = LIST_HEAD_INIT(name)
+
+#define INIT_LIST_HEAD(ptr) do { \
+	(ptr)->next = (ptr); (ptr)->prev = (ptr); \
+} while (0)
+
+/*
+ * Insert a new entry between two known consecutive entries.
+ *
+ * This is only for internal list manipulation where we know
+ * the prev/next entries already!
+ */
+static inline void __list_add(struct list_head *new,
+			      struct list_head *prev,
+			      struct list_head *next)
+{
+	next->prev = new;
+	new->next = next;
+	new->prev = prev;
+	prev->next = new;
+}
+
+/**
+ * list_add - add a new entry
+ * @new: new entry to be added
+ * @head: list head to add it after
+ *
+ * Insert a new entry after the specified head.
+ * This is good for implementing stacks.
+ */
+static inline void list_add(struct list_head *new, struct list_head *head)
+{
+	__list_add(new, head, head->next);
+}
+
+/**
+ * list_add_tail - add a new entry
+ * @new: new entry to be added
+ * @head: list head to add it before
+ *
+ * Insert a new entry before the specified head.
+ * This is useful for implementing queues.
+ */
+static inline void list_add_tail(struct list_head *new, struct list_head *head)
+{
+	__list_add(new, head->prev, head);
+}
+
+/*
+ * Delete a list entry by making the prev/next entries
+ * point to each other.
+ *
+ * This is only for internal list manipulation where we know
+ * the prev/next entries already!
+ */
+static inline void __list_del(struct list_head * prev, struct list_head * next)
+{
+	next->prev = prev;
+	prev->next = next;
+}
+
+/**
+ * list_del - deletes entry from list.
+ * @entry: the element to delete from the list.
+ * Note: list_empty on entry does not return true after this, the entry is
+ * in an undefined state.
+ */
+static inline void list_del(struct list_head *entry)
+{
+	__list_del(entry->prev, entry->next);
+	entry->next = LIST_POISON1;
+	entry->prev = LIST_POISON2;
+}
+
+/**
+ * list_del_init - deletes entry from list and reinitialize it.
+ * @entry: the element to delete from the list.
+ */
+static inline void list_del_init(struct list_head *entry)
+{
+	__list_del(entry->prev, entry->next);
+	INIT_LIST_HEAD(entry);
+}
+
+/**
+ * list_move - delete from one list and add as another's head
+ * @list: the entry to move
+ * @head: the head that will precede our entry
+ */
+static inline void list_move(struct list_head *list, struct list_head *head)
+{
+        __list_del(list->prev, list->next);
+        list_add(list, head);
+}
+
+/**
+ * list_move_tail - delete from one list and add as another's tail
+ * @list: the entry to move
+ * @head: the head that will follow our entry
+ */
+static inline void list_move_tail(struct list_head *list,
+				  struct list_head *head)
+{
+        __list_del(list->prev, list->next);
+        list_add_tail(list, head);
+}
+
+/**
+ * list_empty - tests whether a list is empty
+ * @head: the list to test.
+ */
+static inline int list_empty(const struct list_head *head)
+{
+	return head->next == head;
+}
+
+/**
+ * list_empty_careful - tests whether a list is
+ * empty _and_ checks that no other CPU might be
+ * in the process of still modifying either member
+ *
+ * NOTE: using list_empty_careful() without synchronization
+ * can only be safe if the only activity that can happen
+ * to the list entry is list_del_init(). Eg. it cannot be used
+ * if another CPU could re-list_add() it.
+ *
+ * @head: the list to test.
+ */
+static inline int list_empty_careful(const struct list_head *head)
+{
+	struct list_head *next = head->next;
+	return (next == head) && (next == head->prev);
+}
+
+static inline void __list_splice(struct list_head *list,
+				 struct list_head *head)
+{
+	struct list_head *first = list->next;
+	struct list_head *last = list->prev;
+	struct list_head *at = head->next;
+
+	first->prev = head;
+	head->next = first;
+
+	last->next = at;
+	at->prev = last;
+}
+
+/**
+ * list_splice - join two lists
+ * @list: the new list to add.
+ * @head: the place to add it in the first list.
+ */
+static inline void list_splice(struct list_head *list, struct list_head *head)
+{
+	if (!list_empty(list))
+		__list_splice(list, head);
+}
+
+/**
+ * list_splice_init - join two lists and reinitialise the emptied list.
+ * @list: the new list to add.
+ * @head: the place to add it in the first list.
+ *
+ * The list at @list is reinitialised
+ */
+static inline void list_splice_init(struct list_head *list,
+				    struct list_head *head)
+{
+	if (!list_empty(list)) {
+		__list_splice(list, head);
+		INIT_LIST_HEAD(list);
+	}
+}
+
+#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
+
+/**
+ * container_of - cast a member of a structure out to the containing structure
+ *
+ * @ptr:        the pointer to the member.
+ * @type:       the type of the container struct this is embedded in.
+ * @member:     the name of the member within the struct.
+ *
+ */
+#define container_of(ptr, type, member) ({                      \
+        const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
+        (type *)( (char *)__mptr - offsetof(type,member) );})
+
+
+/**
+ * list_entry - get the struct for this entry
+ * @ptr:	the &struct list_head pointer.
+ * @type:	the type of the struct this is embedded in.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_entry(ptr, type, member) \
+	container_of(ptr, type, member)
+
+/**
+ * list_for_each	-	iterate over a list
+ * @pos:	the &struct list_head to use as a loop counter.
+ * @head:	the head for your list.
+ */
+#define list_for_each(pos, head) \
+	for (pos = (head)->next; prefetch(pos->next), pos != (head); \
+        	pos = pos->next)
+
+/**
+ * __list_for_each	-	iterate over a list
+ * @pos:	the &struct list_head to use as a loop counter.
+ * @head:	the head for your list.
+ *
+ * This variant differs from list_for_each() in that it's the
+ * simplest possible list iteration code, no prefetching is done.
+ * Use this for code that knows the list to be very short (empty
+ * or 1 entry) most of the time.
+ */
+#define __list_for_each(pos, head) \
+	for (pos = (head)->next; pos != (head); pos = pos->next)
+
+/**
+ * list_for_each_prev	-	iterate over a list backwards
+ * @pos:	the &struct list_head to use as a loop counter.
+ * @head:	the head for your list.
+ */
+#define list_for_each_prev(pos, head) \
+	for (pos = (head)->prev; prefetch(pos->prev), pos != (head); \
+        	pos = pos->prev)
+
+/**
+ * list_for_each_safe	-	iterate over a list safe against removal of list entry
+ * @pos:	the &struct list_head to use as a loop counter.
+ * @n:		another &struct list_head to use as temporary storage
+ * @head:	the head for your list.
+ */
+#define list_for_each_safe(pos, n, head) \
+	for (pos = (head)->next, n = pos->next; pos != (head); \
+		pos = n, n = pos->next)
+
+/**
+ * list_for_each_entry	-	iterate over list of given type
+ * @pos:	the type * to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry(pos, head, member)				\
+	for (pos = list_entry((head)->next, typeof(*pos), member);	\
+	     prefetch(pos->member.next), &pos->member != (head); 	\
+	     pos = list_entry(pos->member.next, typeof(*pos), member))
+
+/**
+ * list_for_each_entry_reverse - iterate backwards over list of given type.
+ * @pos:	the type * to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_reverse(pos, head, member)			\
+	for (pos = list_entry((head)->prev, typeof(*pos), member);	\
+	     prefetch(pos->member.prev), &pos->member != (head); 	\
+	     pos = list_entry(pos->member.prev, typeof(*pos), member))
+
+/**
+ * list_prepare_entry - prepare a pos entry for use as a start point in
+ *			list_for_each_entry_continue
+ * @pos:	the type * to use as a start point
+ * @head:	the head of the list
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_prepare_entry(pos, head, member) \
+	((pos) ? : list_entry(head, typeof(*pos), member))
+
+/**
+ * list_for_each_entry_continue -	iterate over list of given type
+ *			continuing after existing point
+ * @pos:	the type * to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_continue(pos, head, member) 		\
+	for (pos = list_entry(pos->member.next, typeof(*pos), member);	\
+	     prefetch(pos->member.next), &pos->member != (head);	\
+	     pos = list_entry(pos->member.next, typeof(*pos), member))
+
+/**
+ * list_for_each_entry_safe - iterate over list of given type safe against removal of list entry
+ * @pos:	the type * to use as a loop counter.
+ * @n:		another type * to use as temporary storage
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_safe(pos, n, head, member)			\
+	for (pos = list_entry((head)->next, typeof(*pos), member),	\
+		n = list_entry(pos->member.next, typeof(*pos), member);	\
+	     &pos->member != (head); 					\
+	     pos = n, n = list_entry(n->member.next, typeof(*n), member))
+
+/*
+ * Double linked lists with a single pointer list head.
+ * Mostly useful for hash tables where the two pointer list head is
+ * too wasteful.
+ * You lose the ability to access the tail in O(1).
+ */
+
+struct hlist_head {
+	struct hlist_node *first;
+};
+
+struct hlist_node {
+	struct hlist_node *next, **pprev;
+};
+
+#define HLIST_HEAD_INIT { .first = NULL }
+#define HLIST_HEAD(name) struct hlist_head name = {  .first = NULL }
+#define INIT_HLIST_HEAD(ptr) ((ptr)->first = NULL)
+#define INIT_HLIST_NODE(ptr) ((ptr)->next = NULL, (ptr)->pprev = NULL)
+
+static inline int hlist_unhashed(const struct hlist_node *h)
+{
+	return !h->pprev;
+}
+
+static inline int hlist_empty(const struct hlist_head *h)
+{
+	return !h->first;
+}
+
+static inline void __hlist_del(struct hlist_node *n)
+{
+	struct hlist_node *next = n->next;
+	struct hlist_node **pprev = n->pprev;
+	*pprev = next;
+	if (next)
+		next->pprev = pprev;
+}
+
+static inline void hlist_del(struct hlist_node *n)
+{
+	__hlist_del(n);
+	n->next = LIST_POISON1;
+	n->pprev = LIST_POISON2;
+}
+
+static inline void hlist_del_init(struct hlist_node *n)
+{
+	if (n->pprev)  {
+		__hlist_del(n);
+		INIT_HLIST_NODE(n);
+	}
+}
+
+static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
+{
+	struct hlist_node *first = h->first;
+	n->next = first;
+	if (first)
+		first->pprev = &n->next;
+	h->first = n;
+	n->pprev = &h->first;
+}
+
+/* next must be != NULL */
+static inline void hlist_add_before(struct hlist_node *n,
+					struct hlist_node *next)
+{
+	n->pprev = next->pprev;
+	n->next = next;
+	next->pprev = &n->next;
+	*(n->pprev) = n;
+}
+
+static inline void hlist_add_after(struct hlist_node *n,
+					struct hlist_node *next)
+{
+	next->next = n->next;
+	n->next = next;
+	next->pprev = &n->next;
+
+	if(next->next)
+		next->next->pprev  = &next->next;
+}
+
+#define hlist_entry(ptr, type, member) container_of(ptr,type,member)
+
+#define hlist_for_each(pos, head) \
+	for (pos = (head)->first; pos && ({ prefetch(pos->next); 1; }); \
+	     pos = pos->next)
+
+#define hlist_for_each_safe(pos, n, head) \
+	for (pos = (head)->first; pos && ({ n = pos->next; 1; }); \
+	     pos = n)
+
+/**
+ * hlist_for_each_entry	- iterate over list of given type
+ * @tpos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry(tpos, pos, head, member)			 \
+	for (pos = (head)->first;					 \
+	     pos && ({ prefetch(pos->next); 1;}) &&			 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
+ * hlist_for_each_entry_continue - iterate over a hlist continuing after existing point
+ * @tpos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_continue(tpos, pos, member)		 \
+	for (pos = (pos)->next;						 \
+	     pos && ({ prefetch(pos->next); 1;}) &&			 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
+ * hlist_for_each_entry_from - iterate over a hlist continuing from existing point
+ * @tpos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_from(tpos, pos, member)			 \
+	for (; pos && ({ prefetch(pos->next); 1;}) &&			 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
+ * hlist_for_each_entry_safe - iterate over list of given type safe against removal of list entry
+ * @tpos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @n:		another &struct hlist_node to use as temporary storage
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_safe(tpos, pos, n, head, member) 		 \
+	for (pos = (head)->first;					 \
+	     pos && ({ n = pos->next; 1; }) && 				 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = n)
+
+#endif
/cvs/lvm2/LVM2/daemons/clogd/local.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/local.c
+++ -	2009-01-08 17:12:35.427693000 +0000
@@ -0,0 +1,379 @@
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
+#include "linux/dm-clog-tfr.h"
+#include "functions.h"
+#include "cluster.h"
+#include "common.h"
+#include "logging.h"
+#include "link_mon.h"
+#include "local.h"
+
+static int cn_fd;  /* Connector (netlink) socket fd */
+static char recv_buf[2048];
+
+
+/* FIXME: merge this function with kernel_send_helper */
+static int kernel_ack(uint32_t seq, int error)
+{
+	int r;
+	unsigned char buf[sizeof(struct nlmsghdr) + sizeof(struct cn_msg)];
+	struct nlmsghdr *nlh = (struct nlmsghdr *)buf;
+	struct cn_msg *msg = NLMSG_DATA(nlh);
+
+	if (error < 0) {
+		LOG_ERROR("Programmer error: error codes must be positive");
+		return -EINVAL;
+	}
+
+	memset(buf, 0, sizeof(buf));
+
+	nlh->nlmsg_seq = 0;
+	nlh->nlmsg_pid = getpid();
+	nlh->nlmsg_type = NLMSG_DONE;
+	nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct cn_msg));
+	nlh->nlmsg_flags = 0;
+
+	msg->len = 0;
+	msg->id.idx = 0x4;
+	msg->id.val = 0x1;
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
+ * @tfr: the newly allocated request from kernel
+ *
+ * Read requests from the kernel and allocate space for the new request.
+ * If there is no request from the kernel, *tfr is NULL.
+ *
+ * This function is not thread safe due to returned stack pointer.  In fact,
+ * the returned pointer must not be in-use when this function is called again.
+ *
+ * Returns: 0 on success, -EXXX on error
+ */
+static int kernel_recv(struct clog_tfr **tfr)
+{
+	int r = 0;
+	int len;
+	struct cn_msg *msg;
+
+	*tfr = NULL;
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
+		if (msg->len > DM_CLOG_TFR_SIZE) {
+			LOG_ERROR("Not enough space to receive kernel request (%d/%d)",
+				  msg->len, DM_CLOG_TFR_SIZE);
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
+		*tfr = (struct clog_tfr *)msg->data;
+
+		if (!(*tfr)->request_type) {
+			LOG_DBG("Bad transmission, requesting resend [%u]", msg->seq);
+			r = -EAGAIN;
+
+			if (kernel_ack(msg->seq, EAGAIN)) {
+				LOG_ERROR("Failed to NACK kernel transmission [%u]",
+					  msg->seq);
+				r = -EBADE;
+			}
+		}
+		break;
+	default:
+		LOG_ERROR("Unknown nlmsg_type");
+		r = -EBADE;
+	}
+
+fail:
+	if (r)
+		*tfr = NULL;
+
+	return (r == -EAGAIN) ? 0 : r;
+}
+
+static int kernel_send_helper(void *data, int out_size)
+{
+	int r;
+	struct nlmsghdr *nlh;
+	struct cn_msg *msg;
+	unsigned char buf[2048];
+
+	memset(buf, 0, sizeof(buf));
+
+	nlh = (struct nlmsghdr *)buf;
+	nlh->nlmsg_seq = 0;  /* FIXME: Is this used? */
+	nlh->nlmsg_pid = getpid();
+	nlh->nlmsg_type = NLMSG_DONE;
+	nlh->nlmsg_len = NLMSG_LENGTH(out_size + sizeof(struct cn_msg));
+	nlh->nlmsg_flags = 0;
+
+	msg = NLMSG_DATA(nlh);
+	memcpy(msg->data, data, out_size);
+	msg->len = out_size;
+	msg->id.idx = 0x4;
+	msg->id.val = 0x1;
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
+ * Any processing errors are placed in the 'tfr'
+ * structure to be reported back to the kernel.
+ * It may be pointless for this function to
+ * return an int.
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int do_local_work(void *data)
+{
+	int r;
+	struct clog_tfr *tfr = NULL;
+
+	r = kernel_recv(&tfr);
+	if (r)
+		return r;
+
+	if (!tfr)
+		return 0;
+
+	LOG_DBG("[%s]  Request from kernel received: [%s/%u]",
+		SHORT_UUID(tfr->uuid), RQ_TYPE(tfr->request_type),
+		tfr->seq);
+	switch (tfr->request_type) {
+	case DM_CLOG_CTR:
+	case DM_CLOG_DTR:
+	case DM_CLOG_IN_SYNC:
+	case DM_CLOG_GET_SYNC_COUNT:
+	case DM_CLOG_STATUS_INFO:
+	case DM_CLOG_STATUS_TABLE:
+	case DM_CLOG_PRESUSPEND:
+		/* We do not specify ourselves as server here */
+		r = do_request(tfr, 0);
+		if (r)
+			LOG_DBG("Returning failed request to kernel [%s]",
+				RQ_TYPE(tfr->request_type));
+		r = kernel_send(tfr);
+		if (r)
+			LOG_ERROR("Failed to respond to kernel [%s]",
+				  RQ_TYPE(tfr->request_type));
+			
+		break;
+	case DM_CLOG_RESUME:
+		/*
+		 * Resume is a special case that requires a local
+		 * component to join the CPG, and a cluster component
+		 * to handle the request.
+		 */
+		r = local_resume(tfr);
+		if (r) {
+			LOG_DBG("Returning failed request to kernel [%s]",
+				RQ_TYPE(tfr->request_type));
+			r = kernel_send(tfr);
+			if (r)
+				LOG_ERROR("Failed to respond to kernel [%s]",
+					  RQ_TYPE(tfr->request_type));
+			break;
+		}
+		/* ELSE, fall through */
+	case DM_CLOG_IS_CLEAN:
+	case DM_CLOG_FLUSH:
+	case DM_CLOG_MARK_REGION:
+	case DM_CLOG_GET_RESYNC_WORK:
+	case DM_CLOG_SET_REGION_SYNC:
+	case DM_CLOG_IS_REMOTE_RECOVERING:
+	case DM_CLOG_POSTSUSPEND:
+		r = cluster_send(tfr);
+		if (r) {
+			tfr->data_size = 0;
+			tfr->error = r;
+			kernel_send(tfr);
+		}
+
+		break;
+	case DM_CLOG_CLEAR_REGION:
+		r = kernel_ack(tfr->seq, 0);
+
+		r = cluster_send(tfr);
+		if (r) {
+			/*
+			 * FIXME: store error for delivery on flush
+			 *        This would allow us to optimize MARK_REGION
+			 *        too.
+			 */
+		}
+
+		break;
+	case DM_CLOG_GET_REGION_SIZE:
+	default:
+		LOG_ERROR("Invalid log request received, ignoring.");
+		return 0;
+	}
+
+	if (r && !tfr->error)
+		tfr->error = r;
+
+	return r;
+}
+
+/*
+ * kernel_send
+ * @tfr: result to pass back to kernel
+ *
+ * This function returns the tfr structure
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
+int kernel_send(struct clog_tfr *tfr)
+{
+	int r;
+	int size;
+
+	if (!tfr)
+		return -EINVAL;
+
+	size = sizeof(struct clog_tfr) + tfr->data_size;
+
+	if (!tfr->data_size && !tfr->error) {
+		/* An ACK is all that is needed */
+
+		/* FIXME: add ACK code */
+	} else if (size > DM_CLOG_TFR_SIZE) {
+		/*
+		 * If we gotten here, we've already overrun
+		 * our allotted space somewhere.
+		 *
+		 * We must do something, because the kernel
+		 * is waiting for a response.
+		 */
+		LOG_ERROR("Not enough space to respond to server");
+		tfr->error = -ENOSPC;
+		size = sizeof(struct clog_tfr);
+	}
+
+	r = kernel_send_helper(tfr, size);
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
+		return EXIT_KERNEL_TFR_SOCKET;
+
+	/* memset to fix valgrind complaint */
+	memset(&addr, 0, sizeof(struct sockaddr_nl));
+
+	addr.nl_family = AF_NETLINK;
+	addr.nl_groups = 0x4;
+	addr.nl_pid = 0;
+
+	r = bind(cn_fd, (struct sockaddr *) &addr, sizeof(addr));
+	if (r < 0) {
+		close(cn_fd);
+		return EXIT_KERNEL_TFR_BIND;
+	}
+
+	opt = addr.nl_groups;
+	r = setsockopt(cn_fd, 270, NETLINK_ADD_MEMBERSHIP, &opt, sizeof(opt));
+	if (r) {
+		close(cn_fd);
+		return EXIT_KERNEL_TFR_SETSOCKOPT;
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
/cvs/lvm2/LVM2/daemons/clogd/local.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/local.h
+++ -	2009-01-08 17:12:35.534383000 +0000
@@ -0,0 +1,9 @@
+#ifndef __CLUSTER_LOG_LOCAL_DOT_H__
+#define __CLUSTER_LOG_LOCAL_DOT_H__
+
+int init_local(void);
+void cleanup_local(void);
+
+int kernel_send(struct clog_tfr *tfr);
+
+#endif /* __CLUSTER_LOG_LOCAL_DOT_H__ */
/cvs/lvm2/LVM2/daemons/clogd/logging.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/logging.c
+++ -	2009-01-08 17:12:35.653409000 +0000
@@ -0,0 +1,25 @@
+#include <syslog.h>
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
/cvs/lvm2/LVM2/daemons/clogd/logging.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/clogd/logging.h
+++ -	2009-01-08 17:12:35.763194000 +0000
@@ -0,0 +1,81 @@
+#ifndef __CLUSTER_LOG_LOGGING_DOT_H__
+#define __CLUSTER_LOG_LOGGING_DOT_H__
+
+#include <stdio.h>
+#include <syslog.h>
+
+#if (BITS_PER_LONG == 64)
+#define PRIu64 "lu"
+#define PRId64 "ld"
+#define PRIo64 "lo"
+#define PRIx64 "lx"
+#define PRIX64 "lX"
+#define SCNu64 "lu"
+#define SCNd64 "ld"
+#define SCNo64 "lo"
+#define SCNx64 "lx"
+#define SCNX64 "lX"
+#else
+#define PRIu64 "Lu"
+#define PRId64 "Ld"
+#define PRIo64 "Lo"
+#define PRIx64 "Lx"
+#define PRIX64 "LX"
+#define SCNu64 "Lu"
+#define SCNd64 "Ld"
+#define SCNo64 "Lo"
+#define SCNx64 "Lx"
+#define SCNX64 "LX"
+#endif
+
+/* SHORT_UUID - print last 8 chars of a string */
+#define SHORT_UUID(x) (strlen(x) > 8) ? ((x) + (strlen(x) - 8)) : (x)
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


