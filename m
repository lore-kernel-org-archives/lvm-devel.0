From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Nov 2010 22:11:27 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c
Message-ID: <20101130221127.1763.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-30 22:11:26

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 

Log message:
	Check reallocated buffer for NULL before use
	
	As *buf is reallocated in case CLVMD_CMD_TEST: test for NULL is needed
	before printing status.
	(realloc() == NULL and status != 0)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1814&r2=1.1815
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2010/11/29 18:35:37	1.1814
+++ LVM2/WHATS_NEW	2010/11/30 22:11:26	1.1815
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Check reallocated buffer for NULL before use in clvmd do_command().
   Fix memory leak when VG allocation policy in metadata is invalid.
   Ignore unrecognised allocation policy found in metadata instead of aborting.
   Factor out tag printing into _out_tags and avoid leaking string buffer.
--- LVM2/daemons/clvmd/clvmd-command.c	2010/10/20 14:51:18	1.41
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/11/30 22:11:26	1.42
@@ -169,7 +169,8 @@
 
 	/* Check the status of the command and return the error text */
 	if (status) {
-		*retlen = 1 + snprintf(*buf, buflen, "%s", strerror(status));
+		*retlen = 1 + (*buf) ? snprintf(*buf, buflen, "%s",
+						strerror(status)) : -1;
 	}
 
 	return status;


