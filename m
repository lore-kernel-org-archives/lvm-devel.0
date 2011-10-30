From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Oct 2011 21:59:00 -0000
Subject: LVM2/daemons common/daemon-client.c lvmetad/lv ...
Message-ID: <20111030215900.3473.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-30 21:58:59

Modified files:
	daemons/common : daemon-client.c 
	daemons/lvmetad: lvmetad-core.c 

Log message:
	Cleanup for lvmetad passing uninit structure
	
	Shown by clang analyzer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/common/daemon-client.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/daemons/common/daemon-client.c	2011/09/17 14:49:18	1.8
+++ LVM2/daemons/common/daemon-client.c	2011/10/30 21:58:59	1.9
@@ -60,7 +60,7 @@
 daemon_reply daemon_send_simple(daemon_handle h, char *id, ...)
 {
 	static const daemon_reply err = { .error = ENOMEM, .buffer = NULL, .cft = NULL };
-	daemon_request rq;
+	daemon_request rq = { .cft = NULL };
 	daemon_reply repl;
 	va_list ap;
 
--- LVM2/daemons/lvmetad/lvmetad-core.c	2011/09/17 13:33:51	1.26
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2011/10/30 21:58:59	1.27
@@ -453,7 +453,7 @@
 int main(int argc, char *argv[])
 {
 	signed char opt;
-	daemon_state s;
+	daemon_state s = { .private = NULL };
 	lvmetad_state ls;
 	int _restart = 0;
 


