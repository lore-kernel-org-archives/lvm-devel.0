From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 20 Apr 2010 14:07:40 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvm.h daemons/ ...
Message-ID: <20100420140740.19819.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2010-04-20 14:07:39

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvm.h clvmd-command.c clvmd.c lvm-functions.c 
	                 lvm-functions.h refresh_clvmd.c refresh_clvmd.h 
	man            : clvmd.8.in 
	scripts        : clvmd_init_red_hat.in 

Log message:
	Add -S command to clvmd, so it can restart itself and still
	preserve exlusive LV locks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1530&r2=1.1531
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvm.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2010/04/19 15:24:00	1.1530
+++ LVM2/WHATS_NEW	2010/04/20 14:07:37	1.1531
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Add -S command to clvmd to restart the daemon preserving exclusive locks.
   Increment lvm2app version from 1 to 2.
   Change lvm2app memory alloc/free for pv/vg/lv properties.
   Change daemon lock filename from lvm2_monitor to lvm2-monitor for consistency.
--- LVM2/daemons/clvmd/clvm.h	2009/05/19 10:38:58	1.7
+++ LVM2/daemons/clvmd/clvm.h	2010/04/20 14:07:38	1.8
@@ -69,4 +69,5 @@
 #define CLVMD_CMD_GET_CLUSTERNAME   41
 #define CLVMD_CMD_SET_DEBUG	    42
 #define CLVMD_CMD_VG_BACKUP	    43
+#define CLVMD_CMD_RESTART	    44
 #endif
--- LVM2/daemons/clvmd/clvmd-command.c	2010/01/05 16:07:57	1.31
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/04/20 14:07:38	1.32
@@ -80,6 +80,7 @@
 
 extern debug_t debug;
 extern struct cluster_ops *clops;
+static int restart_clvmd(void);
 
 /* This is where all the real work happens:
    NOTE: client will be NULL when this is executed on a remote node */
@@ -158,6 +159,10 @@
 		debug = args[0];
 		break;
 
+	case CLVMD_CMD_RESTART:
+		restart_clvmd();
+		break;
+
 	case CLVMD_CMD_GET_CLUSTERNAME:
 		status = clops->get_cluster_name(*buf, buflen);
 		if (!status)
@@ -285,6 +290,7 @@
 	case CLVMD_CMD_SET_DEBUG:
 	case CLVMD_CMD_VG_BACKUP:
 	case CLVMD_CMD_LOCK_QUERY:
+	case CLVMD_CMD_RESTART:
 		break;
 
 	default:
@@ -351,3 +357,50 @@
 	client->bits.localsock.private = 0;
     }
 }
+
+
+static int restart_clvmd(void)
+{
+	char *argv[1024];
+	int argc = 1;
+	struct dm_hash_node *hn = NULL;
+	char *lv_name;
+
+	DEBUGLOG("clvmd restart requested\n");
+
+	/*
+	 * Build the command-line
+	 */
+	argv[0] = strdup("clvmd");
+
+	/* Propogate debug options */
+	if (debug) {
+		char debug_level[16];
+
+		sprintf(debug_level, "-d%d", debug);
+		argv[argc++] = strdup(debug_level);
+	}
+
+	/* Now add the exclusively-open LVs */
+	do {
+		hn = get_next_excl_lock(hn, &lv_name);
+		if (lv_name) {
+			argv[argc++] = strdup("-E");
+			argv[argc++] = strdup(lv_name);
+
+			DEBUGLOG("excl lock: %s\n", lv_name);
+			hn = get_next_excl_lock(hn, &lv_name);
+		}
+	} while (hn && *lv_name);
+	argv[argc++] = NULL;
+
+	/* Tidy up */
+	destroy_lvm();
+
+	/* Exec new clvmd */
+	/* NOTE: This will fail when downgrading! */
+	execve("clvmd", argv, NULL);
+
+	/* We failed */
+	return 0;
+}
--- LVM2/daemons/clvmd/clvmd.c	2010/04/14 18:54:37	1.69
+++ LVM2/daemons/clvmd/clvmd.c	2010/04/20 14:07:38	1.70
@@ -92,6 +92,11 @@
 	unsigned short xid;
 };
 
+struct lvm_startup_params {
+	int using_gulm;
+	char **argv;
+};
+
 debug_t debug;
 static pthread_t lvm_thread;
 static pthread_mutex_t lvm_thread_mutex;
@@ -163,6 +168,7 @@
 	fprintf(file, "   -d       Set debug level\n");
 	fprintf(file, "            If starting clvmd then don't fork, run in the foreground\n");
 	fprintf(file, "   -R       Tell all running clvmds in the cluster to reload their device cache\n");
