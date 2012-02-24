From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 24 Feb 2012 00:02:54 -0000
Subject: LVM2/daemons/common daemon-client.c
Message-ID: <20120224000254.31184.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-24 00:02:54

Modified files:
	daemons/common : daemon-client.c 

Log message:
	Fix an error path in daemon_open.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/daemons/common/daemon-client.c	2012/02/23 23:52:11	1.13
+++ LVM2/daemons/common/daemon-client.c	2012/02/24 00:02:54	1.14
@@ -10,6 +10,7 @@
 
 daemon_handle daemon_open(daemon_info i) {
 	daemon_handle h = { .protocol_version = 0 };
+	daemon_reply r = { .cft = NULL };
 	struct sockaddr_un sockaddr;
 
 	if ((h.socket_fd = socket(PF_UNIX, SOCK_STREAM /* | SOCK_NONBLOCK */, 0)) < 0) {
@@ -25,7 +26,7 @@
 		goto error;
 	}
 
-	daemon_reply r = daemon_send_simple(h, "hello", NULL);
+	r = daemon_send_simple(h, "hello", NULL);
 	if (r.error || strcmp(daemon_reply_str(r, "response", "unknown"), "OK"))
 		goto error;
 


