From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 1 Jul 2010 21:46:10 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/refresh_clvmd.c
Message-ID: <20100701214610.947.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-07-01 21:46:09

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : refresh_clvmd.c 

Log message:
	Fix another segfault in clvmd -R if no response from daemon received.
	
	Missed the same problem in another function...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1647&r2=1.1648
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2010/07/01 21:23:47	1.1647
+++ LVM2/WHATS_NEW	2010/07/01 21:46:09	1.1648
@@ -1,5 +1,6 @@
 Version 2.02.70 - 
 ================================
+  Fix another segfault in clvmd -R if no response from daemon received. (2.02.68)
   Remove superfluous suspended device counter from clvmd.
   Fix lvm shell crash when input is entirely whitespace.
   Update partial mode warning message.
--- LVM2/daemons/clvmd/refresh_clvmd.c	2010/06/21 15:56:58	1.12
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2010/07/01 21:46:09	1.13
@@ -285,7 +285,7 @@
 {
 	int num_responses;
 	char args[1]; // No args really.
-	lvm_response_t *response;
+	lvm_response_t *response = NULL;
 	int saved_errno;
 	int status;
 	int i;