+	fprintf(file, "   -S       Restart clvmd, preserving exclusive locks\n");
 	fprintf(file, "   -C       Sets debug level (from -d) on all clvmd instances clusterwide\n");
 	fprintf(file, "   -t<secs> Command timeout (default 60 seconds)\n");
 	fprintf(file, "   -T<secs> Startup timeout (default none)\n");
@@ -268,6 +274,9 @@
 	case CLVMD_CMD_LOCK_QUERY:
 		command = "LOCK_QUERY";
 		break;
+	case CLVMD_CMD_RESTART:
+		command = "RESTART";
+		break;
 	default:
 		command = "unknown";
 		break;
@@ -283,6 +292,7 @@
 	int local_sock;
 	struct local_client *newfd;
 	struct utsname nodeinfo;
+	struct lvm_startup_params lvm_params;
 	signed char opt;
 	int cmd_timeout = DEFAULT_CMD_TIMEOUT;
 	int start_timeout = 0;
@@ -295,7 +305,7 @@
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt(argc, argv, "?vVhd::t:RT:CI:")) != EOF) {
+	while ((opt = getopt(argc, argv, "?vVhd::t:RST:CI:E:")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -306,7 +316,10 @@
 			exit(0);
 
 		case 'R':
-			return refresh_clvmd()==1?0:1;
+			return refresh_clvmd(1)==1?0:1;
+
+		case 'S':
+			return restart_clvmd(clusterwide_opt)==1?0:1;
 
 		case 'C':
 			clusterwide_opt = 1;
@@ -489,8 +502,10 @@
 
 	/* Don't let anyone else to do work until we are started */
 	pthread_mutex_lock(&lvm_start_mutex);
+	lvm_params.using_gulm = using_gulm;
+	lvm_params.argv = argv;
 	pthread_create(&lvm_thread, NULL, (lvm_pthread_fn_t*)lvm_thread_fn,
-			(void *)(long)using_gulm);
+			(void *)&lvm_params);
 
 	/* Tell the rest of the cluster our version number */
 	/* CMAN can do this immediately, gulm needs to wait until
@@ -551,6 +566,10 @@
 			close(client_fd);
 			return 1;
 		}
+
+		if (fcntl(client_fd, F_SETFD, 1))
+			DEBUGLOG("setting CLOEXEC on client fd failed: %s\n", strerror(errno));
+
 		newfd->fd = client_fd;
 		newfd->type = LOCAL_SOCK;
 		newfd->xid = 0;
@@ -1182,6 +1201,12 @@
 		}
 		DEBUGLOG("creating pipe, [%d, %d]\n", comms_pipe[0],
 			 comms_pipe[1]);
+
+		if (fcntl(comms_pipe[0], F_SETFD, 1))
+			DEBUGLOG("setting CLOEXEC on pipe[0] failed: %s\n", strerror(errno));
+		if (fcntl(comms_pipe[1], F_SETFD, 1))
+			DEBUGLOG("setting CLOEXEC on pipe[1] failed: %s\n", strerror(errno));
+
 		newfd->fd = comms_pipe[0];
 		newfd->removeme = 0;
 		newfd->type = THREAD_PIPE;
@@ -1830,7 +1855,7 @@
 {
 	struct dm_list *cmdl, *tmp;
 	sigset_t ss;
-	int using_gulm = (int)(long)arg;
+	struct lvm_startup_params *lvm_params = arg;
 
 	DEBUGLOG("LVM thread function started\n");
 
@@ -1841,7 +1866,7 @@
 	pthread_sigmask(SIG_BLOCK, &ss, NULL);
 
 	/* Initialise the interface to liblvm */
-	init_lvm(using_gulm);
+	init_lvm(lvm_params->using_gulm, lvm_params->argv);
 
 	/* Allow others to get moving */
 	pthread_mutex_unlock(&lvm_start_mutex);
@@ -1956,8 +1981,10 @@
 		log_error("Can't create local socket: %m");
 		return -1;
 	}
+
 	/* Set Close-on-exec & non-blocking */
-	fcntl(local_socket, F_SETFD, 1);
+	if (fcntl(local_socket, F_SETFD, 1))
+		DEBUGLOG("setting CLOEXEC on local_socket failed: %s\n", strerror(errno));
 	fcntl(local_socket, F_SETFL, fcntl(local_socket, F_GETFL, 0) | O_NONBLOCK);
 
 	memset(&sockaddr, 0, sizeof(sockaddr));
--- LVM2/daemons/clvmd/lvm-functions.c	2010/04/13 19:54:16	1.88
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/04/20 14:07:38	1.89
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -103,7 +103,7 @@
 		command = "LCK_VG";
 		break;
 	case LCK_LV:
-		scope = "LV"; 
+		scope = "LV";
 		switch (cmdl & LCK_MASK) {
 		case LCK_LV_EXCLUSIVE & LCK_MASK:
 			command = "LCK_LV_EXCLUSIVE";
@@ -727,12 +727,36 @@
 }
 
 /*
+ * Compare the uuid with the list of exclusive locks that clvmd
+ * held before it was restarted, so we can get the right kind
+ * of lock now we are restarting.
+ */
+static int was_ex_lock(char *uuid, char **argv)
+{
+	int optnum = 0;
+	char *opt = argv[optnum];
+
+	while (opt) {
+		if (strcmp(opt, "-E") == 0) {
+			opt = argv[++optnum];
+			if (opt && (strcmp(opt, uuid) == 0)) {
+				DEBUGLOG("Lock %s is exclusive\n", uuid);
+				return 1;
+			}
+		}
+		opt = argv[++optnum];
+	}
+	return 0;
+}
+
+/*
  * Ideally, clvmd should be started before any LVs are active
  * but this may not be the case...
  * I suppose this also comes in handy if clvmd crashes, not that it would!
  */
-static void *get_initial_state()
+static void *get_initial_state(char **argv)
 {
+	int lock_mode;
 	char lv[64], vg[64], flags[25], vg_flags[25];
 	char uuid[65];
 	char line[255];
@@ -768,8 +792,15 @@
 				memcpy(&uuid[58], &lv[32], 6);
 				uuid[64] = '\0';
 
+				lock_mode = LKM_CRMODE;
+
+				/* Look for this lock in the list of EX locks
+				   we were passed on the command-line */
+				if (was_ex_lock(uuid, argv))
+					lock_mode = LKM_EXMODE;
+
 				DEBUGLOG("getting initial lock for %s\n", uuid);
-				hold_lock(uuid, LKM_CRMODE, LKF_NOQUEUE);
+				hold_lock(uuid, lock_mode, LKF_NOQUEUE);
 			}
 		}
 	}
