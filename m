From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Dec 2010 12:37:50 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c ./WHATS_NEW
Message-ID: <20101217123750.24540.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-17 12:37:50

Modified files:
	daemons/clvmd  : clvmd-command.c 
	.              : WHATS_NEW 

Log message:
	Fix NULL pointer check for *buf
	
	As ternary operator has lower priority then add operation, this check
	was not doing what seemed to be expected.
	
	So enclose the test in braces and check for NULL in *buf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1838&r2=1.1839

--- LVM2/daemons/clvmd/clvmd-command.c	2010/11/30 22:16:25	1.43
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/12/17 12:37:49	1.44
@@ -168,8 +168,8 @@
 
 	/* Check the status of the command and return the error text */
 	if (status) {
-		*retlen = 1 + (*buf) ? dm_snprintf(*buf, buflen, "%s",
-						   strerror(status)) : -1;
+		*retlen = 1 + ((*buf) ? dm_snprintf(*buf, buflen, "%s",
+						    strerror(status)) : -1);
 	}
 
 	return status;
--- LVM2/WHATS_NEW	2010/12/15 12:49:55	1.1838
+++ LVM2/WHATS_NEW	2010/12/17 12:37:50	1.1839
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Fix NULL pointer check in error path in clvmd do_command(). (2.02.78)
   Fix device.c #include to ensure 64-bit fopen64 use. (2.02.51)
   Create /var/run/lvm directory during clvmd initialisation if missing.
   Use new dm_prepare_selinux_context instead of dm_set_selinux_context.


