From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Apr 2010 14:51:58 -0000
Subject: LVM2/daemons/clvmd clvmd-command.c
Message-ID: <20100430145158.32539.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-30 14:51:58

Modified files:
	daemons/clvmd  : clvmd-command.c 

Log message:
	typo

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/daemons/clvmd/clvmd-command.c	2010/04/30 14:49:44	1.33
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/04/30 14:51:58	1.34
@@ -371,7 +371,7 @@
 	/*
 	 * Build the command-line
 	 */
-	/* FIXME missing strup error checks */
+	/* FIXME missing strdup error checks */
 	argv[0] = strdup("clvmd");
 
 	/* Propogate debug options */