@@ -848,8 +879,31 @@
 	pthread_mutex_unlock(&lvm_lock);
 }
 
+struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name)
+{
+	struct lv_info *lvi;
+
+	*name = NULL;
+	if (!v)
+		v = dm_hash_get_first(lv_hash);
+
+	do {
+		if (v) {
+			lvi = dm_hash_get_data(lv_hash, v);
+			DEBUGLOG("Looking for EX locks. found %x mode %d\n", lvi->lock_id, lvi->lock_mode);
+
+			if (lvi->lock_mode == LCK_EXCL) {
+				*name = dm_hash_get_key(lv_hash, v);
+			}
+			v = dm_hash_get_next(lv_hash, v);
+		}
+	} while (v && !*name);
+	DEBUGLOG("returning EXclusive UUID %s\n", *name);
+	return v;
+}
+
 /* Called to initialise the LVM context of the daemon */
-int init_lvm(int using_gulm)
+int init_lvm(int using_gulm, char **argv)
 {
 	if (!(cmd = create_toolcontext(1, NULL))) {
 		log_error("Failed to allocate command context");
@@ -874,7 +928,7 @@
 	if (using_gulm)
 		drop_vg_locks();
 
-	get_initial_state();
+	get_initial_state(argv);
 
 	/* Trap log messages so we can pass them back to the user */
 	init_log_fn(lvm2_log_fn);
--- LVM2/daemons/clvmd/lvm-functions.h	2010/01/05 16:05:12	1.12
+++ LVM2/daemons/clvmd/lvm-functions.h	2010/04/20 14:07:38	1.13
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -27,7 +27,7 @@
 			char *resource);
 extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
-extern int init_lvm(int using_gulm);
+extern int init_lvm(int using_gulm, char **argv);
 extern void destroy_lvm(void);
 extern void init_lvhash(void);
 extern void destroy_lvhash(void);
@@ -37,5 +37,5 @@
 extern char *get_last_lvm_error(void);
 extern void do_lock_vg(unsigned char command, unsigned char lock_flags,
 		      char *resource);
-
+extern struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name);
 #endif
--- LVM2/daemons/clvmd/refresh_clvmd.c	2009/09/15 12:51:28	1.7
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2010/04/20 14:07:38	1.8
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -14,7 +14,7 @@
  */
 
 /*
- * Tell all clvmds in a cluster to refresh their toolcontext
+ * Send a command to a running clvmd from the command-line
  */
 
 #define _GNU_SOURCE
@@ -83,7 +83,7 @@
 }
 
 /* Send a request and return the status */
