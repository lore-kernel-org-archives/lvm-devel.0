From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jan 2012 15:16:50 -0000
Subject: LVM2/daemons/common daemon-client.c daemon-cli ...
Message-ID: <20120115151650.29796.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-01-15 15:16:50

Modified files:
	daemons/common : daemon-client.c daemon-client.h 

Log message:
	Fix prototypes for daemon_send_simple (const char).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/daemons/common/daemon-client.c	2011/10/30 21:58:59	1.9
+++ LVM2/daemons/common/daemon-client.c	2012/01/15 15:16:50	1.10
@@ -57,7 +57,7 @@
 		dm_config_destroy(r.cft);
 }
 
-daemon_reply daemon_send_simple(daemon_handle h, char *id, ...)
+daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...)
 {
 	static const daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
 	daemon_request rq = { .cft = NULL };
--- LVM2/daemons/common/daemon-client.h	2011/08/30 15:42:57	1.8
+++ LVM2/daemons/common/daemon-client.h	2012/01/15 15:16:50	1.9
@@ -77,7 +77,7 @@
  * type (string, integer) of the value is indicated by a character substituted
  * for ? in %?: d for integer, s for string.
  */
-daemon_reply daemon_send_simple(daemon_handle h, char *id, ...);
+daemon_reply daemon_send_simple(daemon_handle h, const char *id, ...);
 
 void daemon_reply_destroy(daemon_reply r);
 


