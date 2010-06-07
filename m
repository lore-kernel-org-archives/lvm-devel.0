From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 Jun 2010 13:52:54 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/refresh_clvmd.c
Message-ID: <20100607135254.3013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-07 13:52:53

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : refresh_clvmd.c 

Log message:
	Fix segfault in clvmd -R if no response from daemon received.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1609&r2=1.1610
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2010/06/07 10:25:43	1.1609
+++ LVM2/WHATS_NEW	2010/06/07 13:52:52	1.1610
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Fix segfault in clvmd -R if no response from daemon received.
 
 Version 2.02.67 - 4th June 2010
 ===============================
--- LVM2/daemons/clvmd/refresh_clvmd.c	2010/04/20 14:07:38	1.8
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2010/06/07 13:52:53	1.9
@@ -336,7 +336,7 @@
 	int num_responses;
 	char args[1];
 	const char *nodes;
-	lvm_response_t *response;
+	lvm_response_t *response = NULL;
 	int saved_errno;
 	int status;
 	int i;


