From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 21:31:59 -0000
Subject: LVM2/daemons/common daemon-client.c
Message-ID: <20120125213159.3552.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 21:31:59

Modified files:
	daemons/common : daemon-client.c 

Log message:
	Ensure reply struct has all fields defined
	
	Reply is returned by value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/daemons/common/daemon-client.c	2012/01/15 15:16:50	1.10
+++ LVM2/daemons/common/daemon-client.c	2012/01/25 21:31:59	1.11
@@ -34,7 +34,7 @@
 
 daemon_reply daemon_send(daemon_handle h, daemon_request rq)
 {
-	daemon_reply reply;
+	daemon_reply reply = { .cft = NULL };
 	assert(h.socket_fd >= 0);
 
 	if (!rq.buffer) {


