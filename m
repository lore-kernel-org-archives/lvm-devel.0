From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: Mon, 17 Mar 2008 09:38:29 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20080317093748.18285.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-03-17 09:37:47

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix potential thread deadlock.
	Also make local sockets non-blocking.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.803&r2=1.804
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW	2008/03/13 12:33:21	1.803
+++ LVM2/WHATS_NEW	2008/03/17 09:37:47	1.804
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix potential deadlock in clvmd thread handling.
   Refactor text format initialisation into _init_text_import.
   Escape double quotes and backslashes in external metadata and config data.
   Add functions for escaping double quotes in strings.
--- LVM2/daemons/clvmd/clvmd.c	2008/03/06 08:41:05	1.43
+++ LVM2/daemons/clvmd/clvmd.c	2008/03/17 09:37:47	1.44
@@ -1416,7 +1416,8 @@
 		DEBUGLOG("Waiting for next pre command\n");
 
 		pthread_mutex_lock(&client->bits.localsock.mutex);
-		if (client->bits.localsock.state != PRE_COMMAND) {
+		if (client->bits.localsock.state != PRE_COMMAND &&
+		    !client->bits.localsock.finished) {
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
 		}
@@ -1822,8 +1823,9 @@
 		log_error("Can't create local socket: %m");
 		return -1;
 	}
-	/* Set Close-on-exec */
+	/* Set Close-on-exec & non-blocking */
 	fcntl(local_socket, F_SETFD, 1);
+	fcntl(local_socket, F_SETFL, fcntl(local_socket, F_GETFL, 0) | O_NONBLOCK);
 
 	memset(&sockaddr, 0, sizeof(sockaddr));
 	memcpy(sockaddr.sun_path, CLVMD_SOCKNAME, sizeof(CLVMD_SOCKNAME));


