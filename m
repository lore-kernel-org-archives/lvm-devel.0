From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jul 2010 14:01:42 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenod ...
Message-ID: <20100728140142.453.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-28 14:01:41

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-singlenode.c clvmd.c 

Log message:
	Never use clvmd singlenode unless explicitly requested with -Isinglenode.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1675&r2=1.1676
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/WHATS_NEW	2010/07/28 13:55:42	1.1675
+++ LVM2/WHATS_NEW	2010/07/28 14:01:40	1.1676
@@ -3,6 +3,7 @@
   Change clvmd to communicate with lvm2 via a socket in /var/run/lvm.
   Return controlled error if clvmd is run by non-root user.
   Add configure --default-run-dir for /var/run/lvm.
+  Never use clvmd singlenode unless explicitly requested with -Isinglenode.
 
 Version 2.02.71 - 28th July 2010
 ================================
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/06/21 15:56:58	1.4
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2010/07/28 14:01:41	1.5
@@ -26,17 +26,29 @@
 #include <sys/socket.h>
 #include <fcntl.h>
 
-static const char SINGLENODE_CLVMD_SOCKNAME[] = "\0singlenode_clvmd";
+static const char SINGLENODE_CLVMD_SOCKNAME[] = DEFAULT_RUN_DIR "/clvmd_singlenode.sock";
 static int listen_fd = -1;
 
+static void close_comms()
+{
+	if (listen_fd != -1 && close(listen_fd))
+		stack;
+	(void)unlink(SINGLENODE_CLVMD_SOCKNAME);
+	listen_fd = -1;
+}
+
 static int init_comms()
 {
 	struct sockaddr_un addr;
+	mode_t old_mask;
+
+	close_comms();
+	old_mask = umask(0077);
 
 	listen_fd = socket(PF_UNIX, SOCK_STREAM, 0);
 	if (listen_fd < 0) {
 		DEBUGLOG("Can't create local socket: %s\n", strerror(errno));
-		return -1;
+		goto error;
 	}
 	/* Set Close-on-exec */
 	fcntl(listen_fd, F_SETFD, 1);
@@ -48,16 +60,19 @@
 
 	if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
 		DEBUGLOG("Can't bind local socket: %s\n", strerror(errno));
-		close(listen_fd);
-		return -1;
+		goto error;
 	}
 	if (listen(listen_fd, 10) < 0) {
 		DEBUGLOG("Can't listen local socket: %s\n", strerror(errno));
-		close(listen_fd);
-		return -1;
+		goto error;
 	}
 
+	umask(old_mask);
 	return 0;
+error:
+	umask(old_mask);
+	close_comms();
+	return -1;
 }
 
 static int _init_cluster(void)
@@ -74,7 +89,7 @@
 
 static void _cluster_closedown(void)
 {
-	close(listen_fd);
+	close_comms();
 
 	DEBUGLOG("cluster_closedown\n");
 	destroy_lvhash();
--- LVM2/daemons/clvmd/clvmd.c	2010/07/28 13:55:43	1.74
+++ LVM2/daemons/clvmd/clvmd.c	2010/07/28 14:01:41	1.75
@@ -479,7 +479,7 @@
 #endif
 #ifdef USE_SINGLENODE
 	if (!clops)
-		if ((cluster_iface == IF_AUTO || cluster_iface == IF_SINGLENODE) && (clops = init_singlenode_cluster())) {
+		if (cluster_iface == IF_SINGLENODE && (clops = init_singlenode_cluster())) {
 			max_csid_len = SINGLENODE_CSID_LEN;
 			max_cluster_message = SINGLENODE_MAX_CLUSTER_MESSAGE;
 			max_cluster_member_name_len = MAX_CLUSTER_MEMBER_NAME_LEN;


