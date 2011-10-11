From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:23:48 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20111011092348.8624.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:23:48

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Add FIXMEs for init_test
	
	Usage of thread unprotected init_test is not correct and needs probably lvm lock
	since it part of lvm library. Current implementation may probably fail with
	test mode and actually create something unexpectedly (and vice versa).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:18:49	1.111
+++ LVM2/daemons/clvmd/clvmd.c	2011/10/11 09:23:48	1.112
@@ -1514,9 +1514,9 @@
 
 	if (replyargs != NULL) {
 		/* Run the command */
-		status =
-		    do_command(NULL, msg, msglen, &replyargs, buflen,
-			       &replylen);
+		/* FIXME: usage of init_test() is unprotected */
+		status = do_command(NULL, msg, msglen, &replyargs,
+				    buflen, &replylen);
 	} else {
 		status = ENOMEM;
 	}
@@ -1651,6 +1651,7 @@
 	/* Loop around doing PRE and POST functions until the client goes away */
 	while (!client->bits.localsock.finished) {
 		/* Execute the code */
+		/* FIXME: usage of init_test() is unprotected as in do_command() */
 		status = do_pre_command(client);
 
 		if (status)
@@ -1733,6 +1734,7 @@
 	if (replybuf == NULL)
 		return -1;
 
+	/* FIXME: usage of init_test() is unprotected */
 	status = do_command(client, msg, msglen, &replybuf, buflen, &replylen);
 
 	if (status)