-static int _send_request(const char *inbuf, int inlen, char **retbuf)
+static int _send_request(const char *inbuf, int inlen, char **retbuf, int no_response)
 {
 	char outbuf[PIPE_BUF];
 	struct clvm_header *outheader = (struct clvm_header *) outbuf;
@@ -100,6 +100,8 @@
 		fprintf(stderr, "Error writing data to clvmd: %s", strerror(errno));
 		return 0;
 	}
+	if (no_response)
+		return 1;
 
 	/* Get the response */
  reread:
@@ -184,7 +186,7 @@
  * Send a message to a(or all) node(s) in the cluster and wait for replies
  */
 static int _cluster_request(char cmd, const char *node, void *data, int len,
-			   lvm_response_t ** response, int *num)
+			    lvm_response_t ** response, int *num, int no_response)
 {
 	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1];
 	char *inptr;
@@ -207,8 +209,8 @@
 	memcpy(head->node + strlen(head->node) + 1, data, len);
 
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
-			      strlen(head->node) + len, &retbuf);
-	if (!status)
+			       strlen(head->node) + len, &retbuf, no_response);
+	if (!status || no_response)
 		goto out;
 
 	/* Count the number of responses we got */
@@ -287,7 +289,7 @@
 	return 1;
 }
 
-int refresh_clvmd()
+int refresh_clvmd(int all_nodes)
 {
 	int num_responses;
 	char args[1]; // No args really.
@@ -296,7 +298,7 @@
 	int status;
 	int i;
 
-	status = _cluster_request(CLVMD_CMD_REFRESH, "*", args, 0, &response, &num_responses);
+	status = _cluster_request(CLVMD_CMD_REFRESH, all_nodes?"*":".", args, 0, &response, &num_responses, 0);
 
 	/* If any nodes were down then display them and return an error */
 	for (i = 0; i < num_responses; i++) {
@@ -323,6 +325,12 @@
 	return status;
 }
 
+int restart_clvmd(int all_nodes)
+{
+	int dummy;
+	return _cluster_request(CLVMD_CMD_RESTART, all_nodes?"*":".", NULL, 0, NULL, &dummy, 1);
+}
+
 int debug_clvmd(int level, int clusterwide)
 {
 	int num_responses;
@@ -339,7 +347,7 @@
 	else
 		nodes = ".";
 
-	status = _cluster_request(CLVMD_CMD_SET_DEBUG, nodes, args, 1, &response, &num_responses);
+	status = _cluster_request(CLVMD_CMD_SET_DEBUG, nodes, args, 1, &response, &num_responses, 0);
 
 	/* If any nodes were down then display them and return an error */
 	for (i = 0; i < num_responses; i++) {
--- LVM2/daemons/clvmd/refresh_clvmd.h	2007/08/17 11:51:23	1.2
+++ LVM2/daemons/clvmd/refresh_clvmd.h	2010/04/20 14:07:38	1.3
@@ -13,6 +13,7 @@
  */
 
 
-int refresh_clvmd(void);
+int refresh_clvmd(int all_nodes);
+int restart_clvmd(int all_nodes);
 int debug_clvmd(int level, int clusterwide);
 
--- LVM2/man/clvmd.8.in	2009/07/30 13:32:39	1.2
+++ LVM2/man/clvmd.8.in	2010/04/20 14:07:38	1.3
@@ -5,6 +5,7 @@
 .B clvmd
 [\-d [<value>]] [\-C] [\-h]
 [\-R]
+[\-S]
 [\-t <timeout>]
 [\-T <start timeout>]
 [\-V]
@@ -74,6 +75,12 @@
 re-read the lvm configuration file. This command should be run whenever the
 devices on a cluster system are changed.
 .TP
+.I \-S
+Tells the running clvmd to exit and restart. This is a preferred option
+to killing and restarting clvmd as it will preserve exclusive LV locks.
+If a full stop & restart is done instead, exclusive LV locks will be
+re-acquired as shared.
+.TP
 .I \-I
 Selects the cluster manager to use for locking and internal communications,
 the available managers will be listed as part of the 'clvmd -h' output.
--- LVM2/scripts/clvmd_init_red_hat.in	2010/02/26 13:07:43	1.5
+++ LVM2/scripts/clvmd_init_red_hat.in	2010/04/20 14:07:38	1.6
@@ -146,7 +146,17 @@
 	# another start. Even if start is protected by rh_status_q,
 	# that would avoid spawning another daemon, it would try to
 	# reactivate the VGs.
-	stop && start
+
+	# Try to get clvmd to restart itself. This will preserve 
+	# exclusive LV locks
+	action "Restarting $DAEMON: " $DAEMON -S || return $?
+
+	# If that fails then do a normal stop & restart
+	if  [ $? != 0 ]; then
+	    stop && start
+	else
+	    touch $LOCK_FILE
+	fi
 }
 
 # See how we were called.


