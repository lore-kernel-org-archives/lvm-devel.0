From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 09:14:55 -0000
Subject: LVM2/daemons/common daemon-client.c
Message-ID: <20120215091455.6410.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 09:14:54

Modified files:
	daemons/common : daemon-client.c 

Log message:
	Do not forget to initialise the error value in daemon_reply.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/daemons/common/daemon-client.c	2012/01/25 21:31:59	1.11
+++ LVM2/daemons/common/daemon-client.c	2012/02/15 09:14:54	1.12
@@ -34,7 +34,7 @@
 
 daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 {
-	daemon_reply reply = { .cft = NULL };
+	daemon_reply reply = { .cft = NULL, .error = 0 };
 	assert(h.socket_fd >= 0);
 
 	if (!rq.buffer) {


