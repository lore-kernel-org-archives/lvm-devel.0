From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 17 Aug 2007 11:51:24 -0000
Subject: LVM2 ./WHATS_NEW man/clvmd.8 daemons/clvmd/clv ...
Message-ID: <20070817115124.11292.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-08-17 11:51:23

Modified files:
	.              : WHATS_NEW 
	man            : clvmd.8 
	daemons/clvmd  : clvm.h clvmd-command.c clvmd.c clvmd.h 
	                 refresh_clvmd.c refresh_clvmd.h 

Log message:
	Allow clvmd debug to be turned on in a running daemon using clvmd -d
	You can do with cluster-wide too, by adding -C

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.683&r2=1.684
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvm.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2007/08/14 18:58:30	1.683
+++ LVM2/WHATS_NEW	2007/08/17 11:51:22	1.684
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Allow clvmd debug to be turned on in a running daemon using clvmd -d
   Update to use autoconf 2.61, while still supporting 2.57.
   Add more cluster info to lvmdump
   Add const attributes where possible, first cut.
--- LVM2/man/clvmd.8	2006/12/11 14:06:25	1.4
+++ LVM2/man/clvmd.8	2007/08/17 11:51:23	1.5
@@ -3,7 +3,7 @@
 clvmd \- cluster LVM daemon
 .SH SYNOPSIS
 .B clvmd
-[\-d] [\-h]
+[\-d [<value>]] [\-C] [\-h]
 [\-R]
 [\-t <timeout>]
 [\-T <start timeout>]
@@ -14,9 +14,27 @@
 if a node in the cluster does not have this daemon running.
 .SH OPTIONS
 .TP
-.I \-d
-Runs in the foreground and prints debugging information (if compiled in) to
-stderr. By default, clvmd will fork into the background when invoked.
+.I \-d [<value>]
+Enable debug logging. Value can be 0, 1 or 2.
+.br
+0 disables debug logging in a running clvmd
+.br
+1 sends debug logs to stderr (clvmd will not fork in this case)
+.br
+2 sends debug logs to syslog
+.br
+If 
+.B -d 
+is specified without a value then 1 is assumed if you are starting a
+new clvmd, 2 if you are enabling debug in a running clvmd.
+.TP
+.I \-C
+Only valid if 
+.B -d 
+is also specified. Tells all clvmds in a cluster to enable/disable debug logging.
+Without this switch, only the local clvmd will change its debug level to that
+given with 
+.B -d.
 .TP
 .I \-t <timeout>
 Specifies the timeout for commands to run around the cluster. This should not
@@ -42,7 +60,7 @@
 This timeout will be ignored if you start clvmd with the -d switch.
 .TP
 .I \-R
-Tells all the running clvmd in the cluster to reload their device cache and
+Tells all the running clvmds in the cluster to reload their device cache and
 re-read the lvm configuration file. This command should be run whenever the
 devices on a cluster system are changed.
 .TP
--- LVM2/daemons/clvmd/clvm.h	2006/10/09 14:11:57	1.4
+++ LVM2/daemons/clvmd/clvm.h	2007/08/17 11:51:23	1.5
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -66,5 +66,5 @@
 /* Misc functions */
 #define CLVMD_CMD_REFRESH	    40
 #define CLVMD_CMD_GET_CLUSTERNAME   41
-
+#define CLVMD_CMD_SET_DEBUG	    42
 #endif
--- LVM2/daemons/clvmd/clvmd-command.c	2007/05/02 12:22:40	1.16
+++ LVM2/daemons/clvmd/clvmd-command.c	2007/08/17 11:51:23	1.17
@@ -75,6 +75,7 @@
 #include "clvm.h"
 #include "clvmd.h"
 
+extern debug_t debug;
 extern struct cluster_ops *clops;
 
 /* This is where all the real work happens:
@@ -137,6 +138,10 @@
 		do_refresh_cache();
 		break;
 
+	case CLVMD_CMD_SET_DEBUG:
+		debug = args[0];
+		break;
+
 	case CLVMD_CMD_GET_CLUSTERNAME:
 		status = clops->get_cluster_name(*buf, buflen);
 		if (!status)
@@ -249,6 +254,7 @@
 
 	case CLVMD_CMD_REFRESH:
 	case CLVMD_CMD_GET_CLUSTERNAME:
+	case CLVMD_CMD_SET_DEBUG:
 		break;
 
 	default:
--- LVM2/daemons/clvmd/clvmd.c	2007/06/14 10:16:35	1.38
+++ LVM2/daemons/clvmd/clvmd.c	2007/08/17 11:51:23	1.39
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -83,7 +83,8 @@
 	int msglen;
 	unsigned short xid;
 };
-static int debug = 0;
+
+debug_t debug;
 static pthread_t lvm_thread;
 static pthread_mutex_t lvm_thread_mutex;
 static pthread_cond_t lvm_thread_cond;
@@ -121,6 +122,7 @@
 static int process_reply(const struct clvm_header *msg, int msglen,
 			 const char *csid);
 static int open_local_sock(void);
+static int check_local_clvmd(void);
 static struct local_client *find_client(int clientid);
 static void main_loop(int local_sock, int cmd_timeout);
 static void be_daemon(int start_timeout);
@@ -167,15 +169,23 @@
 {
 	time_t P;
 	va_list ap;
+	static int syslog_init = 0;
 
-	if (!debug)
-		return;
-
-	va_start(ap,fmt);
-	time(&P);
- 	fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime(&P)+4 );
-	vfprintf(stderr, fmt, ap);
-	va_end(ap);
+	if (debug == DEBUG_STDERR) {
+		va_start(ap,fmt);
+		time(&P);
+		fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime(&P)+4 );
+		vfprintf(stderr, fmt, ap);
+		va_end(ap);
+	}
+	if (debug == DEBUG_SYSLOG) {
+		if (!syslog_init)
+			openlog("clvmd", LOG_PID, LOG_DAEMON);
+
+		va_start(ap,fmt);
+		vsyslog(LOG_DEBUG, fmt, ap);
+		va_end(ap);
+	}
 }
 
 int main(int argc, char *argv[])
@@ -188,11 +198,13 @@
 	int start_timeout = 0;
 	sigset_t ss;
 	int using_gulm = 0;
+	int debug_opt = 0;
+	int clusterwide_opt = 0;
 
 	/* Deal with command-line arguments */
 	opterr = 0;
 	optind = 0;
