From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Sep 2007 17:06:33 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070917170633.4683.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-09-17 17:06:32

Modified files:
	.              : WHATS_NEW 

Log message:
	clarification

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.707&r2=1.708

--- LVM2/WHATS_NEW	2007/09/17 16:02:46	1.707
+++ LVM2/WHATS_NEW	2007/09/17 17:06:31	1.708
@@ -1,8 +1,8 @@
 Version 2.02.29 -
 ==================================
   Fix strdup memory leak in str_list_dup().
-  Avoid static link failure with some SELinux libraries.
-  Diagnose invalid PE values given on the pvmove command line (64-bit systems).
+  Link with -lpthread when static SELinux libraries require that.
+  Detect command line PE values that exceed their 32-bit range.
   Include strerror string in dev_open_flags' stat failure message.
   Move guts of pvresize into library.
   Avoid error when --corelog is provided without --mirrorlog. (2.02.28)


