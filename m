From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 11:06:57 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20120228110657.1429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 11:06:56

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Ensure clvmd message is always \0 terminated
	
	Drop whole buffer clearing (most messages at <100 bytes).
	Just make sure we have always \0 terminated string for strlen() operations.
	(before for PIPE_BUF sized messages this was not set).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2322&r2=1.2323
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/WHATS_NEW	2012/02/28 11:03:24	1.2322
+++ LVM2/WHATS_NEW	2012/02/28 11:06:56	1.2323
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Ensure clvmd message is always \0 terminated after read.
   Better detection of missing dmeventd fifo connection (2.02.93).
   Add some close() and dev_close() error path backtraces.
   For polling daemon reopen stdin,stdout,stderr to /dev/null.
--- LVM2/daemons/clvmd/clvmd.c	2012/02/28 10:42:20	1.128
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/28 11:06:56	1.129
@@ -1087,10 +1087,9 @@
 	int len;
 	int argslen;
 	int missing_len;
-	char buffer[PIPE_BUF];
+	char buffer[PIPE_BUF + 1];
 
-	memset(buffer, 0, PIPE_BUF);
-	len = read(thisfd->fd, buffer, sizeof(buffer));
+	len = read(thisfd->fd, buffer, sizeof(buffer) - 1);
 	if (len == -1 && errno == EINTR)
 		return 1;
 
@@ -1180,6 +1179,7 @@
 		struct clvm_header *inheader;
 		int status;
 
+		buffer[len] = 0; /* Ensure \0 terminated */
 		inheader = (struct clvm_header *) buffer;
 
 		/* Fill in the client ID */