-	while ((opt = getopt(argc, argv, "?vVhdt:RT:")) != EOF) {
+	while ((opt = getopt(argc, argv, "?vVhd::t:RT:C")) != EOF) {
 		switch (opt) {
 		case 'h':
 			usage(argv[0], stdout);
@@ -205,8 +217,16 @@
 		case 'R':
 			return refresh_clvmd();
 
+		case 'C':
+			clusterwide_opt = 1;
+			break;
+
 		case 'd':
-			debug++;
+			debug_opt = 1;
+			if (optarg)
+				debug = atoi(optarg);
+			else
+				debug = DEBUG_STDERR;
 			break;
 
 		case 't':
@@ -237,8 +257,17 @@
 		}
 	}
 
+	/* Setting debug options on an existing clvmd */
+	if (debug_opt && !check_local_clvmd()) {
+
+		/* Sending to stderr makes no sense for a detached daemon */
+		if (debug == DEBUG_STDERR)
+			debug = DEBUG_SYSLOG;
+		return debug_clvmd(debug, clusterwide_opt);
+	}
+
 	/* Fork into the background (unless requested not to) */
-	if (!debug) {
+	if (debug != DEBUG_STDERR) {
 		be_daemon(start_timeout);
 	}
 
@@ -1753,6 +1782,32 @@
 	return 0;
 }
 
+/* Return 0 if we can talk to an existing clvmd */
+static int check_local_clvmd(void)
+{
+	int local_socket;
+	struct sockaddr_un sockaddr;
+	int ret = 0;
+
+	/* Open local socket */
+	if ((local_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0) {
+		return -1;
+	}
+
+	memset(&sockaddr, 0, sizeof(sockaddr));
+	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));
+	sockaddr.sun_family = AF_UNIX;
+
+	if (connect(local_socket,(struct sockaddr *) &sockaddr,
+		    sizeof(sockaddr))) {
+		ret = -1;
+	}
+
+	close(local_socket);
+	return ret;
+}
+
+
 /* Open the local socket, that's the one we talk to libclvm down */
 static int open_local_sock()
 {
--- LVM2/daemons/clvmd/clvmd.h	2007/07/20 15:38:19	1.10
+++ LVM2/daemons/clvmd/clvmd.h	2007/08/17 11:51:23	1.11
@@ -35,6 +35,8 @@
 	struct node_reply *next;
 };
 
+typedef enum {DEBUG_OFF, DEBUG_STDERR, DEBUG_SYSLOG} debug_t;
+
 /*
  * These exist for the use of local sockets only when we are
  * collecting responses from all cluster nodes
--- LVM2/daemons/clvmd/refresh_clvmd.c	2007/08/07 09:06:05	1.3
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2007/08/17 11:51:23	1.4
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -45,7 +45,7 @@
 
 static int _clvmd_sock = -1;
 
-/* Open connection to the Cluster Manager daemon */
+/* Open connection to the clvm daemon */
 static int _open_local_sock(void)
 {
 	int local_socket;
@@ -318,3 +318,46 @@
 
 	return status;
 }
+
+int debug_clvmd(int level, int clusterwide)
+{
+	int num_responses;
+	char args[1];
+	const char *nodes;
+	lvm_response_t *response;
+	int saved_errno;
+	int status;
+	int i;
+
+	args[0] = level;
+	if (clusterwide)
+		nodes = "*";
+	else
+		nodes = ".";
+
+	status = _cluster_request(CLVMD_CMD_SET_DEBUG, nodes, args, 1, &response, &num_responses);
+
+	/* If any nodes were down then display them and return an error */
+	for (i = 0; i < num_responses; i++) {
+		if (response[i].status == EHOSTDOWN) {
+			fprintf(stderr, "clvmd not running on node %s",
+				  response[i].node);
+			status = 0;
+			errno = response[i].status;
+		} else if (response[i].status) {
+			fprintf(stderr, "Error setting debug on node %s: %s",
+				  response[i].node,
+				  response[i].response[0] ?
+				  	response[i].response :
+				  	strerror(response[i].status));
+			status = 0;
+			errno = response[i].status;
+		}
+	}
+
+	saved_errno = errno;
+	_cluster_free_request(response, num_responses);
+	errno = saved_errno;
+
+	return status;
+}
--- LVM2/daemons/clvmd/refresh_clvmd.h	2006/10/04 08:22:16	1.1
+++ LVM2/daemons/clvmd/refresh_clvmd.h	2007/08/17 11:51:23	1.2
@@ -1,2 +1,18 @@
+/*
+ * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+
 int refresh_clvmd(void);
+int debug_clvmd(int level, int clusterwide);
 


