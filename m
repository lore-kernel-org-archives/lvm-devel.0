From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 10:14:07 -0000
Subject: LVM2/daemons clvmd/clvmd.c dmeventd/libdevmapp ...
Message-ID: <20120228101407.17124.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 10:14:06

Modified files:
	daemons/clvmd  : clvmd.c 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Add log_sys_error for close

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/daemons/clvmd/clvmd.c	2012/02/28 09:58:20	1.126
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/28 10:14:06	1.127
@@ -669,7 +669,8 @@
 	if (client_fd >= 0) {
 		newfd = malloc(sizeof(struct local_client));
 		if (!newfd) {
-			close(client_fd);
+			if (close(client_fd))
+                                log_sys_error("close", "socket");
 			return 1;
 		}
 
@@ -2113,7 +2114,7 @@
 static void close_local_sock(int local_socket)
 {
 	if (local_socket != -1 && close(local_socket))
-		stack;
+		log_sys_error("close", CLVMD_SOCKNAME);
 
 	if (CLVMD_SOCKNAME[0] != '\0' && unlink(CLVMD_SOCKNAME))
 		stack;
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/15 13:56:47	1.45
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/28 10:14:06	1.46
@@ -432,14 +432,12 @@
 	fifos->client = open(fifos->client_path, O_WRONLY | O_NONBLOCK);
 	if (fifos->client >= 0) {
 		/* server is running and listening */
-
-		close(fifos->client);
+		if (close(fifos->client))
+			log_sys_error("close", fifos->client_path);
 		return 1;
 	} else if (errno != ENXIO) {
 		/* problem */
-
-		log_error("%s: Can't open client fifo %s: %s",
-			  __func__, fifos->client_path, strerror(errno));
+		log_sys_error("open", fifos->client_path);
 		return 0;
 	}
 
@@ -447,14 +445,14 @@
 	/* server is not running */
 
 	if (!strncmp(DMEVENTD_PATH, "/", 1) && stat(DMEVENTD_PATH, &statbuf)) {
-		log_error("Unable to find dmeventd.");
+		log_sys_error("stat", DMEVENTD_PATH);
 		return 0;
 	}
 
 	pid = fork();
 
 	if (pid < 0)
-		log_error("Unable to fork.");
+		log_sys_error("fork", "");
 
 	else if (!pid) {
 		execvp(args[0], args);
@@ -484,23 +482,23 @@
 
 	/* Open the fifo used to read from the daemon. */
 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
-		log_error("%s: open server fifo %s",
-			  __func__, fifos->server_path);
+		log_sys_error("open", fifos->server_path);
 		return 0;
 	}
 
 	/* Lock out anyone else trying to do communication with the daemon. */
 	if (flock(fifos->server, LOCK_EX) < 0) {
-		log_error("%s: flock %s", __func__, fifos->server_path);
-		close(fifos->server);
+		log_sys_error("flock", fifos->server_path);
+		if (close(fifos->server))
+			log_sys_error("close", fifos->server_path);
 		return 0;
 	}
 
 /*	if ((fifos->client = open(fifos->client_path, O_WRONLY | O_NONBLOCK)) < 0) {*/
 	if ((fifos->client = open(fifos->client_path, O_RDWR | O_NONBLOCK)) < 0) {
-		log_error("%s: Can't open client fifo %s: %s",
-			  __func__, fifos->client_path, strerror(errno));
-		close(fifos->server);
+		log_sys_error("open", fifos->client_path);
+		if (close(fifos->server))
+			log_sys_error("close", fifos->server_path);
 		return 0;
 	}
 
@@ -528,8 +526,10 @@
 	if (flock(fifos->server, LOCK_UN))
 		log_error("flock unlock %s", fifos->server_path);
 
-	close(fifos->client);
-	close(fifos->server);
+	if (close(fifos->client))
+		log_sys_error("close", fifos->client_path);
+	if (close(fifos->server))
+		log_sys_error("close", fifos->server_path);
 }
 
 /* Get uuid of a device */


