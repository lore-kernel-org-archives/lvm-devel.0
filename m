From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 11 Dec 2006 13:48:42 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20061211134842.21646.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2006-12-11 13:48:41

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix hang in clvmd if a pre-command failed. The pre/post thread was getting
	out of sync in this instance and would not quit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.515&r2=1.516
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2006/12/01 23:29:54	1.515
+++ LVM2/WHATS_NEW	2006/12/11 13:48:41	1.516
@@ -1,5 +1,6 @@
 Version 2.02.17 -
 ===================================
+  Fix hang in clvmd if a pre-command failed.
 
 Version 2.02.16 - 1st December 2006
 ===================================
--- LVM2/daemons/clvmd/clvmd.c	2006/12/01 23:10:25	1.32
+++ LVM2/daemons/clvmd/clvmd.c	2006/12/11 13:48:41	1.33
@@ -1426,6 +1426,8 @@
 		DEBUGLOG("Writing status %d down pipe %d\n", status, pipe_fd);
 		/* Tell the parent process we have finished this bit */
 		write(pipe_fd, &status, sizeof(int));
+		if (status)
+			continue; /* Wait for another PRE command */
 
 		/* We may need to wait for the condition variable before running the post command */
 		pthread_mutex_lock(&client->bits.localsock.mutex);


